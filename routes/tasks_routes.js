const express = require('express');
const router = express.Router();
const taskController = require('../controllers/tasks_controller');

router.post('/createNewTask', taskController.createNewTask);
router.get('/getTasksByDogId/:dogId', taskController.getTasksByDogId);

router.put('/updateTaskDogStatus', taskController.updateTaskDogStatus);

router.get('/getTasksByOwnerId/:OwnerId', taskController.getTasksByOwnerId);

module.exports = router;
