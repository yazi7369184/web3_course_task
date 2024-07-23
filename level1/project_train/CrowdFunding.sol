// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract CrowdFunding {
    //受益人
    address public immutable beneficiary;

    //众筹目标数量
    uint256 public immutable fundingGoal;

    //当前金额
    uint256 public fundingAmount;

    //捐赠人映射
    mapping(address => uint256) public funders;

    mapping(address => bool) private fundersInserted;

    address[] public fundersKey;

    bool public AVAIABLED = true;

    constructor(address beneficiary_, uint256 goal_) {
        beneficiary = beneficiary_;
        fundingGoal = goal_;
    }
                                        
    function contribute() external payable {
        require(AVAIABLED, "CrowdFunding is closed");

        uint256 potentialFundingAmount = fundingAmount + msg.value;
        uint256 refundAmount = 0;

        if (potentialFundingAmount > fundingGoal) {
            refundAmount = potentialFundingAmount - fundingGoal;
            funders[msg.sender] += msg.value - refundAmount;
            fundingAmount += msg.value - refundAmount;
        } else {
            funders[msg.sender] += msg.value;
            fundingAmount += msg.value;
        }

        if (!fundersInserted[msg.sender]) {
            fundersInserted[msg.sender] = true;
            fundersKey.push(msg.sender);
        }

        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }

    }

    function close() external returns(bool) {
        if (fundingAmount < fundingGoal) {
            return false;
        }
        uint256 amount = fundingAmount;
        fundingAmount = 0;
        AVAIABLED = false;
        payable(beneficiary).transfer(amount);
        return true;
    }

    function fundersLength() public view returns(uint256) {
        return fundersKey.length;
    }


}