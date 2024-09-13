const taskServices = require('../services/tasks_services');

exports.createNewTask = async (req, res) => {
    try {
        const { OwnerId, userName, trainerId, trainerName, dogId, dogName, description, status, dueDate } = req.body;
        console.log('Received data:', { OwnerId, userName, trainerId, trainerName, dogId, dogName, description, status, dueDate });
        let task = await taskServices.createNewTask(OwnerId, userName, trainerId, trainerName, dogId, dogName, description, status, dueDate);
        console.log('Task created:', task);
        res.json({status: true, success: task});
    } catch (error) {
        console.error('Error creating task:', error);
        res.status(500).json({ status: false, error: error.message });
    }
}

exports.getTasksByDogId = async (req, res) => {
    try {
        const { dogId } = req.params;
        let tasks = await taskServices.getTasksByDogId(dogId);
        res.json({ status: true, success: tasks });
    } catch (error) {
        res.status(500).json({ status: false, error: error.message });
    }
}

exports.updateTaskDogStatus = async (req, res) => {
    try {
        const { taskId, status } = req.body;
        let task = await taskServices.updateTaskDogStatus(taskId, status);
        res.json({status: true, success: task});
    } catch (error) {
        res.status(500).json({ status: false, error: error.message });
    }
}

exports.getTasksByOwnerId = async (req, res) => {
    try {
        const { OwnerId } = req.params;
        let tasks = await taskServices.getTasksByOwnerId(OwnerId);
        res.json({ status: true, success: tasks });
    } catch (error) {
        res.status(500).json({ status: false, error: error.message });
    }
}