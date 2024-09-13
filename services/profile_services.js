const { dogProfileModel, trainerProfileModel, generalTrainingRequestsModel } = require('../model/profile_model');
const { TrainerModel, OwnerModel, AdminModel } = require('../model/user_model');

class profileServices {
    //-------------------------- Owner ---------------------------------
    static async createDogProfile(
        userId, DogName, Race, Weight, Adopted, dogImage,
        Question1, Question2, Question3, Question4, Question5,
        Question6, Question7, Question8, Question9, Question10,
        Question11, Question12, Question13, Question14, Question15,
        Question16, Question17, Question18, Question19, Question20,
        Question21, Question22, Question23, Question24, Question25
        ) {
        try {
            const dogProfile = new dogProfileModel({
                userId, DogName, Race, Weight, Adopted, dogImage,
                Question1, Question2, Question3, Question4, Question5,
                Question6, Question7, Question8, Question9, Question10,
                Question11, Question12, Question13, Question14, Question15,
                Question16, Question17, Question18, Question19, Question20,
                Question21, Question22, Question23, Question24, Question25
            });
            return await dogProfile.save();
        } catch (error) {
            console.error("Error in createDogProfile service:", error);
            throw new Error('Failed to create dog profile');
        }
    }
    
    static async updateDogProfile(id, update) {
        try {
            const updatedDogProfile = await dogProfileModel.findByIdAndUpdate(id, update, { new: true });
            return updatedDogProfile;
        } catch (error) {
            console.error("Error in updateDogProfile service:", error);
            throw new Error('Failed to update dog profile');
        }
    }

    //------------------------------------------------------------------------
    static async getDogProfileData (userId) {
        const dogProfileData = await dogProfileModel.find({userId});
        return dogProfileData;
    }
    
    static async deleteDogProfile(id) {
        const deleted = await dogProfileModel.findOneAndDelete({_id: id});
        return deleted;
    }

    // Service method
    static async findDogProfileById(id) {
        try {
            const dogProfile = await dogProfileModel.findById(id);
            //.select('DogName')
            return dogProfile;
        } catch (error) {
        //console.error('Error retrieving dog profile:', error.message);
        throw new Error('Error retrieving dog profile: ' + error.message);
    }
    }
    //------------------------------------------------------------------------
    static async getSearchTrainersByArea(area) {
        const trainers = await trainerProfileModel.find({Area: area
            /*Area: area,
            consentToBeSearched: true,*/
        });
        return trainers;
    }

    static async getRequestsResultsById(id) {
        const owners = await generalTrainingRequestsModel.find({trainerId: id});
        return owners;
    }
    
    // New method to list all trainers' basic info
    static async getAllTrainersInfo() {
        try {
          const trainers = await trainerProfileModel.find().exec();
          return trainers;
        } catch (error) {
          throw error;
        }
    }

    //------------------------------------------------------------------------
    static async createGeneralTrainingRequests ( OwnerId, userName, trainerId, trainerName, dogId, dogName ) {
        const MyDogList = new generalTrainingRequestsModel ({ OwnerId, userName, trainerId, trainerName, dogId, dogName });
        return await MyDogList.save();
    }

    static async deleteGeneralTrainingRequest( OwnerId, dogId ) {
        const deleted = await generalTrainingRequestsModel.findOneAndDelete({ OwnerId: OwnerId, dogId: dogId});
        console.log(deleted);
        return deleted;
    }
    //------------------------------ Trainer ----------------------------------

    static async createTrainerProfile(profileData) {
        try {
            const trainerProfile = new trainerProfileModel(profileData);
            return await trainerProfile.save();
        } catch (error) {
            console.error("Error in createTrainerProfile service:", error);
            throw new Error('Failed to create trainer profile');
        }
    }
    //------------------------------------------------------------------------

    static async getTrainerProfileData (userId) {
        const trainerProfileData = await trainerProfileModel.find({userId});
        return trainerProfileData;
    }
    //------------------------------------------------------------------------

    static async deleteTrainerProfile(id) {
        const deleted = await trainerProfileModel.findOneAndDelete({_id: id});
        return deleted;
    }

    static async updateTrainerProfile(id, update) {
        try {
            const updatedTrainerProfile = await trainerProfileModel.findByIdAndUpdate(id, update, { new: true });
            return updatedTrainerProfile;
        } catch (error) {
            console.error("Error in updateTrainerProfile service:", error);
            throw new Error('Failed to update trainer profile');
        }
    }   

    static async getTrainerProfileById(id) {
        const TrainerProfile = await trainerProfileModel.findById(id);
        console.log(TrainerProfile);
        return TrainerProfile;
    }      

    // Assume dogServices is an object that encapsulates dog-related logic
    static async getDogProfilesByOwnerId(ownerId) {
        try {
            const dogProfiles = await dogProfileModel.find({ userId: ownerId });
            return dogProfiles;
        } catch (error) {
            console.error("Error in getDogProfilesByOwnerId service:", error);
            throw error; // Rethrow the error to be caught by the calling function
        }
    }

    static async getDogProfileByDogId(id) {
        try {
            const dogProfiles = await dogProfileModel.find({ _id: id });
            return dogProfiles;
        } catch (error) {
            console.error("Error in getDogProfilesByOwnerId service:", error);
            throw error; // Rethrow the error to be caught by the calling function
        }
    }

    // In your profileServices.js or equivalent file
    static async getTrainingRequestsExcludingTrainer(trainerId) {
        try {
        const requests = await generalTrainingRequestsModel.find({
            trainerId: { $ne: trainerId }
        });
        return requests;
        } catch (error) {
        throw error;
        }
    }

    static async getTrainerProfileByDogId(trainerId) {
        try {
            const trainerProfile = await trainerProfileModel.find({ userId: trainerId });
            //console.log("Requested trainerProfile:", trainerProfile);
            return trainerProfile;
        } catch (error) {
            console.error("Error in getTrainerProfile service:", error);
            throw error;
        }
    };

    static async getOwnerById(OwnerId) {
        try {
          const owner = await OwnerModel.findById(OwnerId).select('userName');
          return owner;
        } catch (error) {
          console.error('Error retrieving owner:', error.message);
          throw new Error('Error retrieving owner: ' + error.message);
        }
      }

    static async getTrainerById(id) {
        try {
            const trainer = await trainerProfileModel.findOne({ userId : id });
            //console.log('Trainer retrieved from database:', trainer);

            return trainer; // Return the trainer object
        } catch (error) {
            console.error('Error retrieving trainer:', error.message);
            throw new Error('Error retrieving trainer: ' + error.message);
        }
    }

    static async getTrainerProfilePicture(trainerId) {
        try {
            const trainerProfile = await trainerProfileModel.findOne({ userId : trainerId }).select('profilePicture');
            
            if (trainerProfile) {
                console.log("Trainer profile found:", trainerProfile); 
                console.log("Profile picture:", trainerProfile.profilePicture); 
                return trainerProfile.profilePicture;
            } else {
                console.log("No trainer profile found for trainerId:", trainerId);
                return null;
            }
        } catch (error) {
            console.error("Error in getTrainerProfilePicture service:", error);
            throw new Error('Failed to get trainer profile picture');
        }
    }
    
}
module.exports = profileServices;