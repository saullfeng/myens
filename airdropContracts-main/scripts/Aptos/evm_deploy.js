const { network, run } = require("hardhat")
const { BigNumber } = require("ethers");

async function main() {
    const [deployer] = await ethers.getSigners()
    console.log(`Deploying contracts to ${network.name} with the account:${deployer.address}`)

    const balance = (await deployer.getBalance()).toString()
    console.log("Account balance:", balance, balance > 0)
    if (balance === 0) {
        throw (`Not enough eth`)
    }

    const Receive = await ethers.getContractFactory("Receive");
    const receive= await Receive.deploy("0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706")
    await receive.deployTransaction.wait()
    console.log("Receive address:", receive.address)
}



function sleep(millisecond) {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve()
        }, millisecond)
    })
}


main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })

