
const { ethers, BigNumber } = require('ethers');
const fs = require('fs');
const dotenv = require("dotenv");
dotenv.config();
const level = require('level-rocksdb');
const db = level('./BIBdb')





async function main() {


    const wallet = new ethers.Wallet(PRIVATE_KEY);
    const ContractAddress = "0xd41b99e0d991e7a83201cb0780dd9d764df5b94d";


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
    const NewNonce = await customHttpProvider.getTransactionCount(wallet.getAddress())
    const transaction = {
        to: ContractAddress,
        nonce: NewNonce,
        chainId: 80001,
        data: data,
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        maxFeePerGas: feeData.maxFeePerGas,
        type: 2,
    };
    const gasLimit = await customHttpProvider.estimateGas(transaction)
    transaction.gasLimit = gasLimit
    const stx = await wallet.signTransaction(transaction)

    const res = await customHttpProvider.sendTransaction(stx)
    console.log(res.hash)
    const bclockres = await customHttpProvider.getTransaction(res.hash)
}


main()
