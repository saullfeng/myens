const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

    const [owner] = await ethers.getSigners()
    console.log("owner address", owner.address)

    Register = await ethers.getContractFactory("Register");
    register = await Register.attach("0x94d1DB3e382cfc2a12a1d7f700C989542723Eed0")
    await register.setNumber(100)

    // Commit = await hre.ethers.getContractFactory("Commit");
    // commit = await Commit.attach("0xEd8b647990325b34a5823426CbEF349EbFC175A1")

    const contactName = "MerkleClaimERC721"
    const merkleTree = await ethers.getContractFactory(contactName);
    // test ac789016e4f90469a4318488d7d1bf3f30d81fe68d683f686e8aea63d2a2fafc
    //0x0625dbc951f206e10785e66d827193ef74c74f0be36302e5fd3fb191dc6e8105
    // const merkleDeploy = await merkleTree.deploy("0x338513aC83aF41aCDe4F19B2D4b0c1511e7C9F3F")
    // await merkleDeploy.deployed()
    // console.log("merkleTreeERC721 address:", merkleDeploy.address)

    const merkle = await ethers.getContractAt(
        contactName,
        // "0x244150397d670708B9FB858391D1285769A356B8",
        // merkleDeploy.address,
        "0x2df911bf911214f80fd26939a14725be16549552",
        owner
    );
    // await merkle.setNumber(100)

    // await merkle.setWhitelistMerkleRoot("0x0625dbc951f206e10785e66d827193ef74c74f0be36302e5fd3fb191dc6e8105")
    const to = "0x65b5cBeF0b61b099F783a6aE899436CD3B49d55a"
    const proof = [
        '0x21fefa039509912461913e605492c200064de3acb34837360096b83edb4a0a33',
        '0xf3d9602ef24355278a6bcdb3bb16a0eebbdcb17523763a3805bd11a21f3f1953',
        '0x5bb6246edc54f52c3e040be4b7012734c0bb7183490e8460d078fb778daa363a',
        '0xee4a21d26248318a637a932612bc937065e76c8575681e599b47d0a0854d737d',
        '0xdc2ca38c3de29812b9da571b3d401a8ab265246e23b52e4d4772512c6518555a'
    ]
    // const commitCon = "0x31eE7087b10071D2ac76391c65bBDD08BB7345bA"
    const name = "qq"
    const duration = 3
    const code = 'klNyMTYRgALyElLwwHG3'
    const suffix = "bn"
    await merkle.setCodeWhitelistMerkleRoot("0xe8cd2010f77fd17d3c3f83ab12b5e7f81f04677c0ce00d06ea77c2f1e33bcd3f")
    const res = await merkle.codeWhitelistSale(
        proof,
        name,
        code,
        suffix,
        duration
    )
    console.log(res)
    // const u = await merkle.getFirstComeFirstServedLength();
    // console.log(u)

    // const ress = await merkle.getVerifyWhite(to)
    // console.log(ress)
    // const w = await merkle.freeNumber(suffix, to, duration)
    // console.log(w)
    // const u = await merkle.freeNumber(name,
    //     suffix,
    //     to,
    //     duration)
    // console.log(u)
    // console.log(await merkle.getVerifyWhite(to)) 



    // console.log(res)

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

