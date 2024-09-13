const db = require('../config/db');
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const { Schema } = mongoose;

//-------------------------------------------owner-----------------------------------------------

// Owner schema
const ownerSchema = new Schema({
    // Additional fields for owner if needed
    userName: {
        type: String,
        lowercase: true,
        required: true,
        unique: true
    },
    email: {
        type: String,
        lowercase: true,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true,
    },
    role: {
        type: String,
        lowercase: true,
        required: true,
        enum: ['owner', 'trainer'],
        default: 'owner'
    },
});

ownerSchema.pre('save', async function() {
    try {
        var user = this;
        const salt = await(bcrypt.genSalt(10));
        const hashedPassword = await bcrypt.hash(user.password, salt);
        user.password = hashedPassword;
        
    } catch (error) {
        throw error;
    }
});

ownerSchema.methods.comparePassword = async function(userPassword) {
    try {
        const isMatch = await bcrypt.compare(userPassword, this.password);
        return isMatch;
    } catch (error) {
        throw error;
    }
};

// Model for owner
const OwnerModel = db.model('Owner', ownerSchema);

//-------------------------------------------Trainer-----------------------------------------------

// Trainer schema
const trainerSchema = new Schema({
    // Additional fields for trainer if needed
    userName: {
        type: String,
        lowercase: true,
        required: true,
        unique: true
    },
    email: {
        type: String,
        lowercase: true,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true,
    },
    role: {
        type: String,
        lowercase: true,
        required: true,
        enum: ['owner', 'trainer'],
        default: 'owner' // Set a default role if needed
    },    
});

trainerSchema.pre('save', async function() {
    try {
        var user = this;
        const salt = await(bcrypt.genSalt(10));
        const hashedPassword = await bcrypt.hash(user.password, salt);
        user.password = hashedPassword;
        
    } catch (error) {
        throw error;
    }
});

trainerSchema.methods.comparePassword = async function(userPassword) {
    try {
        const isMatch = await bcrypt.compare(userPassword, this.password);
        return isMatch;
    } catch (error) {
        throw error;
    }
};

// Model for trainer
const TrainerModel = db.model('Trainer', trainerSchema);

//-------------------------------------------Admin-----------------------------------------------

// Trainer schema
const adminSchema = new Schema({
    // Additional fields for trainer if needed
    email: {
        type: String,
        lowercase: true,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true,
    },
    role: {
        type: String,
        lowercase: true,
        required: true,
        default: 'admin'
    }
    
});

adminSchema.methods.comparePassword = async function(userPassword) {
    try {
        const isMatch = await bcrypt.compare(userPassword, this.password);
        return isMatch;
    } catch (error) {
        throw error;
    }
};

// Model for trainer
const AdminModel = db.model('Admin', trainerSchema);

module.exports = { OwnerModel, TrainerModel, AdminModel };