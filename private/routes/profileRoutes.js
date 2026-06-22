const express = require('express');
const router = express.Router();
const profileController = require('../controller/profileController');
const verifyToken = require('../middleware/auth');
const multer = require('multer');
const storage = multer.memoryStorage();
const upload = multer({ storage });

router.get('/profile/:userId', profileController.getProfile);
router.post('/register', upload.single('image'), profileController.registerInfo);
router.post('/upload-image', verifyToken, upload.single('image'), profileController.updatePhoto);
router.patch('/plusinfos', verifyToken, profileController.plusPoints);
router.patch('/removeinfos', verifyToken, profileController.removePoints);

module.exports = router;
