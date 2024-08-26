// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
* 合约可以声明支持的接口，供其他合约检查    
*
*/
interface IERC165 {

    
    /**
    *   如果合约实现了查询的`interfaceId`，则返回true
    *
    */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}