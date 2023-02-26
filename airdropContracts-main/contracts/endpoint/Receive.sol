//  SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "../lzApp/NonblockingLzApp.sol";

/// @title A LayerZero example sending a cross chain message from a source chain to a destination chain to increment a counter
contract Receive is NonblockingLzApp {
    
    uint8 public constant RECEIVE_FROM_APTOS = 18;
    event ReceiveMsg(uint16 _srcChainId, address _from, bytes _payload);

    uint256 public counter;

    bytes32 public a;
    address public b;
    uint64 public c;
    uint8 public typed;

    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {}

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64,
        bytes memory _payload
    ) internal override {
        address from;
        assembly {
            from := mload(add(_srcAddress, 20))
        }
        (address owner, uint64 duration, bytes32 name) = _decodeReceivePayload(
            _payload
        );
        a = name;
        b = owner;
        c = duration;
        emit ReceiveMsg(_srcChainId, from, _payload);
    }

    function _decodeReceivePayload(bytes memory _payload)
        internal
        returns (

            address owner,
            uint64 duration,
            bytes32 name
        )
    {
        uint8 receiveType = uint8(_payload[0]);
        typed = receiveType;
        assembly {
            owner := mload(add(_payload, 33))
            name := mload(add(_payload, 66))
            duration := mload(add(_payload, 74))
        }
    }

}
