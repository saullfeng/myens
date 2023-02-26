//  SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../Interface/ILayerZeroEndpoint.sol";
import "../Interface/ILayerZeroReceiver.sol";

contract cross123 is Ownable, ILayerZeroReceiver{
    ILayerZeroEndpoint public endpoint;
    uint public message_receive = 0;
    uint public message_send = 0;
    uint gas = 350000;
    uint public tmp;

    event ReceiveMsg(
        uint16 _srcChainId,
        address _from,
        bytes _payload,
        uint _msg
    );

    constructor(
        address _endpoint
    )  {
        endpoint = ILayerZeroEndpoint(_endpoint);
    }

    function crossChain(
        uint16 _dstChainId,
        bytes calldata _destination
    ) public payable {
        uint256 i = 1;
        //bytes memory payload = abi.encode(i,'hn','ok');
        bytes memory payload = abi.encode(i);

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

    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) external override {
        require(msg.sender == address(endpoint)); 
        try this.onLzReceive(_srcChainId, _srcAddress, _nonce, _payload) {
            // do nothing
        } catch {
        }
    }


    function onLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) public {
        // only internal transaction
        require(msg.sender == address(this), "NonblockingReceiver: caller must be Bridge.");

        // handle incoming message
        _LzReceive( _srcChainId, _srcAddress, _nonce, _payload);
    }


    function _LzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 , bytes memory _payload)  internal{

        address from;
        assembly {
            from := mload(add(_srcAddress, 20))
        }
        (uint256 i) = abi.decode(
            _payload,
            (uint256)
        );

        tmp = i;
        message_receive++;
        emit ReceiveMsg(_srcChainId, from, _payload,i);
    }

    function readmsg() public view returns(uint,uint,uint){
        return(message_send,message_receive,tmp);
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
}
