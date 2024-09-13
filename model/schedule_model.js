//schedule_model
const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const ScheduleSchema = new Schema({
  tutorId: {
    type: Schema.Types.ObjectId,
    required: true,
    ref: 'User',
  },
  weekStart: {
    type: Date,
    required: true,
  },
  schedule: [{
    day: String,
    times: [{
      startTime: String,
      endTime: String,
      available: { type: Boolean, default: true },
      ownerId: { type: Schema.Types.ObjectId, ref: 'User', default: null },
      dogId: { type: Schema.Types.ObjectId, ref: 'Dog', default: null },
      meetingId: { type: Schema.Types.ObjectId, ref: 'Meeting', default: null },
    }]
  }],
}, { timestamps: true });

const Schedule = db.model('Schedule', ScheduleSchema);

module.exports = { Schedule };

