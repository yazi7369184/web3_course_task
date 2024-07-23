// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSignWallet {

    address[] public owners;

    mapping(address => bool) public isOwner;

    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool exected;
    }

    Transaction[] public transactions;

    mapping(uint256 => mapping(address => bool)) public approved;

    event Deposit(address indexed sender, uint256 amount);

    event Submit(uint256 indexed txId);

    event Approve(address indexed owner, uint256 indexed txId);

    event Revoke(address indexed owner, uint256 indexed txId);

    event Execute(uint256 indexed txId);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not Owner");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "tx doesn't exist");
        _;
    }

    modifier notApproved(uint256 txId) {
        require(!approved[txId][msg.sender], "tx already approved");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].exected, "");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owner required");
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required number of owners");
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;    
    }

    // 函数
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function submit(
        address _to, 
        uint256 _value, 
        bytes calldata _data
    ) external onlyOwner returns(uint256) {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, exected: false})
        );
        emit Submit(transactions.length - 1);
        return transactions.length - 1;
    } 

    function approve(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notApproved(txId)
        notExecuted(txId)
        {
            approved[txId][msg.sender] = true;
            emit Approve(msg.sender, txId);
        } 

    function execute(uint256 txId)
        external 
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        require(getApprovalCount(txId) >= required, "approvals < required");
        Transaction storage transaction = transactions[txId];
        transaction.exected = true;
       (bool sucess, ) = transaction.to.call{value: transaction.value}(transaction.data);
       require(sucess, "tx failed");
       emit Execute(txId);   
    }

    function getApprovalCount(uint256 txId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 index = 0; index < owners.length; index++) {
            if (approved[txId][owners[index]]) {
                count++;
            }
        }
    }

    function revoke(uint256 txId)
        external
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        require(approved[txId][msg.sender], "tx not approved");
        approved[txId][msg.sender] = false;
        emit Revoke(msg.sender, txId);
    }

}