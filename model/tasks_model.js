const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const TaskSchema = new Schema({
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
    description: {
        type: String,
        required: true
    },
    status: {
        type: String,
        required: true
    },
    dueDate: {
        type: Date,
        required: true
    },
    createdDate: {
        type: Date,
        default: Date.now
    },
});

const TaskModel = db.model('Task', TaskSchema);
module.exports = TaskModel;