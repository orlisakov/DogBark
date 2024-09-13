//schedule_controller
const scheduleService = require('../services/schedule_services');

class ScheduleController {
  async createOrUpdateSchedule(req, res) {
    const { tutorId, schedule, weekStart } = req.body;

    console.log('Received POST request at /schedule');
    console.log('tutorId:', tutorId);
    console.log('weekStart:', weekStart);

    try {
      const savedSchedule = await scheduleService.createOrUpdateSchedule(tutorId, schedule, weekStart);
      res.status(200).json({ message: 'Schedule saved successfully.', schedule: savedSchedule });
    } catch (error) {
      console.error('Error saving schedule:', error.message);
      res.status(500).json({ error: error.message });
    }
  }

  async getScheduleByTutorId(req, res) {
    const { tutorId } = req.params;
    let { weekStart } = req.query;

    if (!weekStart) {
        // Default to the start of the current week if weekStart is not provided
        weekStart = new Date();
        weekStart.setDate(weekStart.getDate() - weekStart.getDay());
        weekStart.setHours(0, 0, 0, 0);
        weekStart = weekStart.toISOString();
    }

    //console.log('Fetching schedule with tutorId:', tutorId, 'weekStart:', weekStart);

    try {
      const schedule = await scheduleService.getScheduleByTutorId(tutorId, weekStart);

      if (!schedule || !schedule.schedule.length) {
          console.log('No schedule found for tutorId:', tutorId, 'weekStart:', weekStart);
          return res.status(404).json({ message: 'No schedule found for this week.' });
      }

        // Filter out only future meetings
        const now = new Date();
        const futureMeetings = schedule.schedule.filter(meeting => {
            const meetingDate = new Date(meeting.startTime);
            return meetingDate > now;
        });

        //console.log('Retrieved schedule:', schedule.schedule);
        res.status(200).json({ tutorId: schedule.tutorId, schedule: schedule.schedule });
    
    } catch (error) {
        console.error('Error retrieving schedule:', error.message);
        res.status(500).json({ error: error.message });
    }
}

  async makeAppointment(req, res) {
    const { trainerId, day, startTime, ownerId, dogId } = req.body;

    try {
      const updatedSlot = await scheduleService.makeAppointment(trainerId, day, startTime, ownerId, dogId);
      res.status(200).json({ message: 'Appointment made successfully.', updatedSlot });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getAppointmentsByOwnerId(req, res) {
    const { ownerId } = req.params;
    const currentDate = new Date();
  
    try {
      const appointments = await scheduleService.getAppointmentsByOwnerId(ownerId, currentDate);
      if (!appointments || appointments.length === 0) {
        return res.status(404).json({ message: 'No appointments found for this owner.' });
      }
      res.status(200).json({ success: appointments });
    } catch (error) {
      console.error('Error retrieving appointments:', error.message);
      res.status(500).json({ error: error.message });
    }
  }

  async cancelAppointment(req, res) {
  const { tutorId } = req.params;
  const { day, startTime } = req.body;

  try {
    const schedule = await Schedule.findOne({
      tutorId: tutorId,
      'schedule.day': day,
      'schedule.times.startTime': startTime,
    });

    if (schedule) {
      const daySchedule = schedule.schedule.find(s => s.day === day);
      const timeSlot = daySchedule.times.find(t => t.startTime === startTime);

      if (timeSlot && !timeSlot.available) {
        timeSlot.available = true;
        timeSlot.ownerId = null;
        timeSlot.dogId = null;

        await schedule.save();

        res.status(200).json({ message: 'הפגישה בוטלה בהצלחה' });
      } else {
        res.status(400).json({ message: 'לא נמצאה פגישה פעילה בזמן זה' });
      }
    } else {
      res.status(404).json({ message: 'לוח זמנים לא נמצא' });
    }
  } catch (error) {
    console.error('שגיאה בביטול הפגישה:', error);
    res.status(500).json({ message: 'שגיאה פנימית בשרת' });
  }
}
async cancelAppointment(req, res) {
  const { tutorId } = req.params;
  const { day, startTime } = req.body;

  console.log('Received cancel appointment request:');
  console.log('Tutor ID:', tutorId);
  console.log('Day:', day);
  console.log('Start Time:', startTime);

  try {
    const result = await scheduleService.cancelAppointment(tutorId, day, startTime);
    
    if (result.success) {
      res.status(200).json({ message: 'הפגישה בוטלה בהצלחה' });
    } else {
      res.status(result.status).json({ message: result.message });
    }
  } catch (error) {
    console.error('שגיאה בביטול הפגישה:', error);
    res.status(500).json({ message: 'שגיאה פנימית בשרת' });
  }
}


}

module.exports = new ScheduleController();
