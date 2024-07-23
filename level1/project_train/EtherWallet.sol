// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EtherWallet {

    address payable public immutable owner;

    event Log(string funName, address from, uint256 value, bytes data);

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }

    function withdraw1() external requireOwner {
        payable(msg.sender).transfer(address(this).balance);
    }


/**
 * @dev This function allows an owner to deposit ether into the contract.
 */    function withdraw2() external requireOwner {                                                                  
        bool flag = payable(msg.sender).send(address(this).balance);
        require(flag, "Send failed");
    }

    function withdraw3() external requireOwner {
        (bool flag, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(flag, "call failed");
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    modifier requireOwner() {
        require(msg.sender == owner);
        _;
    }


}