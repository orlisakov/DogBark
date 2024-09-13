const requestsServices = require('../services/request_services');
const { RequestApproveModel, ownerMessagesModel, trainerMessagesModel } = require('../model/request_model');

exports.createRequestApprove = async (req, res) => {
    try {
        const { OwnerId, userName, trainerId, trainerName, dogId, dogName } = req.body;
        let requestApprove = await requestsServices.createRequestApprove(
            OwnerId, userName, trainerId, trainerName, dogId, dogName);
        res.json({status: true, success: requestApprove});
    } catch (error) {
        res.status(500).json({ status: false, error: error.message });
    }
}

exports.createOwnerMessages = async (req, res) => {
    console.log(req.body);
    try {
        const { OwnerId, userName, trainerId, trainerName, dogId, dogName, message } = req.body;
        let ownerMessages = await requestsServices.createOwnerMessages(
            OwnerId, userName, trainerId, trainerName, dogId, dogName, message);
        res.json({status: true, success: ownerMessages});
    } catch (error) {
        res.status(500).json({ status: false, error: error.message });
    }
}

exports.createTrainerMessages = async (req, res) => {
  console.log(req.body);
  try {
      const { OwnerId, userName, trainerId, trainerName, dogId, dogName, message } = req.body;
      let TrainerMessages = await requestsServices.createTrainerMessages(
          OwnerId, userName, trainerId, trainerName, dogId, dogName, message);
      res.json({status: true, success: TrainerMessages});
  } catch (error) {
      res.status(500).json({ status: false, error: error.message });
  }
}

exports.deleteRequest = async (req, res) => {
    try {
        const { requestId } = req.params; // Assuming you're using request ID as a URL parameter
        let deleted = await requestsServices.deleteRequest(requestId);
        res.json({status: true, success: deleted});
    } catch (error) {
        res.status(500).json({ status: false, error: error.message });
    }
}

exports.getApprovedProcesses = async (req, res, next) => {
    try {
      const { trainerId } = req.params;
      let RequestApprove = await requestsServices.getApprovedProcesses(trainerId);
      res.json({ status: true, success: RequestApprove });
    } catch (error) {
      res.status(500).json({ status: false, error: error.message });
    }
}

exports.getOwnerApprovedProcesses = async (req, res, next) => {
    try {
      const { OwnerId } = req.params;
      let RequestApprove = await requestsServices.getOwnerApprovedProcesses(OwnerId);
      //console.log({ RequestApprove });
      res.json({ status: true, success: RequestApprove });
    } catch (error) {
      res.status(500).json({ status: false, error: error.message });
    }
}

exports.getMessagesForUser = async (req, res, next) => {
    try {
      const { userId } = req.params;
      let MessagesForUser = await requestsServices.getMessagesForUser(userId);
      //console.log({ MessagesForUser });
      res.json({ status: true, success: MessagesForUser });
    } catch (error) {
      res.status(500).json({ status: false, error: error.message });
    }
}

exports.getMessagesForTrainer = async (req, res, next) => {
    try {
      const { trainerId } = req.params;
      let MessagesForUser = await requestsServices.getMessagesForTrainer(trainerId);
      //console.log({ MessagesForUser });
      res.json({ status: true, success: MessagesForUser });
    } catch (error) {
      res.status(500).json({ status: false, error: error.message });
    }
}

exports.checkIfWorkingTogether = async (req, res) => {
  try {
    const { OwnerId, trainerId, dogId } = req.params;
    const isWorkingTogether = await requestsServices.checkIfWorkingTogether(OwnerId, trainerId, dogId);
    console.log({ isWorkingTogether });
    res.json({ isWorkingTogether });
  } catch (error) {
    console.error("Error checking if working together:", error);
    res.status(500).json({ message: 'Server error' });
  }
}


