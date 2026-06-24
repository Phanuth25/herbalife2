import { Router } from 'express';
const router = Router();
import { getItems, postItem, deleteItem, updateQuantity, markAsPurchasedByUserController } from '../controller/invoiceController.js';
import verifyToken from '../middleware/auth.js';

router.get('/getitem/:id', getItems);
router.post('/postitem', postItem);
router.delete('/deleteitem/:product', verifyToken, deleteItem);
router.patch('/postquantity', verifyToken, updateQuantity);
router.put('/markaspurchased/:userid', verifyToken, markAsPurchasedByUserController);

export default router;
