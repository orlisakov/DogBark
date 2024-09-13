const express = require('express');
const router = express.Router();
const messageController = require('../controllers/message_controller');

router.post('/createMessage', messageController.createMessage);
router.get('/getMessagesByChatId/:chatId', messageController.getMessagesByChatId);
router.post('/uploadMedia', messageController.uploadMedia);

module.exports = router;