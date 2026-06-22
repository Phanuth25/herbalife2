const express = require('express');
const router = express.Router();
const invoiceController = require('../controller/invoiceController');
const verifyToken = require('../middleware/auth');

router.get('/getitem/:id', invoiceController.getItems);
router.post('/postitem', invoiceController.postItem);
router.delete('/deleteitem/:product', verifyToken, invoiceController.deleteItem);
router.patch('/postquantity', verifyToken, invoiceController.updateQuantity);

module.exports = router;
