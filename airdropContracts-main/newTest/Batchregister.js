
const ethers = require('ethers');
const fs = require('fs');
const dotenv = require("dotenv");
dotenv.config();
const url = "https://polygon-mumbai.g.alchemy.com/v2/fcrtZatlCLII4bfyctD7pZwZJ60t35AO"
const customHttpProvider = new ethers.providers.JsonRpcProvider(url);

const { PRIVATE_KEY } = process.env;
const testArr = JSON.parse(fs.readFileSync("./json/ensAddress500.json"));
console.log(testArr.length)
async function main() {
    // const toAddress = "0x4134ebd431b3c748ea96e4fbea2e4b6cd1840ea3";
    const wallet = new ethers.Wallet(PRIVATE_KEY);
    const ContractAddress = "0x19Ff44841dE1729EAB791Fef1b79F9b1c34D2AB8";

    // const feeData = await customHttpProvider.getFeeData();
    // console.log(feeData)
    const abi = ["function BatchNumber(string calldata suffix,address[] calldata to,uint256 duration)"];

    const iface = new ethers.utils.Interface(abi);
    const duration = 1
    const suffix = "bn"
    const data = iface.encodeFunctionData("BatchNumber", [
        suffix,
        testArr,
        duration
    ]
    );
    // console.log(feeData.maxPriorityFeePerGas)
    const NewNonce = await customHttpProvider.getTransactionCount(wallet.getAddress())
    const gasPrice = await customHttpProvider.getGasPrice()

    const transaction = {
        to: ContractAddress,
        nonce: NewNonce,
        // type: 2,
        chainId: 80001,
        data: data,
        gasPrice: gasPrice,
    };

    const gasLimit = await customHttpProvider.estimateGas(transaction)
    console.log(gasLimit)
    transaction.gasLimit = gasLimit
    // console.log("transaction===>" + transaction)
    const sTX = await wallet.signTransaction(transaction)

    const res = await customHttpProvider.sendTransaction(sTX)
    console.log(res)


    //batchTransfer1559 address: 0x7aA56f6EdBF31882bF566b4b2e316B0fa2ef5C43
    // batchTransfer address: 0xF870106a80Ab97313d44E598fdd2DfC95d3Abe9C

   

}

main();