const express = require('express');
const router = express.Router();
const db = require('../model/db');
 const verifyToken = require('../middleware/auth');
// Changed route from '/deleteitem/:product' to '/:product' 
// because it's already mounted at '/api/deleteitem' in server.js
router.delete('/:product', verifyToken, (req, res) => {
    const product = req.params.product; // Get ID from URL
    const sql = "DELETE FROM invoices WHERE id = ?";

    db.query(sql, [product], (err, results) => {
        if (err) {
            console.error("Database error:", err);
            return res.status(500).json({ error: "Database error" });
        }

        // Check if anything was actually deleted
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: "Item not found" });
        }

        res.status(200).json({
            success: true,
            message: "Removed successfully",
        });
    });
});

module.exports = router;