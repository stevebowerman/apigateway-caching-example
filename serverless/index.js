'use strict';

const {getItem, getItems, putItem, deleteItem} = require('./db')
const sleep = (delay) => new Promise(resolve => setTimeout(resolve, delay))
    
exports.lambda_handler = async (event) => {
    console.log(event)
    let statusCode = 400
    let body = {}
    
    try {
        if (!event) throw new Error('Invalid request payload')
        
        switch(event.httpMethod) {
            case "GET":
                if (event.pathParameters === null) {
                    body = await getItems()
                } else {
                    body = await getItem(event.pathParameters.id)
                    if (!body) throw new Error('Not found')
                }
                await sleep(5000) // Synthetic delay to visually show cache hit/miss
                statusCode = 200
                break

            case "POST":
                if (event.resource === "/test/search") {
                    body = await getItem(JSON.parse(event.body).id)
                    if (!body) throw new Error('Not found')
                    await sleep(5000) // Synthetic delay to visually show cache hit/miss
                    statusCode = 200
                } else {
                    await putItem(JSON.parse(event.body))
                    statusCode = 204
                }
                break

            case "PUT":
                await putItem(JSON.parse(event.body))
                statusCode = 204
                break

            case "DELETE":
                if (event.pathParameters === null) throw new Error('Missing id')
                await deleteItem(event.pathParameters.id)
                statusCode = 204
                break
        }
    
    } catch (e) {
        console.error(e)
        body = {
            error: {
                code: 400,
                message: e.message
            }
        }
    }

    return {
        statusCode: statusCode,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": true
        },
        body: JSON.stringify(body),
        isBase64Encoded: false
    }
}