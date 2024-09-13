const { Post } = require('../model/post_model');
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

// Create a new post
exports.createPost = [
  upload.array('media', 4), // Allow up to 4 media files per post
  async (req, res) => {
    try {
      // Extract media file paths
      const mediaPaths = req.files.map(file => file.path);

      // Create a new post with the provided data and media paths
      const newPost = new Post({
        trainerId: req.body.trainerId,
        trainerName: req.body.trainerName,
        content: req.body.content,
        profilePicture: req.body.profilePicture,
        media: mediaPaths // Save the media paths in the post
      });

      const savedPost = await newPost.save(); // Save the post to the database

      res.status(201).json({ success: true, post: savedPost });

    } catch (error) {
      console.error('Error in createPost:', error);
      res.status(500).json({ success: false, message: error.message });
    }
  }
];

// Get all posts
exports.getPosts = async (req, res) => {
  try {
    // Populate with both FirstName and LastName fields from the Trainer model
    const posts = await Post.find().populate('trainerId', 'FirstName LastName');
    res.status(200).json({ success: true, posts });
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
