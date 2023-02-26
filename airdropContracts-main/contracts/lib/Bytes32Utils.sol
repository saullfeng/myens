// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

library Bytes32Utils {
    function bytes32ToBytes(bytes32 input) internal pure returns (bytes memory) {
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), input) // set the bytes data
        }
        return b;
    }
}
