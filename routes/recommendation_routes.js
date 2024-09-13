const express = require('express');
const recommendationController = require('../controllers/recommendation_controller');
const router = express.Router();

router.post('/createRecommendation', recommendationController.createRecommendation);
router.get('/getRecommendations/:trainerId', recommendationController.getRecommendations);

router.get('/checkIfWorkingTogetherTrainerAndOwner/:OwnerId/:trainerId', recommendationController.checkIfWorkingTogetherTrainerAndOwner);

router.get('/getTrainerRecommendations/:trainerId', recommendationController.getTrainerRecommendations);

module.exports = router;
