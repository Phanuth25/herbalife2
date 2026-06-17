const express = require('express');
const router = express.Router();
const db = require('../model/db');

router.post('/save-transaction', (req, res) => {
    const { userid, md5, amount, bill_number, status } = req.body;
    const sql = "INSERT INTO transactions (userid, md5, amount, bill_number, status) VALUES (?, ?, ?, ?, ?)";

    db.query(sql, [userid, md5, amount, bill_number, status], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        res.status(200).json({
            success: true,
            message: "Transaction saved successfully",
            transactionId: results.insertId
        });
    });
});

router.patch('/update-transaction/:md5', (req, res) => {
    const { md5 } = req.params;
    const sql = "UPDATE transactions SET status = 'paid' WHERE md5 = ?";

    db.query(sql, [md5], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        res.status(200).json({
            success: true,
            message: "Transaction updated successfully"
        });
    });
});

router.get('/transaction/:userid', (req, res) => {
    const { userid } = req.params;
    const sql = "SELECT * FROM transactions WHERE userid = ? ORDER BY created_at DESC";

    db.query(sql, [userid], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        res.status(200).json({
            success: true,
            message: "Transactions fetched",
            data: results
        });
    });
});

module.exports = router;