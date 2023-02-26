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

    const Deposit = await ethers.getContractFactory("DepositInEth")
    const deposit = await Deposit.attach("0xcEE23C8189a81F6F22Edef79B4044A244cB862B8")

    const Register = await ethers.getContractFactory("Register")
    const register = await Register.attach("0xBc5225bef3E88a684aB59c56FCd166cdB224b902")


    //Cross
    const Admin = await ethers.getContractFactory("AdminInEth")
    const admin = await Admin.deploy(
        "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706",   // endpoint = ILayerZeroEndpoint(_endpoint);
        register.address                                // base = IRegister(_base);
    )
    //  0xf69186dfBa60DdB133E91E9A4B5673624293d8F8 mumbai
    await admin.deployTransaction.wait()
    console.log("Admin address:", admin.address)

    await deposit.setWhitelist(admin.address, true)

    await sleep(3000);

    await register.addController(
        admin.address    //AdminInMumbai.addrss
    );//把AdminInMumbai放入白名单中，可以直接注册

    await sleep(3000);

    await admin.setdepositAddress(
        deposit.address
    );//设置deposit地址

    await sleep(3000);

    await deposit.setOperator(
        admin.address//AdminInMumbai.addrss
    );//把设置为存储合约的appove 


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



//fuji
// NodeController address: 0x6518D5fED2b1b38CcAA8594653c1A01421Add89C
// Register(ERC721) address: 0x37CDa59bc5267b7D195870dc7c3D2FC10B0cB26a
// Resolver address: 0x5a54E0289366979fc75faA57574F13f1895c5D4b
// Commit address: 0x2892516B16b9B0F4f443515dA9ed8D673961dB03
// DefaultResolver 0x5a54E0289366979fc75faA57574F13f1895c5D4b
// Admin address: 0x77Ae68eB8E38B5a89f5Ce5c00FDD9f10DDb63CeF
// Deposit address : 0x4E5F88da91aC4089fB5523Df81cd3F18c0979F5c