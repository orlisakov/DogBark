const multer = require('multer');
const path = require('path'); // Import path module
const MessageService = require('../services/message_services');

// Set up storage for media uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
      cb(null, Date.now() + '-' + file.originalname);
    }
  });

const upload = multer({ storage: storage });

exports.createMessage = [
    upload.single('media'), 
    async (req, res) => {
      try {
        const { chatId, senderId, senderType, messageType } = req.body;
        let messageContent = req.body.messageContent;
  
        if (req.file) {
          messageContent = req.file.path.replace(/\\/g, '/');
        }
  
        const message = await MessageService.createMessage(
          chatId, senderId, senderType, messageType, messageContent
        );
  
        res.json({ status: true, success: message });
      } catch (error) {
        console.error("Error creating message:", error);
        res.status(500).json({ status: false, error: error.message });
      }
    }
  ];

  exports.getMessagesByChatId = async (req, res) => {
    try {
      const { chatId } = req.params;
      const messages = await MessageService.getMessagesByChatId(chatId);
      res.json({ status: true, success: messages });
    } catch (error) {
      console.error("Error retrieving messages:", error);
      res.status(500).json({ status: false, error: error.message });
    }
  };
  

  exports.uploadMedia = [
    upload.single('media'),
    (req, res) => {
      try {
        if (!req.file) {
          return res.status(400).json({ status: false, message: 'No file uploaded' });
        }
  
        const filePath = path.join('uploads', req.file.filename).replace(/\\/g, '/'); // Normalize path
        res.json({
          status: true,
          message: 'File uploaded successfully',
          mediaUrl: filePath 
        });
      } catch (error) {
        console.error("Error uploading media:", error);
        res.status(500).json({ status: false, error: error.message });
      }
    }
  ];
