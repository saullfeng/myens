//  SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.16 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Register.sol";
// import "hardhat/console.sol";
import "../lib/StringUtils.sol";

contract Commit is Ownable {
    using StringUtils for *;
    struct Price {
        uint256 base; //基础
        uint256 premium; //额外费用
    }
    //最短注册时间
    uint256 public constant MIN_REGISTRATION_DURATION = 1 seconds;
    uint256 public immutable minCommitmentAge; //1
    uint256 public immutable maxCommitmentAge; //10000
    uint256 public shortest_length;
    uint256[20] public gradient_fee; //梯度_费
    Register public immutable base;
    Price public price;

    mapping(bytes32 => uint256) public commitments;

    event NameRegistered(
        string name,
        bytes32 indexed label,
        address indexed owner,
        uint256 expires,
        string suffix
    );
    event NameRenewed(string name, bytes32 indexed label, uint256 expires);

    constructor(
        uint256 _minCommitmentAge,
        uint256 _maxCommitmentAge,
        uint256 baseprice,
        uint256 premiumprice,
        Register _base
    ) {
        require(_maxCommitmentAge > _minCommitmentAge);
        minCommitmentAge = _minCommitmentAge; //60
        maxCommitmentAge = _maxCommitmentAge;

        require(baseprice > 0 && premiumprice > 0);
        price.base = baseprice;
        price.premium = premiumprice;
        base = _base;
    }

    function withdraw() public {
        payable(owner()).transfer(address(this).balance);
    }

    function setfee(uint256 baseprice, uint256 premiumprice) public onlyOwner {
        price.base = baseprice;
        price.premium = premiumprice;
    }

    function setShortestLength(uint256 length) public onlyOwner {
        shortest_length = length;
    }

    function setGradientFee(uint256[] memory arr) public onlyOwner {
        for (uint256 i = 0; i < arr.length; i++) {
            gradient_fee[i] = arr[i];
        }
    }

    function getGradientFee() public view returns (uint256[20] memory) {
        return gradient_fee;
    }

    function getShortestLength() public view returns (uint256) {
        return shortest_length;
    }

    function register(
        string calldata name,
        address owner,
        uint256 duration, //year
        uint256 secret,
        string calldata suffix
    ) external payable returns (uint256) {
        uint256 prefix_length = name.strlen();
        require(
            prefix_length >= shortest_length,
            "It's out of the shortest length range"
        );

        if (name.isPureNumber()) {
            uint256 nameForNumber = name.stringToUint();
            if (nameForNumber < 10000) {
                revert(
                    "The name with the number less than 10000 are not allowed"
                );
            } else {
                return _register(name, owner, duration, secret, suffix);
            }
        } else {
            return _register(name, owner, duration, secret, suffix);
        }
    }

    function _register(
        string calldata name,
        address owner,
        uint256 duration, //year
        uint256 secret,
        string calldata suffix
    ) public payable returns (uint256) {
        bytes32 label = keccak256(bytes(string.concat(name, ".", suffix)));
        uint256 fee;
        uint256 prefix_length = name.strlen();
        if (gradient_fee[prefix_length] == 0) {
            fee = gradient_fee[0];
        } else {
            fee = gradient_fee[prefix_length];
        }

        require(
            msg.value >= (price.base + fee * duration),
            " Not enough funds to provide "
        );

        bytes32 commitment = makeCommitment(
            name,
            owner,
            duration,
            secret,
            suffix
        );
        _consumeCommitment(name, duration, commitment, suffix);

        uint256 expires = base.register(
            uint256(label),
            owner,
            //uint(duration * 31536000)
            uint256(duration)
        );

        uint256 product = fee * duration;

        if (msg.value >= (price.base + product)) {
            payable(msg.sender).transfer(
                msg.value - (price.base + fee * duration)
            );
        }

        return expires;
    }

    function renew(
        string calldata name,
        uint256 duration,
        string calldata suffix
    ) external payable returns (uint256) {
        uint256 fee;
        uint256 prefix_length = bytes(name).length;

        string memory tmp = string.concat(name, ".", suffix);
        bytes32 label = keccak256(bytes(tmp));
        require(
            msg.value >= price.base,
            "ETHController: Not enough Ether provided for renewal"
        );

        uint256 expires = base.renew(uint256(label), duration * 31536000);

        if (gradient_fee[prefix_length] == 0) {
            fee = gradient_fee[0];
        } else {
            fee = gradient_fee[prefix_length];
        }

        if (msg.value >= price.base + fee * duration) {
            payable(msg.sender).transfer(
                msg.value - (price.base + fee * duration)
            );
        }
        emit NameRenewed(name, label, expires);

        return expires;
    }

    function commit(bytes32 commitment) public {
        require(
            commitments[commitment] + maxCommitmentAge < block.timestamp,
            "This commitment has not expired"
        ); //只有超过最大时间才能重新更新
        commitments[commitment] = block.timestamp;
    }

    function makeCommitment(
        string calldata name,
        address owner,
        uint256 duration,
        uint256 secret,
        string calldata suffix
    ) public view returns (bytes32) {
        string memory tmp = string.concat(name, ".", suffix);
        bytes32 label = keccak256(bytes(tmp));
        require(
            name_available(name, suffix),
            "This name has been already exist"
        );
        return keccak256(abi.encode(label, owner, duration, secret));
    }

    function name_available(string memory name, string memory suffix)
        public
        view
        returns (bool)
    {
        string memory tmp = string.concat(name, ".", suffix);
        bytes32 label = keccak256(bytes(tmp));
        return
            base.available(uint256(label)) &&
            bytes(name).length >= shortest_length;
    }

    function check_commit_time(bytes32 commitment)
        public
        view
        returns (uint256)
    {
        return commitments[commitment];
    }

    function check_lable(string calldata name) public pure returns (uint256) {
        return uint256(keccak256(bytes(name)));
    }

    function _consumeCommitment(
        string memory name,
        uint256 duration,
        bytes32 commitment,
        string memory suffix
    ) internal {
        require(
            commitments[commitment] + minCommitmentAge <= block.timestamp,
            "Commitment is not valid, Please wait!"
        );
        require(
            commitments[commitment] + maxCommitmentAge > block.timestamp,
            "Commitment has expired,Please commit again!"
        );
        require(name_available(name, suffix), "Name is unavailable");

        delete (commitments[commitment]);

        require(duration >= MIN_REGISTRATION_DURATION);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
