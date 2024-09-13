const db = require('../config/db');
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const MessageSchema = new Schema({
    chatId: { 
        type: String, 
        required: true 
    },
    senderId: { 
        type: String, 
        required: true 
    },
    senderType: { 
        type: String, 
        required: true 
    },
    messageType: { 
        type: String, 
        required: true 
    },
    messageContent: { 
        type: String, 
        required: true 
    },
    createdAt: { 
        type: Date, 
        default: Date.now 
    }
});

const Message = db.model('Message', MessageSchema);

module.exports = Message;