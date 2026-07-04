import { Router } from 'express';
const router = Router();
import { 
    getItems, 
    postItem, 
    deleteItem, 
    updateQuantity, 
    markAsPurchasedController, 
    selectPurchased 
} from '../controller/invoiceController.js';
import verifyToken from '../middleware/auth.js';

router.get('/getitem/:userid', getItems);
router.post('/postitem', postItem);
router.delete('/deleteitem/:product', verifyToken, deleteItem);
router.patch('/postquantity', verifyToken, updateQuantity);
router.patch('/markaspurchased', verifyToken, markAsPurchasedController);
router.get('/selectpurchased', selectPurchased);

export default router;
