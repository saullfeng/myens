const { network, run } = require("hardhat")
const { BigNumber } = require("ethers");
const { expect } = require('chai');
const hre = require("hardhat");
async function main() {
    const firstSlot = 11;
    const secondSlot = 22;
    const nonExistentSlot = 99;

    const firstTokenId = 1001;
    const secondTokenId = 1002;
    const thirdTokenId = 2001;
    const fourthTokenId = 2002;
    const nonExistentTokenId = 9901;

    const firstTokenValue = 1000000;
    const secondTokenValue = 2000000;
    const thirdTokenValue = 3000000;
    const fourthTokenValue = 4000000;

    let firstOwner, secondOwner, newOwner, approved, valueApproved, anotherApproved, operator, slotOperator, other
    [firstOwner, secondOwner, approved, valueApproved, anotherApproved, operator, slotOperator, other] = await ethers.getSigners();
    ERC3525 = await ethers.getContractFactory("MintFor3525");
    erc3525 = await ERC3525.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3")


    //     for (uint256 i = 0; i < length; i++) {
    //         uint256 tokenId = ERC3525.tokenOfOwnerByIndex(owner_, i);
    //  //   tokenIds[i] = tokenId;
    //         uint256 value = ERC3525.balanceOf(tokenId);
    //         tokenValue[i] = value;
    //     }
    // }
    const length = await erc3525.connect(valueApproved.address)['balanceOf(address)'](valueApproved.address)
    const lengths = length.toString() - 0
    let map = new Map();
    let values = []
    for (let index = 0; index < lengths; index++) {

        const tokenId = await erc3525.connect(valueApproved)['tokenOfOwnerByIndex(address,uint256)'](valueApproved.address, index);
        const tokenIds = tokenId.toString() - 0
        // await sleep(5000)
        const value = await erc3525.connect(valueApproved)['balanceOf(uint256)'](tokenIds);
        map.set(tokenIds, value.toString() - 0)
    }
    console.log(map)




}
function sleep(millisecond) {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve()
        }, millisecond)
    })
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
