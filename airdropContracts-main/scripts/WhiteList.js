const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

    Merkle = await ethers.getContractFactory("MerkleClaimERC721");
    merkle = await Merkle.attach("0xfc9Ff2A2DA3c0aF51148847df853a93E2CE9c254 ")

    const to = "0x65b5cBeF0b61b099F783a6aE899436CD3B49d55a"
    const proof = ["0x96d5dcb50c47b261befc3e7cfb5a9d4b2e12a85ac5d6d94354333e59be5c18f9", "0x87cfe090d543278f7a5e8b5f037c0d0d824f3cb6a5957579047c9772f197ec89", "0x02714b591309b94969b2ee3aceab29d2072110087dfe5f1af5ebe16b6d8e6e9d", "0x2e121cdc42d8bb5c71d48b5702cf09a55371ce1ebeeecc3e3d0b4026b4896cb0", "0xacced903d2f1be4e3d65fa66e2f557d1edb51cb2e121e4629fbff23b0bbc0e2b", "0xd001f0f094ebbc756ea143ab02e362a00f44c2632953eb2617492ddbffd2f77e", "0x64a890ccfc51ab34961931be61a96f14447d4dd77dec141e6620b67af2acb7c7", "0xd1827e386995b79b2373aa33a63352850eb74d9bda5cf6bc9ec7d28a9b41cb45", "0x62ba0ac49dff436ac398a7c48fcca04ef2f2698d789bb3d27d835d5f998f1e17"]
    // const commitCon = "0x31eE7087b10071D2ac76391c65bBDD08BB7345bA"
    const name = "q22a"
    const duration = 1
    const secret = 1
    const suffix = "bn"

    const res = await merkle.whitelistSale(
        proof,
        name,
        suffix,
        to,
        duration
        // secret
    )
    console.log(res)

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
