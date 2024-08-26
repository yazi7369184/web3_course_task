// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721Receiver.sol";
import "./IERC721.sol";

contract NFTSwap is IERC721Receiver{

    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);

    event Revoke(address indexed seller, address indexed  nftAddr, uint256 indexed tokenId);

    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);

    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId);
    
    struct Order {
        address owner;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Order)) public nfgList;

   

    function onERC721Received (
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external pure  returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function list(address nftAddr, uint256 tokenId, uint256 price) public {
        IERC721 nft = IERC721(nftAddr);
        require(nft.getApproved(tokenId) == address(this),  "need approve");
        require(price > 0, "price <= 0");
        Order storage order = nfgList[nftAddr][tokenId];
        order.owner = msg.sender;
        order.price = price;
        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        emit List(msg.sender, nftAddr, tokenId, price);
    }

    function revoke(address nftAddr, uint256 tokenId) public {
        
        Order storage order = nfgList[nftAddr][tokenId];
        require(order.owner == msg.sender, "Not owner");

        IERC721 nft = IERC721(nftAddr);

        require(nft.ownerOf(tokenId) == address(this), "Invalid Order");

        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        delete nfgList[nftAddr][tokenId];

        emit Revoke(msg.sender, nftAddr, tokenId);
    }

    function update(address nftAddr, uint256 tokenId, uint256 newPrice) public {
        require(newPrice > 0, "newPrice <= 0");
        Order storage order = nfgList[nftAddr][tokenId];
        require(order.owner == msg.sender, "Not owner");
        IERC721 nft = IERC721(nftAddr);

        require(nft.ownerOf(tokenId) == address(this), "Invalid Order");
        order.price = newPrice;
        emit Update(msg.sender, nftAddr, tokenId, newPrice);
    }

    function purchase(address nftAddr, uint256 tokenId) public payable {
        Order storage order = nfgList[nftAddr][tokenId];
        require(order.price > 0, "Invalid price");
        require(msg.value >= order.price, "insufficient price");
        
        IERC721 nft = IERC721(nftAddr);

        require(nft.ownerOf(tokenId) == address(this), "Invalid Order");
        
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        payable(order.owner).transfer(order.price);

        payable(msg.sender).transfer(msg.value - order.price);

        delete nfgList[nftAddr][tokenId];

        emit Purchase(msg.sender, nftAddr, tokenId);
    }



    fallback() external payable { 
        //string memory s = "";
    }
    receive() external payable { }
}