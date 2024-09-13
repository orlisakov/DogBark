//additions_routes.js
const router = require('express').Router();
const additionsController = require('../controllers/additions_controller');

// Route to get all tips
router.get('/getAllTips', additionsController.getAllTips);

// Route to create a new tip
router.post('/createTip', additionsController.createTip);

// Route to update an existing tip
router.put('/updateTip/:id', additionsController.updateTip);

// Route to delete a tip
router.delete('/deleteTip/:id', additionsController.deleteTip);

// Route to upload an image
router.post('/uploadImage', additionsController.uploadImage);

module.exports = router;

