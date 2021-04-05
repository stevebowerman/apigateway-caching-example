const {putItem} = require('./db');

// Populate the DDB table with sample data

(async () => {
    for (i=0; i<=100; i++) {
        const req = {
            id: i,
            field1: `test ${i}`,
            timestamp: new Date().toISOString()
        }
        await putItem(req)
        console.log(req)
    }
})()