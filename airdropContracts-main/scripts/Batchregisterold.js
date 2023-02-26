const { BigNumber, Wallet } = require("ethers");
const { network, run, ethers } = require("hardhat")
const hre = require("hardhat");
const fs = require('fs');
const os = require('os');
const testArr = JSON.parse(fs.readFileSync("./json/ensAddress10.json"));
function writeFile(filename, data) {
    fs.writeFile(filename, JSON.stringify(data) + ',' + os.EOL, (err) => {
        // console.log(err)
    });
}
let privateKey = process.env.PRIVATE_KEY
async function main() {
    // console.log(ethers)
    const [deployer] = await ethers.getSigners()
    const feeData = await hre.ethers.provider.getFeeData()
    console.log(`Deploying contracts to ${network.name} with the account:${deployer.address}`)

    const balance = (await deployer.getBalance()).toString()
    console.log("Account balance:", balance, balance > 0)
    if (balance === 0) {
        throw (`Not enough eth`)
    }

    const contactName = "BatchRegister"
    const batch = await ethers.getContractAt(
        contactName,
        // "0x244150397d670708B9FB858391D1285769A356B8",
        '0xDaf1E03DB06C7Af9C541D75C68a0d6D66238a0EC',
        // merkleDeploy.address,
        deployer
    );
    const duration = 1
    const suffix = "bn"
    let tx = {
        to: ContractAddress,
        nonce: NewNonce,
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        maxFeePerGas: feeData.maxFeePerGas,
        type: 2,
        chainId: 80001,
        data: data,
    }

    const res = await batch.BatchNumber(suffix, testArr, duration)
    console.log(res)





    // console.log(res)

    //  gas: 3100000,
    // gasPrice: 6000000000,
    //0x6197b76bc64cb141bdf38ec10e674a81d39a1c76e10bb55b4c728688fe484e34
    //Transaction Fee:
    //     0.01206138 MATIC($0.02)
    // Txn Type:
    //     0(Legacy)
    // Gas Limit:
    //     2, 150, 648
    // Gas Used by Transaction:
    //     2, 010, 230(93.47 %)
    // Base Fee Per Gas:
    //     15 wei(0.000000015 Gwei)
    // Burnt Fees:
    //     0.00000000003015345 MATIC
    // Gas Price:
    //     0.000000006 MATIC(6 Gwei)

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

