//  SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../Interface/ILayerZeroEndpoint.sol";
import "../Interface/ILayerZeroReceiver.sol";
import "./IGen721.sol";
import "../Interface/IDeposit.sol";

contract Admin is Ownable, ILayerZeroReceiver {
    uint256 MAX = 100;
    uint256 gas = 350000;
    ILayerZeroEndpoint public endpoint;
    IGen721 public gen721;
    IDeposit public deposit;
    uint public message_receive = 0;
    uint public message_send = 0;

    mapping(uint16 => mapping(bytes => mapping(uint => FailedMessages)))
    public failedMessages;
    mapping(uint16 => bytes) public trustedRemoteLookup;

    struct FailedMessages {
        uint payloadLength;
        bytes32 payloadHash;
    }

    event MessageFailed(
        uint16 _srcChainId,
        bytes _srcAddress,
        uint64 _nonce,
        bytes _payload
    );

    event ReceiveMsg(uint16 _srcChainId, address _from, bytes _payload);

    constructor(
        address _endpoint,
        address _gen721,
        address _deposit
    ) {
        endpoint = ILayerZeroEndpoint(_endpoint);
        gen721 = IGen721(_gen721);
        deposit = IDeposit(_deposit);
    }

    function setgas(uint newVal) external onlyOwner {
        gas = newVal;
    }

    function setTrustedRemote(uint16 _chainId, bytes calldata _trustedRemote)
        external
        onlyOwner
    {
        trustedRemoteLookup[_chainId] = _trustedRemote;
    }

    function crossChain(uint16 _dstChainId, bytes calldata _destination,uint label)
        public
        payable
    {

        bytes memory payload = abi.encode(msg.sender,label);
        require(gen721.ownerOf(label) == msg.sender,"The domain is not your asset");
        // encode adapterParams to specify more gas for the destination

        gen721.transferFrom(msg.sender,address(deposit),label);
        deposit.deposit(label);

        uint16 version = 1;
        bytes memory adapterParams = abi.encodePacked(version, gas);

        (uint256 messageFee, ) = endpoint.estimateFees(
            _dstChainId,
            address(this),
            payload,
            false,
            adapterParams
        );
        require(
            msg.value >= messageFee,
            "Must send enough value to cover messageFee"
        );

        endpoint.send{value: msg.value}(
            _dstChainId,
            _destination,
            payload,
            payable(msg.sender),
            address(0x0),
            adapterParams
        );
        message_send++;
    }

    function lzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) external override {
        require(msg.sender == address(endpoint)); 
        
        try this.onLzReceive(_srcChainId, _srcAddress, _nonce, _payload) {
            // do nothing
        } catch {
            // error / exception
            failedMessages[_srcChainId][_srcAddress][_nonce] = FailedMessages(
                _payload.length,
                keccak256(_payload)
            );
            emit MessageFailed(_srcChainId, _srcAddress, _nonce, _payload);
        }
    }

    function onLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) public {
        // only internal transaction
        require(
            msg.sender == address(this),
            "NonblockingReceiver: caller must be Bridge."
        );

        // handle incoming message
        _LzReceive(_srcChainId, _srcAddress, _nonce, _payload);
    }

    function _LzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64,
        bytes memory _payload
    ) internal {
        address from;
        assembly {
            from := mload(add(_srcAddress, 20))
        }

        (address owner, uint256 label, uint256 duration) = abi.decode(
            _payload,
            (address, uint256, uint256)
        );

        if (gen721.isExist(label) == false) {
            gen721.register(label, owner, duration);
        } else {
            deposit.withdraw(label, owner);
        }

        message_receive++;
        emit ReceiveMsg(_srcChainId, from, _payload);
    }

    function readmsg() public view returns (uint, uint) {
        return (message_send, message_receive);
    }

    // Endpoint.sol estimateFees() returns the fees for the message
    function estimateFees(
        uint16 _dstChainId,
        address _userApplication,
        bytes calldata _payload,
        bool _payInZRO,
        bytes calldata _adapterParams
    ) external view returns (uint256 nativeFee, uint256 zroFee) {
        return
            endpoint.estimateFees(
                _dstChainId,
                _userApplication,
                _payload,
                _payInZRO,
                _adapterParams
            );
    }

    function retryMessage(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes calldata _payload
    ) external payable {
        // assert there is message to retry
        FailedMessages storage failedMsg = failedMessages[_srcChainId][
            _srcAddress
        ][_nonce];
        require(
            failedMsg.payloadHash != bytes32(0),
            "NonblockingReceiver: no stored message"
        );
        require(
            _payload.length == failedMsg.payloadLength &&
                keccak256(_payload) == failedMsg.payloadHash,
            "LayerZero: invalid payload"
        );
        // clear the stored message
        failedMsg.payloadLength = 0;
        failedMsg.payloadHash = bytes32(0);
        // execute the message. revert if it fails again
        this.onLzReceive(_srcChainId, _srcAddress, _nonce, _payload);
    }

}
