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


    const Register = await ethers.getContractFactory("Register");
    const register = await Register.deploy(nodecontroller.address);
    await register.deployTransaction.wait()
    console.log("Register(ERC721) address:", register.address)


    const Resolver = await ethers.getContractFactory("Resolver");
    const resolver = await Resolver.deploy(nodecontroller.address);
    await resolver.deployTransaction.wait()
    console.log("Resolver address:", resolver.address);


    const Commit = await ethers.getContractFactory("Commit");
    const commit = await Commit.deploy(
        1,                                      // uint256 _minCommitmentAge,
        BigNumber.from("200000"),               // uint256 _maxCommitmentAge,
        BigNumber.from("10000000000000000"),    // uint256 baseprice, 0.01
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

    //0xcDbFc6E9Fc0DEf908feA9330c0392ED2a60464d9 fuji
    //0xA34EEe6913ecEdC657Cb39f56d3b2b45C42fCB92 
    await nodecontroller.set2LDowner(
        zeroNode,                   //  bytes32 node, 
        labelHash,                 // bytes32 label, 
        register.address           // address owner
    )

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
