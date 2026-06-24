import { Router } from 'express';
const router = Router();
import { getProfile, registerInfo, updatePhotoController, plusPoints, removePoints } from '../controller/profileController.js';
import verifyToken from '../middleware/auth.js';
import multer, { memoryStorage } from 'multer';
const storage = memoryStorage();
const upload = multer({ storage });

router.get('/profile/:userId', getProfile);
router.post('/register', upload.single('image'), registerInfo);
router.post('/upload-image', verifyToken, upload.single('image'), updatePhotoController);
router.patch('/plusinfos', verifyToken, plusPoints);
router.patch('/removeinfos', verifyToken, removePoints);

export default router;
