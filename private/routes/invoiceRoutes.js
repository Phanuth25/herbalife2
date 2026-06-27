import { Router } from 'express';
const router = Router();
import { 
    getItems, 
    postItem, 
    deleteItem, 
    updateQuantity, 
    markAsPurchasedByUserController, 
    selectPurchased 
} from '../controller/invoiceController.js';
import verifyToken from '../middleware/auth.js';

router.get('/getitem/:id', getItems);
router.post('/postitem', postItem);
router.delete('/deleteitem/:product', verifyToken, deleteItem);
router.patch('/postquantity', verifyToken, updateQuantity);
router.patch('/markaspurchased/:userid', verifyToken, markAsPurchasedByUserController);
router.get('/selectpurchased/:userid', verifyToken, selectPurchased);

export default router;
