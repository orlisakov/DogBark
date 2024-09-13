const recommendationServices = require('../services/recommendation_services');

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

exports.createRecommendation = [
  upload.array('media', 4),
  async (req, res) => {
    try {
      console.log(req.files); 

      const { ownerId, trainerId, ownerName, rating, description } = req.body;
      const media = req.files.map(file => file.path);

      console.log('Data received:', {
        ownerId,
        trainerId,
        ownerName,
        rating,
        description,
        media
      });

      const recommendation = await recommendationServices.createRecommendation({
        ownerId,
        trainerId,
        ownerName,
        rating: Number(rating),
        description,
        media
      });

      res.status(201).json(recommendation);
    } catch (error) {
      console.error("Error creating recommendation:", error);
      res.status(500).json({ message: 'Server error' });
    }
  }
];


exports.getRecommendations = async (req, res) => {
  try {
    const { trainerId } = req.params;
    const recommendations = await recommendationServices.getRecommendations(trainerId);
    //console.log('Saving recommendation:', recommendations);
    res.status(200).json(recommendations);
  } catch (error) {
    console.error("Error getting recommendations:", error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.checkIfWorkingTogetherTrainerAndOwner = async (req, res) => {
  try {
    const { trainerId, OwnerId } = req.params;
    const isWorkingTogether = await recommendationServices.checkIfWorkingTogetherTrainerAndOwner(trainerId, OwnerId);
    //console.log({ isWorkingTogether });
    res.json({ isWorkingTogether });
  } catch (error) {
    console.error("Error checking if working together:", error);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.getTrainerRecommendations = async (req, res) => {
  try {
    const { trainerId } = req.params;
    console.log("Fetching recommendations for trainerId:", trainerId);
    const recommendations = await recommendationServices.getTrainerRecommendations(trainerId);
    res.status(200).json(recommendations);
  } catch (error) {
    console.error("Error fetching trainer's recommendations:", error);
    res.status(500).json({ message: 'Server error' });
  }
};
