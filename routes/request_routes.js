const express = require('express');
const router = express.Router();
const requestController = require('../controllers/request_controller');

router.post('/requestApprove', requestController.createRequestApprove);
router.post('/ownerMessages', requestController.createOwnerMessages);
router.delete('/deleteRequest/:requestId', requestController.deleteRequest);
router.get('/getApprovedProcesses/:trainerId', requestController.getApprovedProcesses);
router.get('/getOwnerApprovedProcesses/:OwnerId', requestController.getOwnerApprovedProcesses);
router.get('/getMessagesForUser/:userId', requestController.getMessagesForUser);

router.post('/trainerMessages', requestController.createTrainerMessages);
router.get('/getMessagesForTrainer/:trainerId', requestController.getMessagesForTrainer);
router.get('/checkIfWorkingTogether/:OwnerId/:trainerId/:dogId', requestController.checkIfWorkingTogether);

module.exports = router;