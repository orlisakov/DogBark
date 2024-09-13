//additions_model.jsconst 
db = require('../config/db');
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const { Schema } = mongoose;

const tipSchema = new Schema({
    title: String,
    content: String,
    imageURL: String,
    createdAt: {
      type: Date,
      default: Date.now,
    },
});

const Tip = db.model('Tip', tipSchema);

module.exports = { Tip };