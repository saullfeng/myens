const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
    const [owner] = await ethers.getSigners()
    console.log(`owner address:${owner.address}`)

    Register = await ethers.getContractFactory("Register");
    Commit = await ethers.getContractFactory("Commit");
    commit = await Commit.attach("0x5048edfF179fF2Fd5DCF199A9b862a88b148b07B")
    // 0xEd8b647990325b34a5823426CbEF349EbFC175A1
    // 0xa2437dffB712d467316Cbe63C543171ac48013C9 goerli
    // 0xcDbFc6E9Fc0DEf908feA9330c0392ED2a60464d9

    //setbasefee
    //setgradientfee
    //setshortestlength

    let base = ethers.utils.parseEther("0")
    let premium = ethers.utils.parseEther("0")
    await commit.setfee(base, premium);

    let num1 = ethers.utils.parseEther("0.01");
    let num2 = ethers.utils.parseEther("0.05");
    let num3 = ethers.utils.parseEther("0.04");
    let num4 = ethers.utils.parseEther("0.03");
    let num5 = ethers.utils.parseEther("0.02");

    let arr = [num1, num2, num3, num4, num5];
    await commit.setGradientFee(arr);
    await commit.setShortestLength(2);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

