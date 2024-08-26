// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract BTCToken is IERC20 {

    string private _name;

    string private _symbol;

    address private _owner;

    uint256 private  _totalSupply;

    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowances;

    event Approve(address owner, address spender, uint256 amount);

    event Transfer(address from, address to, uint256 amount);

    constructor () {
        _name = "Bitcoin";
        _symbol = "BTC";
        _owner = msg.sender;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "not owner");
        _;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256) {
           mapping(address => uint256) storage _allowance = allowances[owner];
           return _allowance[spender];
        }
    
    function approve(address spender, uint256 amount) external {
        require(spender != address(0), "invaild address");
        allowances[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);
    }

    function transfer(address to, uint256 amount) external {
        _transferFrom(msg.sender, msg.sender, to, amount);
    }

    function transferFrom(address from , address to, uint256 amount) external {
        _transferFrom(msg.sender, from, to, amount);
    }

    function _transferFrom(address spender, address from , address to, uint256 amount) private {
        require(amount > 0, "amount <= 0");
        require(spender != from && allowances[from][spender] >= amount, "not approved");
        require(balances[from] >= amount, "insufficient amount");
        balances[from] -= amount;
        balances[to] += amount;
        if (spender != from) {
            allowances[from][spender] -= amount;
        }
        emit Transfer(from, to, amount);
    }


    function mint(address account, uint256 amount) external onlyOwner {
        require(amount > 0, "amount <= 0");
        require(account != address(0), "invalid account");
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        require(amount > 0, "amount <= 0");
        require(account != address(0), "invalid account");
        uint256 _amount = balances[account];
        uint256 burnAmount = _amount > amount ?  amount : _amount;
        balances[account] += burnAmount;
        emit Transfer(account, address(0), amount);
    }

}