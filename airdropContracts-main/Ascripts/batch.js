
const { Network, Alchemy, Wallet, Utils } = require("alchemy-sdk");
const fs = require('fs');
const dotenv = require("dotenv");
dotenv.config();


const { PRIVATE_KEY, API_KEY } = process.env;


const testArr = JSON.parse(fs.readFileSync("./json/ensAddress500.json"));
// console.log(testArr[0])
const settings = {
    apiKey: API_KEY, // Replace with your API key.
    network: Network.MATIC_MUMBAI, // Replace with your network.
};

const alchemy = new Alchemy(settings);

async function main() {
    const wallet = new Wallet(PRIVATE_KEY, alchemy);
    // const toAddress = "0x4134ebd431b3c748ea96e4fbea2e4b6cd1840ea3";
    const ContractAddress = "0xDaf1E03DB06C7Af9C541D75C68a0d6D66238a0EC";
    const feeData = await alchemy.core.getFeeData();
    const abi = ["function BatchNumber(string calldata suffix,address[] calldata to,uint256 duration)"];
    const iface = new Utils.Interface(abi);
    const duration = 1
    const suffix = "bn"
    const data = iface.encodeFunctionData("BatchNumber", [
        suffix,
        testArr,
        duration
    ]

    );
    // console.log(data)

    const transaction = {
        to: ContractAddress,
        nonce: await alchemy.core.getTransactionCount(wallet.getAddress()),
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        maxFeePerGas: feeData.maxFeePerGas,
        type: 2,
        chainId: 80001,
        data: data,
        // gasLimit: Utils.parseUnits("19900000", "wei"),
    };

    // Send the transaction and log it.
    const sentTx = await wallet.sendTransaction(transaction);
    console.log(sentTx);
    //10 1000000 0.001473160515713712 982,107 (98.21%)
    //50 5200000 0.00764858258158488  5,099,055 (98.06%)
    //100 10400000  0.015368086663926256 10,245,391 (98.51%)
    //200 21000000 报错 exceeds block gas limit
    // 

}

main();