const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const postSchema = new Schema({
    trainerId: {
      type: Schema.Types.ObjectId, 
      ref: 'Trainer', 
      required: true, 
    },
    trainerName: {
      type: String, 
      required: true,
    },
    content: { 
      type: String, 
      required: true, 
    },
    profilePicture: { 
      type: String, 
      required: true, 
    },
    createdAt: {
      type: Date, 
      default: Date.now, 
    },
    media: {
      type: [String],
      default: []
    },
  });

const Post = db.model('Post', postSchema);
module.exports = { Post };