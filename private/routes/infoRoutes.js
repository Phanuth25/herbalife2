import { Router } from 'express';
const router = Router();
import { updatePoints, getAllUsers, updateRoleToAdmin, updateRoleToUser } from '../controller/infoController.js';
import verifyToken from '../middleware/auth.js';

router.patch('/updatepoints', verifyToken, updatePoints);
router.get('/users', verifyToken, getAllUsers);
router.patch('/update-role-admin',  updateRoleToAdmin);
router.patch('/update-role-user',  updateRoleToUser);

export default router;
