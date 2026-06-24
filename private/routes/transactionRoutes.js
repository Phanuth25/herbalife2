import { Router } from 'express';
const router = Router();
import { saveTransaction, updateTransaction, getTransactions } from '../controller/transactionController.js';

router.post('/save-transaction', saveTransaction);
router.patch('/update-transaction/:md5', updateTransaction);
router.get('/transaction/:userid', getTransactions);

export default router;
