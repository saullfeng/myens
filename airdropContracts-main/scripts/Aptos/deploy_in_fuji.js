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

    const NodeController = await ethers.getContractFactory("NodeController");
    const nodecontroller = await NodeController.deploy()
    await nodecontroller.deployTransaction.wait()
    console.log("NodeController address:", nodecontroller.address)


    const Register = await ethers.getContractFactory("Register")
    const register = await Register.deploy(nodecontroller.address)
    await register.deployTransaction.wait()    
    console.log("Register(ERC721) address:", register.address)


    const Resolver = await ethers.getContractFactory("Resolver");
    const resolver = await Resolver.deploy(nodecontroller.address);
    await resolver.deployTransaction.wait()
    console.log("Resolver address:", resolver.address)


    const Commit = await ethers.getContractFactory("Commit");
    const commit = await Commit.deploy(
        1,                                      // uint256 _minCommitmentAge,
        BigNumber.from("200000"),               // uint256 _maxCommitmentAge,
        BigNumber.from("10000000000000000"),    // uint256 baseprice,
        BigNumber.from("317097919"),            // uint256 baseprice,    // uint256 premiumprice,
        register.address                        // Register _base
    );
    await commit.deployTransaction.wait()
    console.log("Commit address:", commit.address);


    await register.setdefaultResolver(resolver.address);
    const defaultResolver = await register.checkdefaultResolver();
    console.log("DefaultResolver", defaultResolver);


    await register.addController(commit.address);   //add the commit to register's trust
    const labelHash = await nodecontroller.getNode("bn");
    let zeroNode = await nodecontroller.getNode0x0();
    //let ethNode = await nodecontroller.makeNode(zeroNode, labelHash);

    await sleep(3000);


    await nodecontroller.set2LDowner(
        zeroNode,                   //  bytes32 node, 
        labelHash,                 // bytes32 label, 
        register.address           // address owner
    )

    // await sleep(10000)
    // const nodeOwner = await nodecontroller.ownerOfNode(ethNode);
    // console.log("The owner of '.bn' :", nodeOwner);


    await sleep(3000);


    //Cross
    const Admin = await ethers.getContractFactory("AdminInEth_APT2")
    const admin = await Admin.deploy(
        "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706",   // endpoint = ILayerZeroEndpoint(_endpoint);
        register.address                                // base = IRegister(_base);
    )
    //  0xf69186dfBa60DdB133E91E9A4B5673624293d8F8 mumbai
    await admin.deployTransaction.wait()
    console.log("Admin address:", admin.address)


    const Deposit = await ethers.getContractFactory("DepositInEth");
    const deposit = await Deposit.deploy(
        register.address                               // base = IRegister(_base);
    );
    await deposit.deployTransaction.wait()
    console.log("Deposit address :", deposit.address)

    await sleep(3000);

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

    await sleep(3000);

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


    // NodeController address: 0x6518D5fED2b1b38CcAA8594653c1A01421Add89C
    // Register(ERC721) address: 0x37CDa59bc5267b7D195870dc7c3D2FC10B0cB26a
    // Resolver address: 0x5a54E0289366979fc75faA57574F13f1895c5D4b
    // Commit address: 0x2892516B16b9B0F4f443515dA9ed8D673961dB03
    // DefaultResolver 0x5a54E0289366979fc75faA57574F13f1895c5D4b
    // Admin address: 0x77Ae68eB8E38B5a89f5Ce5c00FDD9f10DDb63CeF
    // Deposit address : 0x4E5F88da91aC4089fB5523Df81cd3F18c0979F5c