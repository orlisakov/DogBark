//additions_controller.js
const additionsServices = require('../services/additions_services');
const multer = require('multer');
const path = require('path');

// Set up storage engine
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/'); // Directory to store the uploaded images
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname)); // Naming the file with a timestamp
    },
});

// File type validation
const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
        return cb(null, true);
    } else {
        cb('Error: Images Only!');
    }
};

// Set up multer
const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB file size limit
    fileFilter: fileFilter,
});

class AdditionsController {
    async getAllTips(req, res) {
        try {
            const tips = await additionsServices.getAllTips();
            res.json(tips);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async createTip(req, res) {
        try {
            const tip = await additionsServices.createTip(req.body);
            res.status(201).json(tip);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    async updateTip(req, res) {
        try {
            const updatedTip = await additionsServices.updateTip(req.params.id, req.body);
            res.json(updatedTip);
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    async deleteTip(req, res) {
        try {
            const deletedTip = await additionsServices.deleteTip(req.params.id);
            res.json({ message: 'Tip deleted successfully' });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async uploadImage(req, res) {
        upload.single('image')(req, res, (err) => {
            if (err) {
                return res.status(400).json({ message: err.message });
            }

            if (!req.file) {
                return res.status(400).json({ message: 'No file uploaded.' });
            }

            // Construct the URL to access the image
            const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
            
            res.status(200).json({ imageUrl });
        });
    }
}

module.exports = new AdditionsController();
