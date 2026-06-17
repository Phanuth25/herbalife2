const express = require('express');
const router = express.Router();
const db = require('../model/db');

router.get('/getitem/:id', (req, res) => {
    const userId = req.params.id;

    // Check if the columns match exactly with your database table 'infos'
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

        console.log("Database results for ID " + userId + ":", results);

        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: "User record not found in database"
            });
        }

        const info = results;

        // We use || null to ensure we don't send 'undefined'
        res.status(200).json({
            success: true,
            message: "Cart loaded",
            data: info
        });
    });
});

module.exports = router;
