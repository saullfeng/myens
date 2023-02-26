const AWS = require('aws-sdk');
const ddb = new AWS.DynamoDB.DocumentClient({ region: 'eu-west-1' });
const { BigNumber } = require('ethers');

async function updateAddress(nonce, txHash, element) {
    const params = {
        TableName: "gfit_send",
        IndexName: "txHash-index",
        Key: {
            'nonce': nonce,
            'txHash': txHash

        },
        UpdateExpression: "SET positions = :positions",
        ExpressionAttributeValues: {
            ':positions': element,

        }
    };
    // Call DynamoDB to add the item to the table
    return ddb.update(params).promise();
}
// async function main() {
//     await updateAddress(430, "0xd6d35f1582c7dfecee92f38a7f7376d6629ca8d91917cd7d5ae0351fe90fc5e4", "pending")
// }
// main()

async function updateTxHash(element) {
    const params = {
        TableName: "gfit_send",
        // IndexName: "txHash-index",
        Key: {
            'nonce': element.nonce,
            'to': element.to
        },
        UpdateExpression: "SET txHash = :txHash, maxPriorityFeePerGas = :maxPriorityFeePerGas,maxFeePerGas = :maxFeePerGas,gasLimit =:gasLimit",
        ExpressionAttributeValues: {
            ':txHash': element.hash,
            ':maxPriorityFeePerGas': BigNumber.from(element.maxPriorityFeePerGas).toString() - 0,
            ':maxFeePerGas': BigNumber.from(element.maxFeePerGas).toString() - 0,
            ':gasLimit': element.gasLimit,
        }
    };
    // Call DynamoDB to add the item to the table
    return ddb.update(params).promise();
}

async function updatePositions(nonce, to, element) {
    const params = {
        TableName: "gfit_send",
        // IndexName: "txHash-index",
        Key: {
            'nonce': nonce,
            'to': to
        },
        UpdateExpression: "SET positions = :positions",
        ExpressionAttributeValues: {
            ':positions': element,

        }
    };
    // Call DynamoDB to add the item to the table
    return ddb.update(params).promise();
}




module.exports = {
    updateAddress,
    updateTxHash,
    updatePositions
}