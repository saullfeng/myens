const { network, run } = require("hardhat")
const { BigNumber } = require("ethers");
const { expect } = require('chai');
async function main() {

    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
    const MAX_UINT256 = BigNumber.from('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');

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

    const RECEIVER_MAGIC_VALUE = '0x009ce20b';

    let firstOwner, secondOwner, newOwner, approved, valueApproved, anotherApproved, operator, slotOperator, other
    [firstOwner, secondOwner, approved, valueApproved, anotherApproved, operator, slotOperator, other] = await ethers.getSigners();
    // console.log(`Deploying contracts to ${network.name} with the account:${deployer.address}`)

    const name = 'Semi Test1 Token';
    const symbol = 'SFT';
    const decimals = 18;

    const Mint = await ethers.getContractFactory("MintFor3525");
    const mint = await Mint.deploy(name, symbol, decimals)
    await mint.deployed()
    console.log("mint address:", mint.address)

    // const mint3525 = await ethers.getContractAt(
    //     "MintFor3525",
    //     mint.address,
    //     deployer
    // );

    await mint.mint(firstOwner.address, firstTokenId, firstSlot, firstTokenValue);
    await mint.mint(secondOwner.address, secondTokenId, firstSlot, secondTokenValue);
    await mint.mint(firstOwner.address, thirdTokenId, secondSlot, thirdTokenValue);
    await mint.mint(secondOwner.address, fourthTokenId, secondSlot, fourthTokenValue);


}
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })