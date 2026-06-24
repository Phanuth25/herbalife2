import { Router } from 'express';
const router = Router();
import { login, refresh, registerUser } from '../controller/authController.js';

router.post('/login', login);
router.post('/refresh', refresh);
router.post('/register2', registerUser);

export default router;
