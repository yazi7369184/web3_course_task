// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC165.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./Strings.sol";

contract ERC721 is IERC721, IERC721Metadata {
    //使用String库
    using Strings for uint256;
    //Token名称
    string public override name;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    //Token代号
    string public override symbol;

    //tokenId到owner address 的持有人映射
    mapping(uint256 => address) private owners;

    //address 到 持仓数量的持仓数量映射
    mapping(address => uint256) private balances;

    //tokenId 到 授权地址的 持仓映射
    mapping(uint256 => address) private tokenApprovals;

    //owner地址到operator地址的批量授权映射
    mapping(address => mapping(address => bool)) private operatorApprovals;

    //错误 无效的接收者
    error ERC721InvalidReceiver(address receiver);

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(owners[tokenId] != address(0), "Token not exist");
        string memory baseURI = "";
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId)) : "";
    }

    function balanceOf(address owner) external view returns (uint256 balance) {
        require(owner != address(0), "owner = zero address");
        return balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address owner) {
        owner = owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    function isOwnerOrApproved(
        address owner,
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        return
            owner == spender ||
            tokenApprovals[tokenId] == spender ||
            operatorApprovals[owner][spender];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external override   {
        _safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        _safeTransferFrom(from, to, tokenId, "");
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal   {
        address owner = owners[tokenId];
        require(isOwnerOrApproved(owner, msg.sender, tokenId), "not owner or approved");
        transfer(owner, from, to, tokenId);
        checkOnERC721Received(from, to, tokenId, data);
    }


    function checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) internal  {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
               if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
               } else {
                 /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
               }     
            }
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        address owner = owners[tokenId];
        require(isOwnerOrApproved(owner, msg.sender, tokenId), "not owner or approved");
        transfer(owner, from, to, tokenId);
    }

    function transfer(
        address owner,
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(owner == from, "not owner");
        require(to != address(0), "transfer to the zero address");
        approve(owner, address(0), tokenId);
        balances[from] -= 1;
        balances[to] += 1;
        owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        address owner = owners[tokenId];
        require(msg.sender == owner || operatorApprovals[owner][msg.sender]);
        approve(owner, to, tokenId);
    }

    function approve(
        address owner,
        address to,
        uint256 tokenId
    ) internal {
        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool _approved) external {
        operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator)
    {
        return tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool)
    {
        return operatorApprovals[owner][operator];
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(owners[tokenId] == address(0), "token already minted");

        balances[to] += 1;
        owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal virtual {
        address owner = owners[tokenId];
        require(msg.sender == owner, "not owner of token");
        approve(owner, address(0), tokenId);
        balances[owner] -= 1;
        delete owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

}
