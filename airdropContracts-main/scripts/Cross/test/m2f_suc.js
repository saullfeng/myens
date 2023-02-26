const { ethers } = require("hardhat");

async function main() {

    const [owner] = await ethers.getSigners()
    console.log(`owner address:${owner.address}`)

    const Register = await hre.ethers.getContractFactory("Register"); //get abi
    const Commit = await hre.ethers.getContractFactory("Commit");


    //mumbai
    // NodeController address: 0xb5cfb5B9A96c87d76ED32143CD267Fa84dd900A2
    // Register(ERC721) address: 0x9A87ba5D230B0121b012e9804F289492b629fAE9
    // Resolver address: 0xcaebD32d1Ce52E4e9d783762f97cDcE5f1E6dC18
    // Commit address: 0x7d128f174dd92B1cbe4FD4Bd0F262442c38785a4
    // DefaultResolver 0x0000000000000000000000000000000000000000
    // Admin address: 0x2133568B19C05B3d0530b81EDc4e1BcAD13fe2Ab
    // Deposit address : 0xcEb2a313f1333652fa28D4216EA8CFfdb376323e

    const AdminInMumbai = await hre.ethers.getContractFactory("AdminInEth");
    const adminInMumbai = AdminInMumbai.attach("0xa79E22E8BE96532b612aA1cC485dB7DD886CC428");
    const register = Register.attach("0xAc982d4f3C11c8977480954Ede9f73E8CB56A0cd");
    const commit = Commit.attach("0xEc980F3C41e43B7723D753641aE882254E24B17E")

    const label = await commit.check_lable("tyu.bn")
    console.log(label)

    
    //await register.approve(adminInMumbai.address, label);
    //await sleep(5000)

    let remoteAndLocal = hre.ethers.utils.solidityPack(
        ['address', 'address'],
        ['0x548C2022e255Ad1207fDa57356E627427865e0a6', '0xa79E22E8BE96532b612aA1cC485dB7DD886CC428']
    )

//fuji
// NodeController address: 0x6201857120080f122a8D00b30c4e22067F8aE42e
// Register(ERC721) address: 0x190Ee8Da6f643e4b9899148d8C3D14197187129c
// Resolver address: 0xb9464e3B67D6f7B70bb354f357Cfbd000F3D63a3
// Commit address: 0x7750FcAC1955f77DE3b6a704A1F5e5d2F22D1cB3
// DefaultResolver 0x0000000000000000000000000000000000000000
// Admin address: 0x548C2022e255Ad1207fDa57356E627427865e0a6
// Deposit address : 0x64A354dC2649cf7b1f342e2AaF896674e0c84A8d

    await adminInMumbai.crossChain(
        10106,
        remoteAndLocal,
        label,
        { value: ethers.utils.parseEther("0.6") },
    )


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


    // let b = await node.checkNode('fir.bn');
    // let a = await node.makeNode("0x24bb3ee1d13e66ad83f7d8f92faad2f685c75a758f36e5c579c522e29aef77e0",
    //  b);
    //  let c = await node.ownerOfnode(a);
    //  console.log(c)

    // adminInfuji address: 0x6cf25683DEd05Eb244A4c67d2CB653eDa7F05212
    // depositInfuji address: 0xfb350712043e227db22653f04c7B82bef6729635


    