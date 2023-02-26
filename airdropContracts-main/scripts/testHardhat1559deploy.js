// const { BigNumber, Wallet } = require("ethers");
const { network, run, ethers } = require("hardhat")
const hre = require("hardhat");
const fs = require('fs');
const os = require('os');
const testArr = JSON.parse(fs.readFileSync("./json/ensAddress20.json"));
function writeFile(filename, data) {
    fs.writeFile(filename, JSON.stringify(data) + ',' + os.EOL, (err) => {
        // console.log(err)
    });
}
let privateKey = process.env.PRIVATE_KEY
async function main() {
    // console.log(ethers)
    const [deployer] = await ethers.getSigners()
    const balance = (await deployer.getBalance()).toString()
    console.log("Account balance:", balance, balance > 0)
    if (balance === 0) {
        throw (`Not enough eth`)
    }
    const feeData = await hre.ethers.provider.getFeeData()
    // console.log(feeData)
    // let gasPrice = await hre.ethers.provider.getGasPrice()
    console.log(`Deploying contracts to ${network.name} with the account:${deployer.address}`)

    const FEE_DATA = {
        maxFeePerGas: feeData.maxFeePerGas,
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        baseFeePerGas: feeData.lastBaseFeePerGas,
        // type: 2
    };

    // Wrap the provider so we can override fee data.
    const provider = new ethers.providers.FallbackProvider([ethers.provider], 1);
    // console.log(await provider.getTransactionCount(deployer.address))
    // console.log(ethers.provider)
    provider.getFeeData = async () => FEE_DATA;
    // provider.getFeeData = async () => FEE_DATA;

    // console.log(FEE_DATA)
    const contactName = "BatchRegister"
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    // console.log(signer)
    const Hardhat1559 = await ethers.getContractFactory(contactName, signer);
    // console.log(Hardhat1559.deploy())
    const newDe = await Hardhat1559.deploy("0x6fD63aB9bb3a17c2c5D5a288f6522C529470f05D")
    let gasPrice = await hre.ethers.provider.getGasPrice()
    // await newDe.deployed({ gasPrice: gasPrice, type: 2 })
    // console.log("batchTransfer1559de address:", newDe.address)

    const duration = 1
    const suffix = "bn"
    // const res1559 = await hardhat1559.BatchNumber(suffix, testArr, duration)
    // console.log(res1559)





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

