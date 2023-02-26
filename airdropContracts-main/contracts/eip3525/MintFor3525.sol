//  SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@solvprotocol/erc-3525/ERC3525.sol";

//set slot_ owner 来定
//value_ 有固定类型

contract MintFor3525 is ERC3525 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC3525(name_, symbol_, decimals_) {}

    function mint(
        address to_,
        uint256 tokenId_,
        uint256 slot_,
        uint256 value_
    ) public virtual {
        ERC3525._mint(to_, tokenId_, slot_, value_);
    }

    function mintValue(uint256 tokenId_, uint256 value_) public virtual {
        ERC3525._mintValue(tokenId_, value_);
    }

    // 一个tokenid拆分 return 一个new的tokenid 一个 原来的tokenid
    function transferFrom(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) public payable virtual override returns (uint256 newTokenId) {
        newTokenId = ERC3525.transferFrom(tokenId_, to_, value_);
    }

    //两个tokenid合并
    function transferFrom(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) public payable virtual override {
        ERC3525.transferFrom(fromTokenId_, toTokenId_, value_);
    }

    function burn(uint256 tokenId_) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId_),
            "ERC3525: caller is not token owner nor approved"
        );
        ERC3525._burn(tokenId_);
    }

    function burnValue(uint256 tokenId_, uint256 burnValue_) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId_),
            "ERC3525: caller is not token owner nor approved"
        );
        ERC3525._burnValue(tokenId_, burnValue_);
    }

    function approve(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) public payable virtual override {
        ERC3525.approve(tokenId_, to_, value_);
    }

    function getAllTokenIdValue(address owner_)
        public
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256 length = ERC3525.balanceOf(owner_);
        // uint256 memory tokenValue[]= new uint256[];
        uint256[] memory tokenValue = new uint256[](length);
        uint256[] memory tokenIds = new uint256[](length);
        for (uint256 i = 0; i < length; ) {
            uint256 tokenId = ERC3525.tokenOfOwnerByIndex(owner_, i);
            // tokenIds[i] = tokenId;
            uint256 value = ERC3525.balanceOf(tokenId);
            tokenValue[i] = value;
            tokenIds[i] = tokenId;

            unchecked {
                ++i;
            }
        }
        return (tokenValue, tokenIds);
    }
}
