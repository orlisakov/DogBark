const { TrainerModel, OwnerModel, AdminModel } = require('../model/user_model');
const { MessagesAdminToUser, MessagesUserToAdmin } = require('../model/admin_model');

class AdminService {
    static async getOwners() {
        try {
          const owners = await OwnerModel.find({}, '-password');
          return owners;
        } catch (error) {
          throw error;
        }
    }
    
    static async getTrainers() {
        try {
          const trainers = await TrainerModel.find({}, '-password');
          return trainers;
        } catch (error) {
          throw error;
        }
    }

    static async deleteUserByAdmin(userId) {
        try {
          let deletedUser;
    
          // Check if user exists in Owners collection
          deletedUser = await OwnerModel.findByIdAndDelete(userId);
    
          // If not found in Owners, check in Trainers collection
          if (!deletedUser) {
            deletedUser = await TrainerModel.findByIdAndDelete(userId);
          }
          // If still not found, handle accordingly (throw error or return null)
          if (!deletedUser) {
            throw new Error(`User with ID ${userId} not found`);
          }
    
          return deletedUser;
        } catch (error) {
          throw error;
        }
    }

    static async sendMessageToUser({ adminId, adminUsername, userId, recipientUsername, recipientType, message }) {
        try {
            
          const newMessage = new MessagesAdminToUser({
            adminId: adminId,
            adminUsername: adminUsername,
            recipientUserId: userId,
            recipientUsername: recipientUsername,
            recipientType: recipientType,
            message: message,
          });
      
          return await newMessage.save();
        } catch (error) {
          throw error;
        }
      }  

      //---------------------------------------------------------------------------------
      static async sendMessageUserToAdmin({ adminId, adminUsername, userId, recipientUsername, recipientType, message }) {
        try {
            
          const newMessage = new MessagesUserToAdmin({
            adminId: adminId,
            adminUsername: adminUsername,
            recipientUserId: userId,
            recipientUsername: recipientUsername,
            recipientType: recipientType,
            message: message,
          });
      
          return await newMessage.save();
        } catch (error) {
          throw error;
        }
      } 
}

module.exports = AdminService;