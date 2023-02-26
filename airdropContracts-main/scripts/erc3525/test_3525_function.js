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
    erc3525 = await ERC3525.attach("0x5FC8d32690cc91D4c39d9d3abcBD16989F875707")
    // console.log(erc3525)
    // const balanceOf = await erc3525['balanceOf(uint256)'](1001)
    // console.log(balanceOf)
    //批准
    // await erc3525.connect(firstOwner)['approve(uint256,address,uint256)'](firstOwner, valueApproved.address, firstTokenValue);
    //拆分
    // for (let index = 0; index < 2; index++) {
    //     await erc3525.connect(firstOwner)['transferFrom(uint256,address,uint256)'](firstTokenId, valueApproved.address, 1001 + index);
    // }


    // const allowances = await erc3525.allowance(secondTokenId, valueApproved.address);
    // console.log(allowances)
    // const balanceOf1 = await erc3525.connect(valueApproved)['balanceOf(address)'](valueApproved.address)
    // console.log(balanceOf1)
    //合并
    // await erc3525.connect(valueApproved)['transferFrom(uint256,uint256,uint256)'](2, 3, 1)

    // const balanceOf2 = await erc3525.connect(valueApproved.address)['balanceOf(uint256)'](0)
    // const balanceOf3 = await erc3525.connect(valueApproved.address)['balanceOf(uint256)'](2)
    // console.log(balanceOf2)
    // console.log(balanceOf3)

    //_burn 
    await erc3525.connect(valueApproved)['burn(uint256)'](3)


}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
