const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

    const [owner] = await ethers.getSigners()
    console.log(`owner address:${owner.address}`)

    Register = await ethers.getContractFactory("Register");
    register = await Register.attach("0x94d1DB3e382cfc2a12a1d7f700C989542723Eed0")
    // console.log(register)
    Commit = await hre.ethers.getContractFactory("Commit");
    commit = await Commit.attach("0x028d375386C8B128c7b310BD728C6081C7cA60A6")
    // 0xcDbFc6E9Fc0DEf908feA9330c0392ED2a60464d9
    // 0xEd8b647990325b34a5823426CbEF349EbFC175A1
    const name = "f12eq"

    const res = await register['register(uint256,address,uint256)'](258846353982310, owner.address, 1)
    console.log(res)


    // commitment = await commit.makeCommitment(
    //     name,
    //     owner.address,
    //     1,
    //     1,
    //     "bn"
    // )
    // await commit.commit(commitment)

    // await sleep(5000)

    // await commit.register(
    //     name,
    //     owner.address,
    //     1,
    //     1,
    //     "bn",
    //     { value: ethers.utils.parseEther("0.1") }
    // )

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

