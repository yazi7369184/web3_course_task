// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Bank {

    address public immutable owner;
    
    //ETH以外的资产
    mapping(address => mapping(address => uint256)) public balances;


    event Deopsit(address ads, uint256 ammount);

    event Withdraw(uint256 amount);

    receive() external payable {
        emit Deopsit(msg.sender, msg.value);
    }

    constructor() payable {
        owner = msg.sender;
    }

    function deposit() external payable  {
        //require(amount > 0, "invalid amount");
        emit Deopsit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Not Owner");
        require(address(this).balance >= amount, "insufficient balance");
        payable(msg.sender).transfer(amount);
        emit Withdraw(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //存款ERC20代币
    function depositERC20Token(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount");
        bool success_flag = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success_flag, "Token transfer failed");
        balances[msg.sender][token] += amount;
        emit Deopsit(msg.sender, amount);
    }

    //取款ERC20代币
    function withdrawERC20Token(address token, uint amount) external {
        require(msg.sender == owner, "only owner can withdraw");
        require(address(this).balance >= amount, "insufficient balance");
        bool flag = IERC20(token).transfer(msg.sender, amount);
        require(flag, "Token transfer failed");
        balances[msg.sender][token] -= amount;
        emit Withdraw(amount);
    }


    //存款ERC721代币
    function depositERC721Token(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount");
        ERC721(token).transferFrom(msg.sender, address(this), amount);
        //require(success_flag, "Token transfer failed");
        balances[msg.sender][token] += amount;
        emit Deopsit(msg.sender, amount);
    }

    //取款ERC721代币
    function withdrawERC721Token(address token, uint256 amount) external {
        require(msg.sender == owner, "only owner can withdraw");
        require(address(this).balance >= amount, "insufficient balance");
        //资产给用户
        IERC721(token).transferFrom(address(this), msg.sender, amount);
        balances[msg.sender][token] -= amount;
        emit Withdraw(amount);
    }





}