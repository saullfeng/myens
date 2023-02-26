const { BigNumber, Wallet } = require("ethers");
const { network, run, ethers } = require("hardhat")
const hre = require("hardhat");
const fs = require('fs');
const os = require('os');
const testArr = JSON.parse(fs.readFileSync("./json/ensAddress50.json"));
function writeFile(filename, data) {
    fs.writeFile(filename, JSON.stringify(data) + ',' + os.EOL, (err) => {
        // console.log(err)
    });
}
// let privateKey = process.env.PRIVATE_KEY
async function main() {
    // console.log(ethers)
    const [deployer] = await ethers.getSigners()
    const feeData = await hre.ethers.provider.getFeeData()
    let gasPrice = await hre.ethers.provider.getGasPrice()
    console.log(`Deploying contracts to ${network.name} with the account:${deployer.address}`)

    const balance = (await deployer.getBalance()).toString()

    console.log("Account balance:", balance, balance > 0)
    if (balance === 0) {
        throw (`Not enough eth`)
    }



    const contactName = "BatchRegister"
    const BatchRegister = await ethers.getContractFactory(contactName);
    // // // test ac789016e4f90469a4318488d7d1bf3f30d81fe68d683f686e8aea63d2a2fafc
    // // //0x0625dbc951f206e10785e66d827193ef74c74f0be36302e5fd3fb191dc6e8105
    const Deploy1559 = await BatchRegister.deploy("0x6fD63aB9bb3a17c2c5D5a288f6522C529470f05D")
    // const Deploy1 = await BatchRegister.deploy("0x0dEeadCd7DC4EE98B974c041cf4a25CEc2d54B61")
    await Deploy1559.deployed({
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        maxFeePerGas: feeData.maxFeePerGas,
        gasPrice: gasPrice,
        type: 2
    })
    // await Deploy1.deployed()
    console.log("batchTransfer1559 address:", Deploy1559.address)
    // console.log("batchTransfer address:", Deploy1.address)

    const batch = await ethers.getContractAt(
        contactName,
        // "0x244150397d670708B9FB858391D1285769A356B8",
        // '0xEE31CB70633D8d031363B968EC03e1CC7CB91969',
        Deploy1559.address,
        deployer
    );

    const duration = 1
    const suffix = "bn"

    const res = await batch.BatchNumber(suffix, testArr, duration)
    console.log(res)





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

