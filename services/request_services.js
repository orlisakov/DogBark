const { RequestApproveModel, ownerMessagesModel, trainerMessagesModel } = require('../model/request_model');
const { generalTrainingRequestsModel } = require('../model/profile_model');


class requestsServices { 
    static async createRequestApprove(
        OwnerId, userName, trainerId, trainerName, dogId, dogName) {
        const requestApprove = new RequestApproveModel({
            OwnerId: OwnerId,
            userName: userName,
            trainerId: trainerId,
            trainerName: trainerName,
            dogId: dogId,
            dogName: dogName
        });
        return await requestApprove.save();
    }

    static async createOwnerMessages(
        OwnerId, userName, trainerId, trainerName, dogId, dogName, message) {
        const ownerMessages = new ownerMessagesModel({
            OwnerId: OwnerId,
            userName: userName,
            trainerId: trainerId,
            trainerName: trainerName,
            dogId: dogId,
            dogName: dogName,
            message: message,
        });
        return await ownerMessages.save();
    }

    static async createTrainerMessages(
        OwnerId, userName, trainerId, trainerName, dogId, dogName, message) {
        const TrainerMessages = new trainerMessagesModel({
            OwnerId: OwnerId,
            userName: userName,
            trainerId: trainerId,
            trainerName: trainerName,
            dogId: dogId,
            dogName: dogName,
            message: message,
        });
        return await TrainerMessages.save();
    }

    static async deleteRequest(requestId) {
        const deleted = await generalTrainingRequestsModel.findOneAndDelete({_id: requestId});
        return deleted;
    }
    
    static async getApprovedProcesses(trainerId) {
        const RequestApprove = await RequestApproveModel.find({trainerId: trainerId});
        return RequestApprove;
    }

    static async getOwnerApprovedProcesses(OwnerId) {
        const RequestApprove = await RequestApproveModel.find({OwnerId: OwnerId});
        //console.log({ RequestApprove });
        return RequestApprove;
    }

    static async getMessagesForUser(userId) {
        const MessagesForUser = await ownerMessagesModel.find({OwnerId: userId});
        //console.log({ MessagesForUser });
        return MessagesForUser;
    }

    static async getMessagesForTrainer(trainerId) {
        const MessagesForUser = await trainerMessagesModel.find({trainerId: trainerId});
        //console.log({ MessagesForUser });
        return MessagesForUser;
    }

    static async checkIfWorkingTogether(OwnerId, trainerId, dogId) {
        const isWorkingTogether = await RequestApproveModel.exists({
          OwnerId: OwnerId,
          trainerId: trainerId,
          dogId: dogId,
        });
        //console.log({ isWorkingTogether });
        return !!isWorkingTogether;
      }
}

module.exports = requestsServices;