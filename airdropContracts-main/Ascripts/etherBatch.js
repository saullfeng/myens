
const { ethers, BigNumber } = require('ethers');
const { putAddress } = require('../scripts/dynamoDB/putItem');
const fs = require('fs');
const dotenv = require("dotenv");
dotenv.config();
const url = "https://polygon-mumbai.g.alchemy.com/v2/fcrtZatlCLII4bfyctD7pZwZJ60t35AO"
const customHttpProvider = new ethers.providers.JsonRpcProvider(url);

const { PRIVATE_KEY, API_KEY } = process.env;
const testArr = JSON.parse(fs.readFileSync("./json/ensAddress20.json"));
console.log(testArr.length)
const state = ['sending', 'pending', 'success', "need waiting"]
async function main() {
    // const toAddress = "0x4134ebd431b3c748ea96e4fbea2e4b6cd1840ea3";
    const wallet = new ethers.Wallet(PRIVATE_KEY);
    const ContractAddress = "0xd41b99e0d991e7a83201cb0780dd9d764df5b94d";
    // 循环空投
    // data数据不一样的
    // giftRecipient 将不是address 将是第几次的空投
    const feeData = await customHttpProvider.getFeeData();
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
    const transaction = {
        to: ContractAddress,
        nonce: NewNonce,
        chainId: 80001,
        data: data,
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        maxFeePerGas: feeData.maxFeePerGas,
        type: 2,
        // gasLimit: Utils.parseUnits("19900000", "wei"),
    };
    const gasLimit = await customHttpProvider.estimateGas(transaction)
    transaction.gasLimit = gasLimit
    // const gasPrice = await customHttpProvider.getGasPrice()
    // transaction.gasPrice = gasPrice

    const stx = await wallet.signTransaction(transaction)

    const res = await customHttpProvider.sendTransaction(stx)
    // await putAddress(1, res, state[0])

    console.log(res.hash)
    const bclockres = await customHttpProvider.getTransaction(res.hash)
    console.log(bclockres)
    // console.log(BigNumber.from(res.maxPriorityFeePerGas).toString() - 0)


}

main();