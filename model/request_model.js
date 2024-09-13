const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const RequestApproveSchema = new Schema({
    OwnerId: { 
        type: Schema.Types.ObjectId,
        ref: 'Owner', 
        required: true 
    },
    userName: { 
        type: String,
        required: true 
    },
    trainerId: { 
        type: Schema.Types.ObjectId, 
        ref: 'Trainer', 
        required: true
    },
    trainerName: { 
        type: String,
        required: true 
    },
    dogId: { 
        type: Schema.Types.ObjectId, 
        ref: 'dogProfile', 
        required: true
    },
    dogName: {
        type: String,
        required: true 
    },
    requestDate: { 
        type: Date, 
        default: Date.now 
    },
});

const ownerMessagesSchema = new Schema({
    OwnerId: { 
        type: Schema.Types.ObjectId,
        ref: 'Owner', 
        required: true 
    },
    userName: { 
        type: String,
        required: true 
    },
    trainerId: { 
        type: Schema.Types.ObjectId, 
        ref: 'Trainer', 
        required: true
    },
    trainerName: { 
        type: String,
        required: true 
    },
    dogId: { 
        type: Schema.Types.ObjectId, 
        ref: 'dogProfile', 
        required: true
    },
    dogName: {
        type: String,
        required: true 
    },
    message: {
        type: String,
        required: true 
    },
    requestDate: { 
        type: Date, 
        default: Date.now 
    },
});

const trainerMessagesSchema = new Schema({
    OwnerId: { 
        type: Schema.Types.ObjectId,
        ref: 'Owner', 
        required: true 
    },
    userName: { 
        type: String,
        required: true 
    },
    trainerId: { 
        type: Schema.Types.ObjectId, 
        ref: 'Trainer', 
        required: true
    },
    trainerName: { 
        type: String,
        required: true 
    },
    dogId: { 
        type: Schema.Types.ObjectId, 
        ref: 'dogProfile', 
        required: true
    },
    dogName: {
        type: String,
        required: true 
    },
    message: {
        type: String,
        required: true 
    },
    requestDate: { 
        type: Date, 
        default: Date.now 
    },
});


const RequestApproveModel = db.model('RequestApprove', RequestApproveSchema);
const ownerMessagesModel = db.model('ownerMessages', ownerMessagesSchema);
const trainerMessagesModel = db.model('trainerMessages', trainerMessagesSchema);

module.exports = { RequestApproveModel, ownerMessagesModel, trainerMessagesModel };