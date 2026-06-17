const express = require('express');
const router = express.Router();
const db = require('../model/db');
const verifyToken = require('../middleware/auth');
router.post('/postitem', verifyToken,(req, res) => {
    const { userid, product, quantity } = req.body;

    // First get product price and point from products table
    const getProduct = "SELECT price, point FROM products WHERE id = ?";

    db.query(getProduct, [product], (err, results) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: "Product not found" });
        }

        const productData = results[0];
        const total = productData.price * quantity;
        const point = productData.point * quantity;

        // Now insert into invoices with calculated total and point
        const sql = "INSERT INTO invoices (userid, product, quantity, total, point) VALUES (?, ?, ?, ?, ?)";

        db.query(sql, [userid, product, quantity, total, point], (err, insertResults) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }

            res.status(200).json({
                success: true,
                message: "Purchased successfully",
                invoiceId: insertResults.insertId,
                total: total,
                point: point,
            });
        });
    });
});

module.exports = router;