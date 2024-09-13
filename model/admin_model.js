const db = require('../config/db');
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const { Schema } = mongoose;

const sendMessageAdminToUserSchema = new Schema({
    adminId: {
        type: Schema.Types.ObjectId,
        ref: 'Admin',
        required: true,
    },
    adminUsername: { 
        type: String, 
        required: true,
    },
    recipientUserId: {
        type: Schema.Types.ObjectId, 
        ref: 'User',
        required: true,
    },
    recipientUsername: { 
        type: String, 
        required: true,
    },
    recipientType: { 
        type: String, 
        required: true, 
    },
    message: { 
        type: String, 
        required: true,
    },
    sentDate: { 
        type: Date, 
        default: Date.now,
    },
});
  
const MessagesAdminToUser = db.model('MessagesAdminToUser', sendMessageAdminToUserSchema);

const sendMessageUserToAdminSchema = new Schema({
    adminId: {
        type: Schema.Types.ObjectId,
        ref: 'Admin',
        required: true,
    },
    adminUsername: { 
        type: String, 
        required: true,
    },
    recipientUserId: {
        type: Schema.Types.ObjectId, 
        ref: 'User',
        required: true,
    },
    recipientUsername: { 
        type: String, 
        required: true,
    },
    recipientType: { 
        type: String, 
        required: true, 
    },
    message: { 
        type: String, 
        required: true,
    },
    sentDate: { 
        type: Date, 
        default: Date.now,
    },
});
  
const MessagesUserToAdmin = db.model('MessagesUserToAdmin', sendMessageUserToAdminSchema);

module.exports = { MessagesAdminToUser, MessagesUserToAdmin };
