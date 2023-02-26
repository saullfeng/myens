const { network, run, ethers } = require("hardhat")
const { BigNumber } = require("ethers");
const { formatBytes32String } = require("ethers/lib/utils");

async function main() {
    const [owner] = await ethers.getSigners()
    console.log(`owner address:${owner.address}`)


    const Admin = await ethers.getContractFactory("AdminInEth_APT2");
    const admin = Admin.attach("0xbD1194C1F5ebaf0F61b0a5D3940a4d11bE8752F8");


    // const Commit = await ethers.getContractFactory("Commit")
    // const commit = await Commit.attach("0x2892516B16b9B0F4f443515dA9ed8D673961dB03")

    // const aaaa = await commit.check_lable("cute.bn");
    // console.log(aaaa);


    // const a = await admin.a();
    // const b = await admin.b();
    // const c = await admin.c();
    // console.log(a,b,c)
    // const amount = ethers.BigNumber.from('32152167629311550991772383370938382603334832530988802531557994290880357738146');
  
    // // const ml = ethers.utils.keccak256("0x637574652e626e00000000000000000000000000000000000000000000000000")
    // // console.log(ml)
    // const res =  ethers.utils.hexZeroPad(amount.toHexString(), 32)
    // console.log(res)
    // const d =  ethers.utils.formatBytes32String("cute.bn")
    // console.log(d)
    //const e =  ethers.utils.parseBytes32String("0xd44d2ead4f8d086645edafbcb71380f1d8faa428f0e842b429ce5942d4db2e57")
    //console.log(e);

    
    await admin.setTrustedRemote(10108, "0x5ba56e6b445112aab43b8581f64db804ef652c125c156c71401aeb211b3dbc35bD1194C1F5ebaf0F61b0a5D3940a4d11bE8752F8")

}

function sleep(millisecond) {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve()
        }, millisecond)
    })
}

// NodeController address: 0x6518D5fED2b1b38CcAA8594653c1A01421Add89C
// Register(ERC721) address: 0x37CDa59bc5267b7D195870dc7c3D2FC10B0cB26a
// Resolver address: 0x5a54E0289366979fc75faA57574F13f1895c5D4b
// Commit address: 0x2892516B16b9B0F4f443515dA9ed8D673961dB03
// DefaultResolver 0x5a54E0289366979fc75faA57574F13f1895c5D4b
// Admin address: 0x77Ae68eB8E38B5a89f5Ce5c00FDD9f10DDb63CeF
// Deposit address : 0x4E5F88da91aC4089fB5523Df81cd3F18c0979F5c


main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })

