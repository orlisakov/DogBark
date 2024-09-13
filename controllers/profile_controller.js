const profileServices = require('../services/profile_services');

const multer = require('multer');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
      cb(null, Date.now() + '-' + file.originalname);
    }
  });
  
const upload = multer({ storage: storage });
  
  exports.createDogProfile = [
    upload.array('media', 4),
    async (req, res) => {
      try {
        const {
          userId, DogName, Race, Weight, Adopted,
          Question1, Question2, Question3, Question4, Question5,
          Question6, Question7, Question8, Question9, Question10,
          Question11, Question12, Question13, Question14, Question15,
          Question16, Question17, Question18, Question19, Question20,
          Question21, Question22, Question23, Question24, Question25
        } = req.body;
  
        let dogImage = [];
        if (req.files && req.files.length > 0) {
            dogImage = req.files.map(file => file.path);
        }
  
        let dogProfile = await profileServices.createDogProfile(
          userId, DogName, Race, Weight, Adopted, dogImage,
          Question1, Question2, Question3, Question4, Question5,
          Question6, Question7, Question8, Question9, Question10,
          Question11, Question12, Question13, Question14, Question15,
          Question16, Question17, Question18, Question19, Question20,
          Question21, Question22, Question23, Question24, Question25
        );
        
        res.json({ status: true, success: dogProfile });

      } catch (error) {
        console.error("Error creating dog profile:", error);
        return res.status(500).json({ status: false, message: 'Server error' });
      }
    }
  ];
  
//------------------------------------------------------------------------
exports.createGeneralTrainingRequests = async (req, res, next) => {
    try {
        const { OwnerId, userName, trainerId, trainerName, dogId, dogName } = req.body;
        console.log({ OwnerId, userName, trainerId, dogId, trainerName, dogName });
        let GeneralTrainingRequests = await profileServices.createGeneralTrainingRequests(
            OwnerId, userName, trainerId, trainerName, dogId, dogName );
        //console.log(GeneralTrainingRequests);
        res.json({status: true, success: GeneralTrainingRequests});

    } catch (error) {
        res.status(500).json({status: false, error: error.message});
        throw error;
    }
}

exports.deleteGeneralTrainingRequest = async (req, res, next) => {
  try {
    const { OwnerId, dogId } = req.body;

    if (!mongoose.Types.ObjectId.isValid(dogId)) {
      return res.status(400).json({ message: 'Invalid dogId format' });
    }

    let deleted = await profileServices.deleteGeneralTrainingRequest(OwnerId, dogId);
    res.json({ status: true, success: deleted });
  } catch (error) {
    console.error('Error in deleteGeneralTrainingRequest:', error.message);
    res.status(500).json({ status: false, error: error.message });
  }
};

//------------------------------------------------------------------------
exports.getDogProfile = async (req, res, next) => {
    try {
        const { userId } = req.body;
        let dogProfile = await profileServices.getDogProfileData(userId);
        res.json({status: true, success: dogProfile});
    } catch (error) {
        throw error;
    }
}

//------------------------------------------------------------------------
exports.deleteDogProfile = async (req, res, next) => {
    try {
        const { id } = req.body;
        let deleted = await profileServices.deleteDogProfile( id );
        res.json({status: true, success: deleted});
        //console.log(deleted);
    } catch (error) {
        throw error;
    }
}

//------------------------------update-----------------------------------

exports.updateDogProfile = [
    upload.array('media', 4), // Accept up to 4 files
    async (req, res, next) => {
      try {
        const { id } = req.params;
        const {
          DogName, Race, Weight, Adopted,
          Question1, Question2, Question3, Question4, Question5,
          Question6, Question7, Question8, Question9, Question10,
          Question11, Question12, Question13, Question14, Question15,
          Question16, Question17, Question18, Question19, Question20,
          Question21, Question22, Question23, Question24, Question25
        } = req.body;
    
        let dogImage = [];
      if (req.files && req.files.length > 0) {
        dogImage = req.files.map(file => file.path);
      }

        const update = {
          DogName, Race, Weight, Adopted, dogImage,
          Question1, Question2, Question3, Question4, Question5,
          Question6, Question7, Question8, Question9, Question10,
          Question11, Question12, Question13, Question14, Question15,
          Question16, Question17, Question18, Question19, Question20,
          Question21, Question22, Question23, Question24, Question25
        };
    
        let updatedDogProfile = await profileServices.updateDogProfile(id, update);
        if (!updatedDogProfile) {
          return res.status(404).send({ message: 'Dog profile not found' });
        }
    
        res.json({ status: true, dogProfile: updatedDogProfile });
      } catch (error) {
        console.error("Error updating dog profile:", error);
        res.status(500).send({ message: 'An error occurred', error: error.message });
      }
    }
  ];
  
// Fetch dog profile by ID
exports.getDogProfileById = async (req, res, next) => {
  try {
    const { id } = req.params;  // Use 'id' here
    const dogProfile = await profileServices.findDogProfileById(id);  // Pass 'id' to the service method
    if (!dogProfile) {
      return res.status(404).send({ error: 'Dog profile not found' });
    }
    //console.log('Dog profile found:', dogProfile);
    res.status(200).send(dogProfile);
  } catch (error) {
    console.error('Error fetching dog profile:', error.message);
    res.status(500).send({ error: 'Server error' });
  }
};


//-------------------------Search Trainers By Area------------------------------
exports.getSearchTrainersByArea = async (req, res, next) => {
    try {
      const area = req.query.area;
      let trainers = await profileServices.getSearchTrainersByArea(area);
      res.json({ success: true, trainers: trainers });
      //console.log(trainers);
    } catch (error) {
        throw error;
    }
};

exports.getRequestsResultsById = async (req, res, next) => {
    try {
      const id = req.query.id;
      let owners = await profileServices.getRequestsResultsById(id);
      res.json({ success: true, owners: owners });
      //console.log(owners);
    } catch (error) {
        res.status(500).json({ success: false, message: 'Internal server error', error: error.message });
        throw error;
    }
};
  
exports.getAllTrainers = async (req, res, next) => {
    try {
        const trainers = await profileServices.getAllTrainersInfo();
        res.json({status: true, success: trainers});
    } catch (error) {
        console.error('Failed to fetch all trainers:', error);
        res.status(500).json({status: false, error: 'Internal Server Error'});
    }
};
//---------------------------Trainer ----------------------------------


exports.createTrainerProfile = [
  upload.fields([
      { name: 'profilePicture', maxCount: 1 },
      { name: 'certificates', maxCount: 10 }
  ]),
  async (req, res, next) => {
      try {
          const {
              userId, FirstName, LastName, PhoneNum, Area,
              Question1, Question2, Question3, Question4, Question5,
              Question6, Question7, Question8, Question9, Question10,
              Question11, Question12, Question13, Question14, Question15,
              Question16, Question17, Question18, Question19, Question20,
              Question21, Question22, Question23, Question24, Question25,
              Question26, Question27, Question28, Question29
          } = req.body;

          let profilePicture = '';
          if (req.files['profilePicture']) {
              profilePicture = req.files['profilePicture'][0].path;
          }

          let certificates = [];
          if (req.files['certificates']) {
              certificates = req.files['certificates'].map(file => file.path);
          }

          let trainerProfile = await profileServices.createTrainerProfile({
              userId, FirstName, LastName, PhoneNum, Area, profilePicture, certificates,
              Question1, Question2, Question3, Question4, Question5,
              Question6, Question7, Question8, Question9, Question10,
              Question11, Question12, Question13, Question14, Question15,
              Question16, Question17, Question18, Question19, Question20,
              Question21, Question22, Question23, Question24, Question25,
              Question26, Question27, Question28, Question29
          });

          res.json({ status: true, success: trainerProfile });
      } catch (error) {
          console.error("Error creating trainer profile:", error);
          res.status(500).json({ status: false, message: 'Server error' });
      }
  }
];

//------------------------------------------------------------------------

exports.getTrainerProfile = async (req, res, next) => {
    try {
        const { userId } = req.body;
        let trainerProfile = await profileServices.getTrainerProfileData(userId);
        res.json({status: true, success: trainerProfile});
    } catch (error) {
        throw error;
    }
}

//------------------------------------------------------------------------

exports.deleteTrainerProfile = async (req, res, next) => {
    try {
        const { id } = req.body;
        let deleted = await profileServices.deleteTrainerProfile(id);
        res.json({status: true, success: deleted});
    } catch (error) {
        throw error;
    }
}

exports.updateTrainerProfile = [
  upload.fields([
      { name: 'profilePicture', maxCount: 1 },
      { name: 'certificates', maxCount: 10 }
  ]),
  async (req, res, next) => {
      try {
          const { id } = req.params;
          const {
              FirstName, LastName, PhoneNum, Area,
              Question1, Question2, Question3, Question4, Question5,
              Question6, Question7, Question8, Question9, Question10,
              Question11, Question12, Question13, Question14, Question15,
              Question16, Question17, Question18, Question19, Question20,
              Question21, Question22, Question23, Question24, Question25,
              Question26, Question27, Question28, Question29
          } = req.body;

          let profilePicture = '';
          if (req.files['profilePicture']) {
              profilePicture = req.files['profilePicture'][0].path;
          }

          let certificates = [];
          if (req.files['certificates']) {
              certificates = req.files['certificates'].map(file => file.path);
          }

          const update = {
              FirstName, LastName, PhoneNum, Area, profilePicture, certificates,
              Question1, Question2, Question3, Question4, Question5,
              Question6, Question7, Question8, Question9, Question10,
              Question11, Question12, Question13, Question14, Question15,
              Question16, Question17, Question18, Question19, Question20,
              Question21, Question22, Question23, Question24, Question25,
              Question26, Question27, Question28, Question29
          };

          let updatedTrainerProfile = await profileServices.updateTrainerProfile(id, update);
          if (!updatedTrainerProfile) {
              return res.status(404).send({ message: 'Trainer Profile not found' });
          }

          res.json({ status: true, TrainerProfile: updatedTrainerProfile });
      } catch (error) {
          console.error("Error updating trainer profile:", error);
          res.status(500).send({ message: 'An error occurred', error: error.message });
      }
  }
];

exports.getTrainerProfileById = async (req, res, next) => {
    try {
      //console.log("Requested ID:", req.params.id);
      const { id } = req.params;
      let TrainerProfile = await profileServices.getTrainerProfileById(id);
      if (!TrainerProfile) {
        return res.status(404).send({ error: 'Trainer profile not found' });
      }
      //console.log(TrainerProfile);
      res.send(TrainerProfile);
    } catch (error) {
      console.error("Error fetching Trainer Profile:", error); // More descriptive error logging
      res.status(500).send({ error: 'Server error' });
    }
};

  exports.getDogProfileByOwnerId = async (req, res, next) => {
    try {
        const { id } = req.params;
        //console.log("Requested Owner ID:", id);
        let dogProfiles = await profileServices.getDogProfilesByOwnerId(id);
        if (!dogProfiles || dogProfiles.length === 0) {
            return res.status(404).send({ error: 'No dog profiles found for this owner' });
        }
        //console.log(dogProfiles);
        res.json(dogProfiles);
    } catch (error) {
        console.error("Error fetching Dog Profiles:", error); // More descriptive error logging
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getDogProfileByDogId = async (req, res, next) => {
    try {
        const { id } = req.params;
        //console.log("Requested Owner ID:", id);
        let dogProfiles = await profileServices.getDogProfileByDogId(id);
        if (!dogProfiles || dogProfiles.length === 0) {
            return res.status(404).send({ error: 'No dog profiles found for this owner' });
        }
        //console.log(dogProfiles);
        res.json(dogProfiles);
    } catch (error) {
        console.error("Error fetching Dog Profiles:", error); // More descriptive error logging
        res.status(500).json({ message: 'Server error' });
    }
};



exports.getTrainingRequestsExcludingTrainer = async (req, res, next) => {
    try {
      const { trainerId } = req.params;
      let requests = await profileServices.getTrainingRequestsExcludingTrainer(trainerId);
      res.json({ success: true, requests: requests });
    } catch (error) {
      res.status(500).send({ message: "Internal server error", error: error.message });
    }
};
  
//------------------------------------------------------------------------
exports.getTrainerProfileByDogId = async (req, res, next) => {
    try {
        const { id } = req.params;
        //console.log("Requested Trainer ID:", id);
        let trainerProfile = await profileServices.getTrainerProfileByDogId(id);
        //console.log(trainerProfile);
        if (!trainerProfile) {
            return res.status(404).send({ error: 'No trainer profile found for this ID' });
        }
        //console.log(trainerProfile);
        res.json(trainerProfile);
    } catch (error) {
        console.error("Error fetching Trainer Profile:", error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getOwnerById = async (req, res, next) => {
  const { OwnerId } = req.params;

  try {
    const owner = await profileServices.getOwnerById(OwnerId);
    if (!owner) {
      return res.status(404).json({ message: 'Owner not found' });
    }
    res.status(200).json(owner);
  } catch (error) {
    console.error('Error retrieving owner:', error.message);
    res.status(500).json({ error: error.message });
  }
}

exports.getTrainerById = async (req, res, next) => {
  const { id } = req.params;

  try {
      const trainer = await profileServices.getTrainerById(id);
      //console.log('Trainer object returned from service:', trainer); // Log what service returns

      if (!trainer) {
          return res.status(404).json({ message: 'Trainer not found' });
      }

      const fullName = `${trainer.FirstName || ''} ${trainer.LastName || ''}`.trim();
      //console.log('Full name sent to frontend:', fullName); // Log the full name sent to frontend

      res.status(200).json({ fullName });
  } catch (error) {
      console.error('Error retrieving trainer:', error.message);
      res.status(500).json({ error: 'Server error' });
  }
}

exports.getTrainerProfilePicture = async (req, res, next) => {
  try {
      const { trainerId } = req.params;
      let profilePicture = await profileServices.getTrainerProfilePicture(trainerId);
      res.json({ status: true, profilePicture: profilePicture });
  } catch (error) {
      console.error("Error in getTrainerProfilePicture controller:", error);
      res.status(500).json({ status: false, message: "Failed to get trainer profile picture" });
  }
}

