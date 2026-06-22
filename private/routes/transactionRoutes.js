const express = require('express');
const router = express.Router();
const transactionController = require('../controller/transactionController');

router.post('/save-transaction', transactionController.saveTransaction);
router.patch('/update-transaction/:md5', transactionController.updateTransaction);
router.get('/transaction/:userid', transactionController.getTransactions);

module.exports = router;
