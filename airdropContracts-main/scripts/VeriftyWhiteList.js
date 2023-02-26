const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

    Merkle = await ethers.getContractFactory("MerkleClaimERC721");
    merkle = await Merkle.attach("0xFF375535e20058D7ACa115a567c48Ef2C13A1AC9")

    const to = "0x65b5cBeF0b61b099F783a6aE899436CD3B49d55a"
    const res = await merkle.getVerifyWhite(to)
    console.log(res)

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
