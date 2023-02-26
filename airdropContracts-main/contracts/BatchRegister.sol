// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;
import "./eth-registry/Register.sol";
import "./eth-registry/Commit.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BatchRegister {
    Register public register;
    uint256 _value;

    constructor(Register _register) {
        register = _register;
    }

    function current() internal view returns (uint256) {
        return _value;
    }

    function increment() internal {
        unchecked {
            _value += 1;
        }
    }

    function BatchNumber(
        string calldata suffix,
        address[] calldata to,
        uint256 duration
    ) public {
        // merkle tree list related
        for (uint256 i = 0; i < to.length; i++) {
            // uint256 num = clock.current();
            bytes32 id = labelName(Strings.toString(_value), suffix);
            // bytes32 id = labelName(Strings.toString(i), suffix);
            register.Batchregister(uint256(id), to[i], uint256(duration));
            increment();
        }
    }

    // function brushNumber(
    //     string calldata name,
    //     string calldata suffix,
    //     address to,
    //     uint256 duration
    // ) public {
    //     // merkle tree list related

    //     // uint256 num = clock.current();
    //     bytes32 id = labelName(name, suffix);
    //     // bytes32 id = labelName(Strings.toString(i), suffix);
    //     register.Batchregister(uint256(id), to, uint256(duration));
    // }

    function labelName(string memory name, string calldata suffix)
        public
        pure
        returns (bytes32 label)
    {
        string memory tmp = string.concat(name, ".", suffix);
        label = keccak256(bytes(tmp));
    }
}
