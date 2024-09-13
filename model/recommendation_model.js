const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const recommendationSchema = new Schema({
  ownerId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  trainerId: {
    type: Schema.Types.ObjectId,
    ref: 'Trainer',
    required: true
  },
  ownerName: {
    type: String,
    required: true
  },
  rating: {
    type: Number,
    min: 1,
    max: 5,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  media: {
    type: [String],
    default: []
  }
});

const Recommendation = db.model('Recommendation', recommendationSchema);

module.exports = Recommendation;
