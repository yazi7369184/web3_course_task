// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

contract RCCApe is ERC721 {

    uint MAX_APES = 1000;//总量

    constructor (string memory name, string memory symbol) ERC721(name, symbol) {

    }

    function mint(address to, uint256 tokenId) external  {
        require(tokenId >= 0 && tokenId <= MAX_APES, "token out of range");
        _mint(to, tokenId);
    }
    
}