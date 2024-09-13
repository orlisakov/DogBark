const db = require('../config/db');
const mongoose = require('mongoose');
const { OwnerModel, TrainerModel, AdminModel } = require('./user_model');
const { Schema } = mongoose;

//-------------------------------------------owner-----------------------------------------------
// Owner schema
const dogProfileSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'Owner',
        required: true,
    },
    Trainer: {
        type: Schema.Types.ObjectId,
        ref: 'TrainerProfile',
        required: false,
    },
    DogName: {
        type: String,
        lowercase: true,
        required: true,
    },
    Race: {
        type: String,
        lowercase: true,
        required: true,
    },
    Weight: {
        type: String,
        required: true,
    },
    Adopted: {
        type: String,
        required: true,
    },
    dogImage: {
        type: [String],
        default: []
    },
    
    Question1: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question2: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question3: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question4: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question5: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question6: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question7: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question8: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question9: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question10: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question11: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question12: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question13: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question14: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question15: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question16: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question17: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question18: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question19: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question20: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question21: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question22: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question23: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question24: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question25: {
        type: String,
        lowercase: true,
        required: true,
    },
});

const generalTrainingRequestsSchema = new Schema({
    OwnerId: { 
        type: Schema.Types.ObjectId,
        ref: 'OwnerModel', 
        required: true 
    },
    userName: { 
        type: String,
        required: true 
    },
    trainerId: { 
        type: Schema.Types.ObjectId, 
        ref: 'TrainerModel', 
        required: true
    },
    trainerName: { 
        type: String,
        required: true 
    },
    dogId: { 
        type: Schema.Types.ObjectId, 
        ref: 'dogProfileModel', 
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

//-------------------------------------------Trainer-----------------------------------------------

// Trainer schema
const trainerProfileSchema = new Schema({
    profilePicture: {
        type: String,
        required: false,
    },
    userId: {
        type: Schema.Types.ObjectId,
        ref: TrainerModel.modelName,
    },
    FirstName: {
        type: String,
        lowercase: true,
        required: true,
    },
    LastName: {
        type: String,
        lowercase: true,
        required: true,
    },
    PhoneNum: {
        type: String,
        lowercase: true,
        required: true,
    },
    Area: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question1: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question2: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question3: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question4: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question5: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question6: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question7: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question8: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question9: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question10: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question11: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question12: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question13: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question14: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question15: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question16: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question17: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question18: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question19: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question20: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question21: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question22: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question23: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question24: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question25: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question26: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question27: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question28: {
        type: String,
        lowercase: true,
        required: true,
    },
    Question29: {
        type: String,
        lowercase: true,
        required: true,
    },
    certificates: {
        type: [String],
        default: [],
    },
});

const dogProfileModel = db.model('dogProfile', dogProfileSchema);
const trainerProfileModel = db.model('trainerProfile', trainerProfileSchema);
const generalTrainingRequestsModel = db.model('generalTrainingRequests', generalTrainingRequestsSchema);

module.exports = { dogProfileModel, trainerProfileModel, generalTrainingRequestsModel };