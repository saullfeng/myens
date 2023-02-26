//  SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../Interface/ILayerZeroEndpoint.sol";
import "../Interface/ILayerZeroReceiver.sol";

contract Gen721 is ERC721, Ownable {
    mapping(address => bool) whiteList;
    mapping(uint => uint) expire_table;

    constructor() ERC721("star", "star") {
        _safeMint(msg.sender, 1);
        expire_table[1] = block.timestamp + 1000000;
    }

    modifier onlyWhiteList() {
        require(whiteList[msg.sender] == true, "is not in");
        _;
    }

    function setWhiteList(address _addr, bool _flag) external onlyOwner {
        whiteList[_addr] = _flag;
    }

    
    function readWhiteList(address _addr) external view returns (bool) {
        return whiteList[_addr];
    }

    function register(
        uint tokenId,
        address _to,
        uint duration
    ) external onlyWhiteList {
        require(
            expire_table[tokenId] <= block.timestamp,
            " your domain is expired"
        );
        if (expire_table[tokenId] != 0) {
            _burn(tokenId);
        }
        expire_table[tokenId] = block.timestamp + duration;
        _safeMint(_to, tokenId);
    }

    function getDuration(uint label) external view returns (uint) {
        return expire_table[label] - block.timestamp;
    }

    function isExist(uint tokenId) external view returns (bool) {
        return _exists(tokenId);
    }
}
