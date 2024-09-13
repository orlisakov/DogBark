// schedule_services.js
const { Schedule } = require('../model/schedule_model');

class ScheduleService {
  async createOrUpdateSchedule(tutorId, schedule, weekStart) {
    const normalizedWeekStart = new Date(weekStart);
    normalizedWeekStart.setHours(0, 0, 0, 0); // Normalize the date to the start of the day

    let existingSchedule = await Schedule.findOne({ tutorId, weekStart: normalizedWeekStart });

    if (existingSchedule) {
      existingSchedule.schedule = schedule;
      await existingSchedule.save();
      return existingSchedule;
    } else {
      const newSchedule = new Schedule({
        tutorId,
        weekStart: normalizedWeekStart,
        schedule,
      });
      await newSchedule.save();
      return newSchedule;
    }
  }

  async getScheduleByTutorId(tutorId, weekStart) {
    if (!weekStart) {
        throw new Error('weekStart parameter is missing');
    }

    const normalizedWeekStart = new Date(weekStart);
    normalizedWeekStart.setHours(0, 0, 0, 0);

    try {
        const schedule = await Schedule.findOne({ tutorId, weekStart: normalizedWeekStart });

        if (!schedule) {
            return { tutorId, schedule: [] };
        }

        return { tutorId: schedule.tutorId, schedule: schedule.schedule };
    } catch (error) {
        console.error('Error fetching schedule from database:', error.message);
        throw new Error('Database query failed');
    }
}

  async makeAppointment(trainerId, day, startTime, ownerId, dogId) {
    const schedule = await Schedule.findOne({
      tutorId: trainerId,
      'schedule.day': day,
      'schedule.times.startTime': startTime,
    });

    if (schedule) {
      const daySchedule = schedule.schedule.find(s => s.day === day);
      const timeSlot = daySchedule.times.find(t => t.startTime === startTime);

      if (timeSlot.available) {
        timeSlot.available = false;
        timeSlot.ownerId = ownerId;
        timeSlot.dogId = dogId;
        await schedule.save();
        return timeSlot;
      } else {
        throw new Error('Time slot is no longer available.');
      }
    } else {
      throw new Error('Schedule not found.');
    }
  }

  async getAppointmentsByOwnerId(ownerId, currentDate) {
    try {
        const schedules = await Schedule.find({
            'schedule.times.ownerId': ownerId,
            
        });

        if (!schedules || schedules.length === 0) {
            console.log('No schedules found for ownerId:', ownerId);
            return [];
        }

        const hebrewDayMapping = {
            "יום ראשון": 0, // Sunday
            "יום שני": 1, // Monday
            "יום שלישי": 2, // Tuesday
            "יום רביעי": 3, // Wednesday
            "יום חמישי": 4, // Thursday
            "יום שישי": 5, // Friday
            "שבת": 6 // Saturday
        };

        const upcomingAppointments = schedules.flatMap(schedule => 
            schedule.schedule.flatMap(daySchedule => {
                const weekStart = new Date(schedule.weekStart);
                const dayOffset = hebrewDayMapping[daySchedule.day];

                if (typeof dayOffset === 'undefined') {
                    console.log(`Invalid day: ${daySchedule.day}`);
                    return [];
                }

                // Calculate the actual date for the day
                const scheduleDate = new Date(weekStart);
                scheduleDate.setDate(weekStart.getDate() + dayOffset);

                return daySchedule.times
                    .map(timeSlot => {
                        const startTimeParts = timeSlot.startTime.split(':');
                        const appointmentDateTime = new Date(scheduleDate);
                        appointmentDateTime.setHours(parseInt(startTimeParts[0], 10), parseInt(startTimeParts[1], 10));

                        return {
                            day: appointmentDateTime.toISOString(),
                            startTime: timeSlot.startTime,
                            endTime: timeSlot.endTime,
                            tutorId: schedule.tutorId,
                            dogId: timeSlot.dogId,
                            ownerId: timeSlot.ownerId // Include ownerId in the response
                        };
                    })
                    .filter(appointment => 
                        new Date(appointment.day) >= currentDate && 
                        appointment.ownerId && // Ensure ownerId is not null
                        appointment.ownerId.toString() === ownerId.toString() // Safely compare
                    );
            })
        );
        console.log('All upcoming appointments for ownerId:', ownerId, upcomingAppointments);

        return upcomingAppointments;
    } catch (error) {
        console.error('Database query failed:', error);
        throw new Error('Database query failed');
    }
}

async cancelAppointment(tutorId, day, startTime) {
  const hebrewDayMapping = {
    0: "יום ראשון", // Sunday
    1: "יום שני", // Monday
    2: "יום שלישי", // Tuesday
    3: "יום רביעי", // Wednesday
    4: "יום חמישי", // Thursday
    5: "יום שישי", // Friday
    6: "שבת"       // Saturday
  };

  try {
    const dayOfWeek = new Date(day).getDay(); // Get the day of the week (0-6)
    const hebrewDay = hebrewDayMapping[dayOfWeek]; // Map to the Hebrew day name

    console.log(`Searching for schedule with tutorId: ${tutorId}, day: ${hebrewDay}, startTime: ${startTime}`);

    const schedule = await Schedule.findOne({
      tutorId: tutorId,
      'schedule.day': hebrewDay,
      'schedule.times.startTime': startTime,
    });

    if (schedule) {
      const daySchedule = schedule.schedule.find(s => s.day === hebrewDay);
      const timeSlot = daySchedule.times.find(t => t.startTime === startTime);

      if (timeSlot && !timeSlot.available) {
        timeSlot.available = true;
        timeSlot.ownerId = null;
        timeSlot.dogId = null;

        await schedule.save();
        return { success: true, status: 200 };
      } else {
        console.log('No active appointment found at this time');
        return { success: false, status: 400, message: 'לא נמצאה פגישה פעילה בזמן זה' };
      }
    } else {
      console.log('Schedule not found');
      return { success: false, status: 404, message: 'לוח זמנים לא נמצא' };
    }
  } catch (error) {
    console.error('Error in canceling appointment:', error);
    return { success: false, status: 500, message: 'שגיאה פנימית בשרת' };
  }
}
}

module.exports = new ScheduleService();

