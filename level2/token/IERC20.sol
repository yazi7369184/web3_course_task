// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * 合约可以声明支持的接口，供其他合约检查
 *
 */
interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    
    function approve(address spender, uint256 amount) external;

    function transfer(address to, uint256 amount) external;

    function transferFrom(address from , address to, uint256 amount) external;


    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    

}
