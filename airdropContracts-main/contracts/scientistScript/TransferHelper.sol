// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.7;

// import {IERC721Receiver} from "./interfaces/IERC721Receiver.sol";

// import "./TransferHelperStructs.sol";

// import {ConduitInterface} from "./interfaces/ConduitInterface.sol";

// import {ConduitControllerInterface} from "./interfaces/ConduitControllerInterface.sol";

// import {Conduit} from "./conduit/Conduit.sol";

// import {ConduitTransfer} from "./conduit/lib/ConduitStructs.sol";

// import {TransferHelperInterface} from "./interfaces/TransferHelperInterface.sol";

// import {TransferHelperErrors} from "./interfaces/TransferHelperErrors.sol";

// /**
//  * @title TransferHelper
//  * @author stephankmin, stuckinaboot, ryanio
//  * @notice TransferHelper is a utility contract for transferring
//  *         ERC20/ERC721/ERC1155 items in bulk to specific recipients.
//  */

// /**
//  * @title 转账助手
//  * @author stephankmin, stuckinaboot, ryanio
//  * @notice TransferHelper 是一个用于转账的实用合约
//  * ERC20/ERC721/ERC1155 项目批量发送给特定收件人。
//  */
// contract TransferHelper is TransferHelperInterface, TransferHelperErrors {
//     // Allow for interaction with the conduit controller.
//     ConduitControllerInterface internal immutable _CONDUIT_CONTROLLER;

//     // Set conduit creation code and runtime code hashes as immutable arguments.
//     // 将管道创建代码和运行时代码哈希设置为不可变参数。
//     bytes32 internal immutable _CONDUIT_CREATION_CODE_HASH;
//     bytes32 internal immutable _CONDUIT_RUNTIME_CODE_HASH;

//     /**
//      * @dev Set the supplied conduit controller and retrieve its
//      *      conduit creation code hash.
//      *
//      *
//      * @param conduitController A contract that deploys conduits, or proxies
//      *                          that may optionally be used to transfer approved
//      *                          ERC20/721/1155 tokens.
//      */

//     /**
//      * @dev 设置提供的管道控制器并检索它的
//      * 管道创建代码哈希。
//      *
//      *
//      * @param conduitController 部署管道或代理的合约
//      * 可以选择性地用于转移批准
//      * ERC20/721/1155 代币。
//      */
//     constructor(address conduitController) {
//         // Get the conduit creation code and runtime code hashes from the
//         // supplied conduit controller and set them as an immutable.
//         // 从中获取管道创建代码和运行时代码哈希
//         // 提供的管道控制器并将它们设置为不可变的。
//         ConduitControllerInterface controller = ConduitControllerInterface(
//             conduitController
//         );
//         (_CONDUIT_CREATION_CODE_HASH, _CONDUIT_RUNTIME_CODE_HASH) = controller
//             .getConduitCodeHashes();

//         // Set the supplied conduit controller as an immutable.
//         _CONDUIT_CONTROLLER = controller;
//     }

//     /**
//      * @notice Transfer multiple ERC20/ERC721/ERC1155 items to
//      *         specified recipients.
//      *
//      * @param items      The items to transfer to an intended recipient.
//      * @param conduitKey An optional conduit key referring to a conduit through
//      *                   which the bulk transfer should occur.
//      *
//      * @return magicValue A value indicating that the transfers were successful.
//      */
//     /**
//      * @notice 将多个 ERC20/ERC721/ERC1155 项目转移到
//      * 指定收件人。
//      *
//      * @param items 要转移给预期收件人的项目。
//      * @param conduitKey 一个可选的管道键，指的是一个管道
//      * 批量传输应该发生。
//      *
//      * @return magicValue 表示传输成功的值。
//      */
//     function bulkTransfer(
//         TransferHelperItemsWithRecipient[] calldata items,
//         bytes32 conduitKey
//     ) external view returns (bytes4 magicValue) {
//         // Ensure that a conduit key has been supplied.
//         if (conduitKey == bytes32(0)) {
//             revert InvalidConduit(conduitKey, address(0));
//         }

//         // Use conduit derived from supplied conduit key to perform transfers.
//         _performTransfersWithConduit(items, conduitKey);

//         // Return a magic value indicating that the transfers were performed.
//         magicValue = this.bulkTransfer.selector;
//     }

//     /**
//      * @notice Perform multiple transfers to specified recipients via the
//      *         conduit derived from the provided conduit key.
//      *
//      * @param transfers  The items to transfer.
//      * @param conduitKey The conduit key referring to the conduit through
//      *                   which the bulk transfer should occur.
//      */
//     /**
//      * @notice 通过
//      * 管道派生自提供的管道密钥。
//      *
//      * @param transfers 要传输的项目。
//      * @param conduitKey 指代管道的管道密钥
//      * 批量传输应该发生。
//      */
//     function _performTransfersWithConduit(
//         TransferHelperItemsWithRecipient[] calldata transfers,
//         bytes32 conduitKey
//     ) internal {
//         // Retrieve total number of transfers and place on stack.
//         uint256 numTransfers = transfers.length;

//         // Derive the conduit address from the deployer, conduit key
//         // and creation code hash.
//         // 从部署者中导出管道地址，管道密钥
//         // 和创建代码哈希。
//         address conduit = address(
//             uint160(
//                 uint256(
//                     keccak256(
//                         abi.encodePacked(
//                             bytes1(0xff),
//                             address(_CONDUIT_CONTROLLER),
//                             conduitKey,
//                             _CONDUIT_CREATION_CODE_HASH
//                         )
//                     )
//                 )
//             )
//         );

//         // Declare a variable to store the sum of all items across transfers.
//         uint256 sumOfItemsAcrossAllTransfers;

//         // Skip overflow checks: all for loops are indexed starting at zero.
//         unchecked {
//             // Iterate over each transfer.
//             for (uint256 i = 0; i < numTransfers; ++i) {
//                 // Retrieve the transfer in question.
//                 TransferHelperItemsWithRecipient calldata transfer = transfers[
//                     i
//                 ];

//                 // Increment totalItems by the number of items in the transfer.
//                 sumOfItemsAcrossAllTransfers += transfer.items.length;
//             }
//         }

//         // Declare a new array in memory with length totalItems to populate with
//         // each conduit transfer.
//         ConduitTransfer[] memory conduitTransfers = new ConduitTransfer[](
//             sumOfItemsAcrossAllTransfers
//         );

//         // Declare an index for storing ConduitTransfers in conduitTransfers.
//         uint256 itemIndex;

//         // Skip overflow checks: all for loops are indexed starting at zero.
//         unchecked {
//             // Iterate over each transfer.
//             for (uint256 i = 0; i < numTransfers; ++i) {
//                 // Retrieve the transfer in question.
//                 TransferHelperItemsWithRecipient calldata transfer = transfers[
//                     i
//                 ];

//                 // Retrieve the items of the transfer in question.
//                 TransferHelperItem[] calldata transferItems = transfer.items;

//                 // Ensure recipient is not the zero address.
//                 _checkRecipientIsNotZeroAddress(transfer.recipient);

//                 // Create a boolean indicating whether validateERC721Receiver
//                 // is true and recipient is a contract.

//                 // 创建一个布尔值，指示是否验证 ERC721Receiver
//                 // 为真，接收者是一个合约。
//                 bool callERC721Receiver = transfer.validateERC721Receiver &&
//                     transfer.recipient.code.length != 0;

//                 // Retrieve the total number of items in the transfer and
//                 // place on stack.

//                 // 检索转移中的项目总数和
//                 // 放在堆栈上。
//                 uint256 numItemsInTransfer = transferItems.length;

//                 // Iterate over each item in the transfer to create a
//                 // corresponding ConduitTransfer.
//                 // 遍历传输中的每个项目以创建一个
//                 // 相应的 ConduitTransfer。
//                 for (uint256 j = 0; j < numItemsInTransfer; ++j) {
//                     // Retrieve the item from the transfer.
//                     TransferHelperItem calldata item = transferItems[j];

//                     if (item.itemType == ConduitItemType.ERC20) {
//                         // Ensure that the identifier of an ERC20 token is 0.
//                         if (item.identifier != 0) {
//                             revert InvalidERC20Identifier();
//                         }
//                     }

//                     // If the item is an ERC721 token and
//                     // callERC721Receiver is true...
//                     if (item.itemType == ConduitItemType.ERC721) {
//                         if (callERC721Receiver) {
//                             // Check if the recipient implements
//                             // onERC721Received for the given tokenId.
//                             // 检查接收者是否实现
//                             // onERC721Received 给定的 tokenId。
//                             _checkERC721Receiver(
//                                 conduit,
//                                 transfer.recipient,
//                                 item.identifier
//                             );
//                         }
//                     }

//                     // Create a ConduitTransfer corresponding to each
//                     // TransferHelperItem.
//                     conduitTransfers[itemIndex] = ConduitTransfer(
//                         item.itemType,
//                         item.token,
//                         msg.sender,
//                         transfer.recipient,
//                         item.identifier,
//                         item.amount
//                     );

//                     // Increment the index for storing ConduitTransfers.
//                     ++itemIndex;
//                 }
//             }
//         }

//         // Attempt the external call to transfer tokens via the derived conduit.
//         // 尝试外部调用以通过派生管道传输令牌。
//         try ConduitInterface(conduit).execute(conduitTransfers) returns (
//             bytes4 conduitMagicValue
//         ) {
//             // Check if the value returned from the external call matches
//             // the conduit `execute` selector.
//             // 检查外部调用返回的值是否匹配
//             // 管道 `execute` 选择器。
//             if (conduitMagicValue != ConduitInterface.execute.selector) {
//                 // If the external call fails, revert with the conduit key
//                 // and conduit address.
//                 // 如果外部调用失败，使用管道键恢复
//                 // 和管道地址。
//                 revert InvalidConduit(conduitKey, conduit);
//             }
//         } catch Error(string memory reason) {
//             // Catch reverts with a provided reason string and
//             // revert with the reason, conduit key and conduit address.
//             revert ConduitErrorRevertString(reason, conduitKey, conduit);
//         } catch (bytes memory data) {
//             // Conduits will throw a custom error when attempting to transfer
//             // native token item types or an ERC721 item amount other than 1.
//             // Bubble up these custom errors when encountered. Note that the
//             // conduit itself will bubble up revert reasons from transfers as
//             // well, meaning that these errors are not necessarily indicative of
//             // an issue with the item type or amount in cases where the same
//             // custom error signature is encountered during a conduit transfer.

//             // 管道在尝试传输时会抛出一个自定义错误
//             // 本机令牌项目类型或 ERC721 项目数量不是 1。
//             // 遇到这些自定义错误时冒泡。 请注意，
//             // conduit 本身会从传输中冒出 revert reasons as
//             // 嗯，这意味着这些错误不一定表示
//             // 在相同的情况下，项目类型或数量存在问题
//             // 在管道传输期间遇到自定义错误签名。

//             // Set initial value of first four bytes of revert data to the mask.
//             // 将恢复数据的前四个字节的初始值设置为掩码。
//             bytes4 customErrorSelector = bytes4(0xffffffff);

//             // Utilize assembly to read first four bytes (if present) directly.
//             // 利用汇编直接读取前四个字节（如果存在）。
//             assembly {
//                 // Combine original mask with first four bytes of revert data.
//                 // 将原始掩码与恢复数据的前四个字节组合起来。
//                 customErrorSelector := and(
//                     mload(add(data, 0x20)), // Data begins after length offset.
//                     customErrorSelector
//                 )
//             }

//             // Pass through the custom error in question if the revert data is
//             // the correct length and matches an expected custom error selector.
//             // 如果恢复数据是通过有问题的自定义错误
//             // 正确的长度并匹配预期的自定义错误选择器。
//             if (
//                 data.length == 4 &&
//                 (customErrorSelector == InvalidItemType.selector ||
//                     customErrorSelector == InvalidERC721TransferAmount.selector)
//             ) {
//                 // "Bubble up" the revert reason.
//                 assembly {
//                     revert(add(data, 0x20), 0x04)
//                 }
//             }

//             // Catch all other reverts from the external call to the conduit and
//             // include the conduit's raw revert reason as a data argument to a
//             // new custom error.
//             // 捕获所有其他从外部调用到管道的回复
//             // 将管道的原始恢复原因作为数据参数包含在
//             // 新的自定义错误。
//             revert ConduitErrorRevertBytes(data, conduitKey, conduit);
//         }
//     }

//     /**
//      * @notice An internal function to check if a recipient address implements
//      *         onERC721Received for a given tokenId. Note that this check does
//      *         not adhere to the safe transfer specification and is only meant
//      *         to provide an additional layer of assurance that the recipient
//      *         can receive the tokens — any hooks or post-transfer checks will
//      *         fail and the caller will be the transfer helper rather than the
//      *         ERC721 contract. Note that the conduit is set as the operator, as
//      *         it will be the caller once the transfer is performed.
//      *
//      * @param conduit   The conduit to provide as the operator when calling
//      *                  onERC721Received.
//      * @param recipient The ERC721 recipient on which to call onERC721Received.
//      * @param tokenId   The ERC721 tokenId of the token being transferred.
//      */

//     /**
//      * @notice 一个检查收件人地址是否实现的内部函数
//      * onERC721Received 对于给定的 tokenId。 请注意，此检查确实
//      * 不遵守安全传输规范，仅表示
//      * 为收件人提供额外的保证
//      * 可以接收代币——任何挂钩或转账后支票都会
//      * 失败，呼叫者将成为转移助手而不是
//      * ERC721 合约。 请注意，导管设置为操作员，如
//      * 转接完成后即为来电者。
//      *
//      * @param conduit 调用时作为操作员提供的管道
//      * 在ERC721上收到。
//      * @param recipient 要调用 onERC721Received 的 ERC721 接收者。
//      * @param tokenId 正在转移的代币的 ERC721 tokenId。
//      */
//     function _checkERC721Receiver(
//         address conduit,
//         address recipient,
//         uint256 tokenId
//     ) internal {
//         // Check if recipient can receive ERC721 tokens.
//         try
//             IERC721Receiver(recipient).onERC721Received(
//                 conduit,
//                 msg.sender,
//                 tokenId,
//                 ""
//             )
//         returns (bytes4 selector) {
//             // Check if onERC721Received selector is valid.
//             if (selector != IERC721Receiver.onERC721Received.selector) {
//                 // Revert if recipient cannot accept
//                 // ERC721 tokens.
//                 revert InvalidERC721Recipient(recipient);
//             }
//         } catch (bytes memory data) {
//             // "Bubble up" recipient's revert reason.
//             revert ERC721ReceiverErrorRevertBytes(
//                 data,
//                 recipient,
//                 msg.sender,
//                 tokenId
//             );
//         } catch Error(string memory reason) {
//             // "Bubble up" recipient's revert reason.
//             revert ERC721ReceiverErrorRevertString(
//                 reason,
//                 recipient,
//                 msg.sender,
//                 tokenId
//             );
//         }
//     }

//     /**
//      * @notice An internal function that reverts if the passed-in recipient
//      *         is the zero address.
//      *
//      * @param recipient The recipient on which to perform the check.
//      */
//     function _checkRecipientIsNotZeroAddress(address recipient) internal pure {
//         // Revert if the recipient is the zero address.
//         if (recipient == address(0x0)) {
//             revert RecipientCannotBeZeroAddress();
//         }
//     }
// }
