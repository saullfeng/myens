//  SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.16 <0.9.0;


import "../lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../Interface/ILayerZeroEndpoint.sol";
import "../Interface/ILayerZeroReceiver.sol";
import "../Interface/IDeposit.sol";
import "../Interface/IRegister.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../lib/Bytes32Utils.sol";

contract AdminInEth_APT is Ownable, ILayerZeroReceiver {
    using Bytes32Utils for bytes32;

    uint256 MAX = 100;
    uint256 gas = 350000;
    ILayerZeroEndpoint public endpoint;
    IRegister public base;
    address private deposit;
    uint public message_receive = 0;
    uint public b = 0;
    uint public message_send = 0;
    bytes public tmp_bytes;
    string public tmp_string;

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

    constructor(address _endpoint, address _base) {
        endpoint = ILayerZeroEndpoint(_endpoint);
        base = IRegister(_base);
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

    function setdepositAddress(address _deposit) external onlyOwner {
        deposit = _deposit;
    }

    function crossChain(
        uint16 _dstChainId,
        bytes calldata _destination,
        uint256 label
    ) public payable {
        require(msg.sender == base.ownerOf(label), "Not the owner");
        address owner = msg.sender;
        base.transferFrom(msg.sender, deposit, label);
        IDeposit(deposit).deposit(label);
        bytes memory payload = abi.encode(
            owner,
            label,
            base.checkExpire(label),
            base.getNameByHash(label)
        );


        // encode adapterParams to specify more gas for the destination
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
        require(msg.sender == address(endpoint)); // boilerplate! lzReceive must be called by the endpoint for security

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

        (address owner, uint64 duration, bytes32 name) = _decodeReceivePayload(
            _payload
        );



        // tmp_bytes = name.bytes32ToBytes();
        // tmp_string = string(tmp_bytes);
        //bytes32 label = keccak256(bytes(tmp_string));

        bytes32 label = keccak256(name.bytes32ToBytes());

        //base.expire[token] = expiration

        //isExist 判断是否是0地址，跨过去后存在deposit地址
        if (base.isExist(uint256(label))){
           IDeposit(deposit).withdraw(uint256(label), owner);
        } else {
            base.register(uint256(label), owner, uint256(duration));
        }
        
        message_receive++;
        emit ReceiveMsg(_srcChainId, from, _payload);
    }


    function _decodeReceivePayload(bytes memory _payload)
        internal
        pure
        returns (
            address owner,
            uint64 duration,
            bytes32 name
        )
    {
        //uint8 receiveType = uint8(_payload[0]);
        //typed = receiveType;
        assembly {
            owner := mload(add(_payload, 33))
            name := mload(add(_payload, 66))
            duration := mload(add(_payload, 74))
        }
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

    // test
    address public test_owner;
    uint256 public test_label;
    uint public test_existence;

    function checkLabel(string calldata name)
        public
        pure
        returns (uint256 label)
    {
        label = uint256(keccak256(bytes(name)));
    }

    function checkfee(uint16 _dstChainId, string calldata name)
        public
        view
        returns (uint256)
    {
        uint256 label = checkLabel(name);
        bytes memory payload = abi.encode(msg.sender, label);


        // encode adapterParams to specify more gas for the destination
        uint16 version = 1;
        bytes memory adapterParams = abi.encodePacked(version, gas);

        (uint256 messageFee, ) = endpoint.estimateFees(
            _dstChainId,
            address(this),
            payload,
            false,
            adapterParams
        );
        return messageFee;
    }

    function checkdepositAddress() public view returns (address) {
        return deposit;
    }

    function check_label(string calldata name) public pure returns (uint256) {
        return uint256(keccak256(bytes(name)));
    }

    function check_msg() public view returns (uint, uint) {
        return (message_send, message_receive);
    }

}
