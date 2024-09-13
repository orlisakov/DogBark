// routes/postRoutes.js
const express = require('express');
const router = express.Router();
const postController = require('../controllers/post_controller');

router.post('/createPost', postController.createPost);
router.get('/getPosts', postController.getPosts);

module.exports = router;
