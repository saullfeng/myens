import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IGen721 is IERC721 {

    function register(
        uint,
        address,
        uint
    ) external;

    function readWhiteList(address) external view;

    function isExist(uint) external view returns (bool);

    function getDuration(uint) external view returns(uint);
}
