const TaskModel = require('../model/tasks_model');

class TaskService {
    static async createNewTask(OwnerId, userName, trainerId, trainerName, dogId, dogName, description, status, dueDate) {
        const task = new TaskModel({ OwnerId, userName, trainerId, trainerName, dogId, dogName, description, status, dueDate });
        //console.log({ task });
        return await task.save();
    }

    static async getTasksByDogId(dogId) {
        return await TaskModel.find({ dogId });
    }
    
    static async updateTaskDogStatus(taskId, status) {
        return await TaskModel.findByIdAndUpdate(taskId, { status, updatedAt: Date.now() }, { new: true });
    }

    static async getTasksByOwnerId(OwnerId) {
        return await TaskModel.find({ OwnerId });
    }
}

module.exports = TaskService;
