// import our monggoose a libary
const monggoose = require('mongoose');

// create a database connectivity 
const connection = monggoose.createConnection('mongodb://localhost:27017/BarkProject').on('open', () => {
    console.log("MongoDb Connected");
}).on('error', () => {
    console.log("MongoDb Connected error");
});

module.exports = connection;