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
        gasPrice: feeData.gasPrice
        // type: 2
    };

    // Wrap the provider so we can override fee data.
    const provider = new ethers.providers.FallbackProvider([ethers.provider], 1);
    // console.log(ethers.provider)
    provider.getFeeData = async () => FEE_DATA;
    // console.log(FEE_DATA)
    const contactName = "BatchRegister"
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    // console.log(signer)
    // Hardhat1559 = await ethers.getContractFactory(contactName, signer);
    // // console.log(Hardhat1559)
    // hardhat1559 = await Hardhat1559.attach("0xD41B99e0D991E7a83201cb0780Dd9D764Df5B94D")

    const hardhat1559 = await ethers.getContractAt(
        contactName,
        // "0x244150397d670708B9FB858391D1285769A356B8",
        '0xD41B99e0D991E7a83201cb0780Dd9D764Df5B94D',
        // Deploy1559.address,
        signer
    );
    // console.log(hardhat1559)

    let gasPrice = await hre.ethers.provider.getGasPrice()
    const duration = 1
    const suffix = "bn"
    const nonce = await ethers.provider.getTransactionCount(deployer.address);
    const res1559 = await hardhat1559.BatchNumber(suffix, testArr, duration, { gasPrice: gasPrice, nonce: nonce })
    console.log(res1559)

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

