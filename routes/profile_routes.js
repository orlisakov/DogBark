const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profile_controller');

//---------------------- owner ---------------------------
router.post('/dogProfile', profileController.createDogProfile);
router.post('/getDogProfileList', profileController.getDogProfile);
router.post('/deleteDogProfile', profileController.deleteDogProfile);
router.put('/updateDogProfile/:id', profileController.updateDogProfile);
router.get('/getDogProfileById/:id', profileController.getDogProfileById);
router.get('/getOwnerById/:OwnerId', profileController.getOwnerById);
//--------------------- trainer ---------------------------

router.get('/getTrainerById/:id', profileController.getTrainerById);

router.post('/trainerProfile', profileController.createTrainerProfile);
router.post('/getTrainerProfileList', profileController.getTrainerProfile);
router.post('/deleteTrainerProfile', profileController.deleteTrainerProfile);
router.put('/updateTrainerProfile/:id', profileController.updateTrainerProfile);
router.get('/getTrainerProfileById/:id', profileController.getTrainerProfileById);
router.get('/requests/exclude/:trainerId', profileController.getTrainingRequestsExcludingTrainer);
router.get('/requestsResultsById', profileController.getRequestsResultsById); 
router.get('/getDogProfileByOwnerId/:id', profileController.getDogProfileByOwnerId); 
router.get('/getDogProfileByDogId/:id', profileController.getDogProfileByDogId); 

router.get('/searchTrainersByArea', profileController.getSearchTrainersByArea); 
router.get('/allTrainers', profileController.getAllTrainers); 
router.post('/createGeneralTrainingRequests', profileController.createGeneralTrainingRequests); 
router.post('/deleteGeneralTrainingRequest', profileController.deleteGeneralTrainingRequest); 

router.get('/getTrainerProfileByDogId/:id', profileController.getTrainerProfileByDogId);

router.get('/getTrainerProfilePicture/:trainerId', profileController.getTrainerProfilePicture);
//------------------------------------------------------------------------
module.exports = router;