// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {ConduitItemType} from "./conduit/lib/ConduitEnums.sol";

/**
 * @dev A TransferHelperItem specifies the itemType (ERC20/ERC721/ERC1155),
 *      token address, token identifier, and amount of the token to be
 *      transferred via the TransferHelper. For ERC20 tokens, identifier
 *      must be 0. For ERC721 tokens, amount must be 1.
 */

/**
 * @dev 一个 TransferHelperItem 指定 itemType (ERC20/ERC721/ERC1155),
 * 代币地址、代币标识符和代币数量
 * 通过 TransferHelper 传输。 对于 ERC20 令牌，标识符
 * 必须为 0。对于 ERC721 代币，金额必须为 1。
 */
struct TransferHelperItem {
    ConduitItemType itemType;
    address token;
    uint256 identifier;
    uint256 amount;
}

/**
 * @dev A TransferHelperItemsWithRecipient specifies the tokens to transfer
 *      via the TransferHelper, their intended recipient, and a boolean flag
 *      indicating whether onERC721Received should be called on a recipient
 *      contract.
 */
/**
 * @dev A TransferHelperItemsWithRecipient 指定要转移的代币
 * 通过 TransferHelper、他们的预期收件人和一个布尔标志
 * 指示是否应在收件人上调用 onERC721Received
 *      合同。
 */
struct TransferHelperItemsWithRecipient {
    TransferHelperItem[] items;
    address recipient;
    bool validateERC721Receiver;
}
