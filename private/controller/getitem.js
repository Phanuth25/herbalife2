const express = require('express');
const router = express.Router();
const db = require('../model/db');

router.get('/getitem/:id', (req, res) => {
    const userId = req.params.id;

    const sql = `
            SELECT
                inv.id,
                p.name,
                inv.product,
                inv.quantity,
                inv.total,
                inv.point,
                inv.datetime
            FROM invoices inv
            INNER JOIN products p ON inv.product = p.id
            WHERE inv.userid = ?
        `;

    db.query(sql, [userId], (err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }

        // Fix: Return 200 even if results are empty (empty cart is not an error)
        res.status(200).json({
            success: true,
            message: results.length > 0 ? "Cart loaded" : "Cart is empty",
            data: results
        });
    });
});

module.exports = router;