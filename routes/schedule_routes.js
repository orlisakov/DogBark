const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/Schedule_controller');

// Route to create or update a tutor's schedule
router.post('/createOrUpdateSchedule', scheduleController.createOrUpdateSchedule);

// Route to get a tutor's schedule by ID
router.get('/getScheduleByTutorId/:tutorId', scheduleController.getScheduleByTutorId);

// Route to make an appointment
router.post('/makeAppointment', scheduleController.makeAppointment);

// Route to get appointments by Owner ID
router.get('/getAppointmentsByOwnerId/:ownerId', scheduleController.getAppointmentsByOwnerId);

// Route to cancel an appointment
router.post('/cancelAppointment/:tutorId', scheduleController.cancelAppointment);

module.exports = router;
