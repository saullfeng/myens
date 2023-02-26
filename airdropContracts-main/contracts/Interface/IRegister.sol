//  SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IRegister is IERC721 {

    function addController(address controller) external;

    function removeController(address controller) external;

    function register(uint256 id, address owner, uint duration) external returns(uint);

    function renew(uint256 id, uint duration) external returns(uint);

    function available(uint256 id) external view returns(bool);

    function checkExpire(uint256 id) external view returns(uint256);

    function reclaim(uint256 id, address owner) external;

    function isExist(uint256 id) external view returns(bool);

    function getNameByHash(uint256 id) external view returns(string memory);
}
