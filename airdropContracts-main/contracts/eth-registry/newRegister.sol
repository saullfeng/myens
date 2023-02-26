//  SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.16 <0.9.0;

import "./NodeController.sol";
import "./Resolver.sol";
import "../Interface/IRegister.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//1.ans账户==true 可以转账 开关
//2.map 0000 1111 only eth
//3.endpoint

contract newRegister is IRegister, ERC721, Ownable {
    uint256 public constant GRACE_PERIOD = 28 days; //缓冲期
    address public defaultResolver;
    bytes32 private constant ETH_NODE =
        0x24bb3ee1d13e66ad83f7d8f92faad2f685c75a758f36e5c579c522e29aef77e0;
    NodeController public nodecontroller;

    //mapping(string => bytes32) nodes;
    mapping(uint256 => string) public tokenNames;
    mapping(uint256 => uint256) expires;
    mapping(address => bool) public controllers;
    mapping(address => mapping(uint256 => bool)) private depositlist;

    //to do nft名字没设置

    constructor(NodeController _nodecontroller) ERC721("star", "move") {
        nodecontroller = _nodecontroller;
    }

    modifier onlyController() {
        require(controllers[msg.sender], "onlyController is fail");
        _;
    }

    modifier live() {
        //require(nodecontroller.ownerOfNode(nodes[suffix]) == address(this));
        require(
            nodecontroller.ownerOfNode(ETH_NODE) == address(this),
            "live is fail"
        );
        _;
    }

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external override onlyOwner {
        controllers[controller] = true;
    }

    // Revoke controller permission for an address.
    function removeController(address controller) external override onlyOwner {
        controllers[controller] = false;
    }

    function setdefaultResolver(address _defaultResolver) external onlyOwner {
        defaultResolver = _defaultResolver;
    }

    // function createNewNode(string memory suffix) public{
    //     bytes32 node_hash =  nodecontroller.getNode(suffix);
    //     nodes[suffix] = nodecontroller.makeNode(0x0, node_hash);
    // }

    function register(
        uint256 id,
        address owner,
        uint256 duration //注册持续时间
    )
        external
        override
        returns (
            //string memory name
            uint256
        )
    {
        return _register(id, owner, duration);
    }

    function _register(
        uint256 id,
        address owner,
        uint256 duration
    )
        internal
        //string memory name
        onlyController
        live
        returns (uint256)
    {
        require(available(id), "id is fail");
        require(
            block.timestamp + duration + GRACE_PERIOD >
                block.timestamp + GRACE_PERIOD,
            "time is fail"
        ); //防止溢出

        expires[id] = block.timestamp + duration;
        if (_exists(id)) {
            _burn(id);
        }

        _safeMint(owner, id);
        nodecontroller.set2LDrecord(
            ETH_NODE,
            //nodes[suffix],
            bytes32(id),
            owner,
            address(defaultResolver)
        );
        //tokenNames[id] = name;

        return block.timestamp + duration;
    }

    function isExist(uint256 id) public view returns (bool) {
        return _exists(id);
    }

    function getNameByHash(uint256 label) public view returns (string memory) {
        return tokenNames[label];
    }

    function renew(uint256 id, uint256 duration)
        external
        override
        returns (uint256)
    {
        return _renew(id, duration);
    }

    function available(uint256 id) public view override returns (bool) {
        return (expires[id] + GRACE_PERIOD < block.timestamp);
    }

    function checkExpire(uint256 id) public view override returns (uint256) {
        return expires[id];
    }

    function _renew(uint256 id, uint256 duration)
        internal
        onlyController
        live
        returns (uint256)
    {
        require(expires[id] + GRACE_PERIOD >= block.timestamp); // 在缓冲期内
        require(
            expires[id] + duration + GRACE_PERIOD > duration + GRACE_PERIOD
        ); // 防止溢出

        expires[id] += duration;
        return expires[id];
    }

    function reclaim(uint256 id, address owner) external override live {
        require(_isApprovedOrOwner(msg.sender, id));
        nodecontroller.set2LDowner(ETH_NODE, bytes32(id), owner);
    }

    function makeNode(string calldata name) public pure returns (bytes32) {
        bytes32 label = keccak256(bytes(name));

        return keccak256(abi.encodePacked(ETH_NODE, label));
    }

    // function deposit(address owner, uint256 id) external override{
    //     require(!available(id) && _isApprovedOrOwner(owner, id));//必须在期限内 且是所有者
    //     _deposit(owner,id);
    // }

    // function withdraw(address owner, uint256 id) external override{
    //     require(!available(id) && depositlist[owner][id]);//必须在期限内  且被所有者贮藏
    //     _withdraw(owner,id);
    // }

    // function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
    //     address owner = ownerOf(tokenId);
    //     return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    // }

    // function _withdraw(address owner, uint256 id) internal onlyController{
    //     depositlist[owner][id] = false;
    //     _mint(owner, id);
    // }

    // function _deposit(address owner, uint256 id) internal onlyController{
    //     depositlist[owner][id] = true;
    //     _burn(id);
    // }

    //test
    function checkdefaultResolver() public view returns (address) {
        return defaultResolver;
    }

    function checkduration(uint256 label) public view returns (uint256) {
        return expires[label] - block.timestamp;
    }

    function check_node(string calldata name) public pure returns (bytes32) {
        uint256 label = uint256(keccak256(bytes(name)));
        return keccak256(abi.encodePacked(ETH_NODE, bytes32(label)));
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
