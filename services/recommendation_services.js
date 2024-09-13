const Recommendation = require('../model/recommendation_model');
const { RequestApproveModel, ownerMessagesModel, trainerMessagesModel } = require('../model/request_model');

class RecommendationService {
    static async createRecommendation({ ownerId, trainerId, ownerName, rating, description, media }) {
        try {
            const recommendation = new Recommendation({
              ownerId,
              trainerId,
              ownerName,
              rating,
              description,
              media
            });
      
            console.log('Saving recommendation:', recommendation);
            return await recommendation.save();
            
          } catch (error) {
            console.error("Error creating recommendation:", error);
            throw error;  // Re-throw the error after logging it
          }
    }

    static async getRecommendations(trainerId) {
      const recommendations = await Recommendation.find({ trainerId: trainerId });
      //console.log('Saving recommendation:', recommendations);
      return recommendations;
    }

    static async checkIfWorkingTogetherTrainerAndOwner(trainerId, OwnerId) {
      try {
        const isWorkingTogether = await RequestApproveModel.exists({
          trainerId: trainerId,
          OwnerId: OwnerId,
        });
        //console.log('Saving recommendation:', isWorkingTogether);
        return !!isWorkingTogether;
      } catch (error) {
        console.error("Error checking if working together:", error);
        throw new Error("Failed to check if working together");
      }
    }

    static async getTrainerRecommendations(trainerId) {
      try {
        console.log("Fetching recommendations for trainerId:", trainerId);
        const recommendations = await Recommendation.find({ trainerId: trainerId });
        console.log("Fetched recommendations:", recommendations);
        return recommendations;
      } catch (error) {
        console.error("Error fetching recommendations:", error);
        throw new Error("Failed to fetch recommendations");
      }
    }
    
}

module.exports = RecommendationService;
