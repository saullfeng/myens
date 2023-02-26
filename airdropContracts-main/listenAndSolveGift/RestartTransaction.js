
const { ethers, BigNumber } = require('ethers');
const fs = require('fs');
const dotenv = require("dotenv");
dotenv.config();
const { scanAddress } = require('../scripts/dynamoDB/scan');
const { updateTxHash } = require('../scripts/dynamoDB/update');
const url = "https://polygon-mumbai.g.alchemy.com/v2/fcrtZatlCLII4bfyctD7pZwZJ60t35AO"
const customHttpProvider = new ethers.providers.JsonRpcProvider(url);

const { PRIVATE_KEY, API_KEY } = process.env;
const testArr = JSON.parse(fs.readFileSync("./json/ensAddress20.json"));
async function main() {
    const wallet = new ethers.Wallet(PRIVATE_KEY);
    const AllStatus = await scanAddress()
    AllStatus.Items.forEach(async ele => {
        // if (ele.positions == 'pending') {
        const feeData = await customHttpProvider.getFeeData();
        let tx = {
            from: wallet.address,
            chainId: ele.chainId,
            to: ele.to,
            nonce: ele.nonce,
            value: '0',
            data: ele.data,
            maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
            maxFeePerGas: feeData.maxFeePerGas,
            type: 2,
            // gasLimit: ele.gasLimit
        };
        console.log("++++++1")
        const gasLimit = await customHttpProvider.estimateGas(tx)
        tx.gasLimit = gasLimit
        const stx = await wallet.signTransaction(tx)
        const res = await customHttpProvider.sendTransaction(stx)
        await updateTxHash(res)
        console.log(res)
        // }
    })

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

// tx = {
//     from: wallet.address,
//     to: ele.to,
//     chainId: ele.chainId,
//     nonce: ele.nonce
// }
// customHttpProvider.estimateGas(tx).then(function (estimate) {
//     tx.gasLimit = Math.ceil(estimate * 1.2);
//     tx.gasPrice = Math.ceil(ele.gasPrice * 1.2)
//     console.log(tx)
//     wallet.signTransaction(tx).then((signedTX) => {
//         customHttpProvider.sendTransaction(signedTX).then(
//             //更新 
//             console.log
//         );
//     });
// });