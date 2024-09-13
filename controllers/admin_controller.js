const AdminService = require('../services/admin_services');

exports.getTrainers = async (req, res, next) => {
    try {
      const users = await AdminService.getTrainers();
      res.status(200).json(users);
    } catch (error) {
      console.error("Error fetching getTrainers:", error);
      res.status(500).json({
        error: "Failed to fetch getTrainers",
      });
    }
  };

exports.getOwners = async (req, res, next) => {
    try {
      const users = await AdminService.getOwners();
      res.status(200).json(users);
    } catch (error) {
      console.error("Error fetching getOwners:", error);
      res.status(500).json({
        error: "Failed to fetch getOwners",
      });
    }
};

exports.sendMessageAdminToUser = async (req, res, next) => {
    try {
      const { adminId, adminUsername, userId, recipientUsername, recipientType, message } = req.body;
      /*console.log('sendMessageAdminToUser data:', { adminId, adminUsername, userId, recipientUsername, recipientType, message });*/
  
      const savedMessage = await AdminService.sendMessageToUser({
        adminId,
        adminUsername,
        userId,
        recipientUsername,
        recipientType,
        message,
      });
  
      res.status(200).json({
        status: true,
        message: 'Message sent successfully',
        result: savedMessage,
      });
    } catch (error) {
      console.error('Error sending message:', error);
      res.status(500).json({
        status: false,
        error: 'Server Error, Message Sending Failed',
      });
    }
  };

  exports.deleteUserByAdmin = async (req, res, next) => {
    try {
      const { userId } = req.body;
      const result = await AdminService.deleteUserByAdmin(userId);
      
      res.status(200).json({
        status: true,
        message: 'User deleted successfully',
        result,
      });
    } catch (error) {
      console.error('Error deleting user:', error);
      res.status(500).json({
        status: false,
        error: 'Server Error, User Deletion Failed',
      });
    }
  };

  //---------------------------------------------------------------------------
  exports.sendMessageUserToAdmin = async (req, res, next) => {
    try {
      const { adminId, adminUsername, userId, recipientUsername, recipientType, message } = req.body;
      /*console.log('sendMessageUserToAdmin data:', { adminId, adminUsername, userId, recipientUsername, recipientType, message });*/
  
      const savedMessage = await AdminService.sendMessageUserToAdmin({
        adminId,
        adminUsername,
        userId,
        recipientUsername,
        recipientType,
        message,
      });
  
      res.status(200).json({
        status: true,
        message: 'Message sent successfully',
        result: savedMessage,
      });
    } catch (error) {
      console.error('Error sending message:', error);
      res.status(500).json({
        status: false,
        error: 'Server Error, Message Sending Failed',
      });
    }
  };