// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./eth-registry/Register.sol";
import "./eth-registry/Commit.sol";

contract MerkleClaimERC721 is Ownable {
    using ECDSA for bytes32;

    uint256 public constant MINT_PRICE = 0.1 ether;
    bytes32 private _whitelistMerkleRoot;
    bytes32 private _codelistMerkleRoot;
    mapping(address => bool) public WhiteListClaimed;
    mapping(string => bool) public CodeListClaimed;
    mapping(address => bool) public FreeClaimed;
    Register public register;
    address[] firstComeFirstServed;

    bool public whiteMinted;
    bool public minted;

    event FreeClaim(address indexed to, uint256 amount);

    event Code(
        address indexed to,
        uint256 indexed time,
        string code,
        string name,
        string suffix
    );

    constructor(Register _register) {
        whiteMinted = true;
        minted = true;
        register = _register;
    }

    function freemintOpened() public onlyOwner {
        minted = true;
    }

    function freemintClosed() public onlyOwner {
        minted = false;
    }

    function whiteOpened() public onlyOwner {
        whiteMinted = true;
    }

    function whiteClosed() public onlyOwner {
        whiteMinted = false;
    }

    modifier onlyWhiteMinted() {
        require(whiteMinted, "Contract currently paused");
        _;
    }

    modifier onlyFreeMint() {
        require(minted, "mint currently paused");
        _;
    }

    modifier isValidMerkleProof(
        bytes32[] calldata _merkleProof,
        bytes32 _root,
        address _leaf
    ) {
        require(
            MerkleProof.verify(
                _merkleProof,
                _root,
                keccak256(abi.encodePacked(_leaf))
            ),
            "Address does not exist in list"
        );
        _;
    }

    function whitelistSale(
        bytes32[] calldata proof,
        string calldata name,
        string calldata suffix,
        address to,
        uint256 duration
    )
        public
        onlyWhiteMinted
        returns (
            // uint256 secret,
            uint256 Mregister
        )
    {
        // merkle tree list related
        require(_whitelistMerkleRoot != "", "Free Claim merkle tree not set");
        require(
            WhiteListClaimed[to] != true,
            "Free Claim merkle tree , you have received"
        );
        bytes32 id = labelName(name, suffix);
        Mregister = register.register(
            proof,
            _whitelistMerkleRoot,
            uint256(id),
            to,
            uint256(duration)
        );
        WhiteListClaimed[to] = true;
    }

    function codeWhitelistSale(
        bytes32[] calldata proof,
        string calldata name,
        string calldata code,
        string calldata suffix,
        uint256 duration
    )
        public
        onlyWhiteMinted
        returns (
            // uint256 secret,
            uint256 Mregister
        )
    {
        // merkle tree list related
        require(_codelistMerkleRoot != "", "Free Claim merkle tree not set");
        // require(
        //     CodeListClaimed[code] != true,
        //     "code Free Claim merkle tree , you have received"
        // );
        bytes32 id = labelName(name, suffix);
        Mregister = register.codeRegister(
            proof,
            _codelistMerkleRoot,
            uint256(id),
            msg.sender,
            uint256(duration),
            code
        );
        // CodeListClaimed[code] = true;
        emit Code(msg.sender, block.timestamp, code, name, suffix);
    }

    function freeNumber(
        // string calldata name,
        string calldata suffix,
        address to,
        uint256 duration
    )
        public
        onlyFreeMint
        returns (
            // uint256 secret,
            string memory name
        )
    {
        // merkle tree list related
        require(
            FreeClaimed[to] != true,
            " free mint table ,you have already claimed once "
        );
        uint256 num = firstComeFirstServed.length;
        name = Strings.toString(num);
        bytes32 id = labelName(name, suffix);
        uint256 Mregister = register.register(
            uint256(id),
            to,
            uint256(duration),
            num
        );
        firstComeFirstServed.push(to);
        FreeClaimed[to] = true;
        emit FreeClaim(to, Mregister);
    }

    function setWhitelistMerkleRoot(bytes32 newMerkleRoot_) external onlyOwner {
        _whitelistMerkleRoot = newMerkleRoot_;
    }

    function setCodeWhitelistMerkleRoot(bytes32 newMerkleRoot_)
        external
        onlyOwner
    {
        _codelistMerkleRoot = newMerkleRoot_;
    }

    function getMerkleRoot() external view onlyOwner returns (bytes32) {
        return _whitelistMerkleRoot;
    }

    function getabiKeccak256(string calldata to, uint256 amount)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(to, amount));
    }

    function getVerifyWhite(address whiteAddress) public view returns (bool) {
        return WhiteListClaimed[whiteAddress];
    }

    function getVerifyFreeClaimed(address _Address) public view returns (bool) {
        return FreeClaimed[_Address];
    }

    //慎重
    function UpdateFreeClaimed(address whiteAddress) public {
        FreeClaimed[whiteAddress] = false;
    }

    //慎重
    function UpdateVerifyWhite(address whiteAddress) public {
        WhiteListClaimed[whiteAddress] = false;
    }

    function sendViaSend(address payable _to) public payable {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function isMTExist(bytes32 id) public view returns (bool) {
        return register.isExist(uint256(id));
    }

    function labelName(string memory name, string calldata suffix)
        public
        pure
        returns (bytes32 label)
    {
        string memory tmp = string.concat(name, ".", suffix);
        label = keccak256(bytes(tmp));
    }

    function getFirstComeFirstServedLength() public view returns (uint256) {
        return firstComeFirstServed.length;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
