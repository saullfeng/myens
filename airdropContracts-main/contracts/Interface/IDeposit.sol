//  SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.16 <0.9.0;

interface IDeposit {
    function deposit(uint256 tokenId) external;

    function withdraw(uint256 tokenId, address to) external;

    function setOperator(address operator) external;
}
