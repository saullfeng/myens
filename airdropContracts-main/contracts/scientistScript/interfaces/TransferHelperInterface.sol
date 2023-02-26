// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {TransferHelperItem, TransferHelperItemsWithRecipient} from "../helpers/TransferHelperStructs.sol";

interface TransferHelperInterface {
    /**
     * @notice Transfer multiple items to a single recipient.
     *
     * @param items The items to transfer.
     * @param conduitKey  The key of the conduit performing the bulk transfer.
     */
    /**
     * @notice 将多个项目转移给一个收件人。
     *
     * @param items 要传输的项目。
     * @param conduitKey 执行批量传输的管道的密钥。
     */
    function bulkTransfer(
        TransferHelperItemsWithRecipient[] calldata items,
        bytes32 conduitKey
    ) external returns (bytes4);
}
