'use strict';

const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TABLE = process.env.TABLE

// Don't catch errors, allow them to propagate

exports.putItem = async (item) => {
    await docClient.put({
        TableName: TABLE,
        Item: item
    }).promise()
}


exports.getItem = async (id) => {
    const data = await docClient.query({
        TableName: TABLE,
        KeyConditionExpression: "#id = :id",
        ExpressionAttributeNames: {
            "#id": "id"
        },
        ExpressionAttributeValues: {
            ":id": parseInt(id)
        }
    }).promise()
    return data.Items[0]
}


exports.getItems = async () => {
    const data = await docClient.scan({
        TableName: TABLE
    }).promise()

    return data.Items
}

exports.deleteItem = async (id) => {
    await docClient.delete({
        TableName: TABLE,
        Key: {
            id: parseInt(id)
        }
    }).promise()
}