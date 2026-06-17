const express = require('express');
const router = express.Router();
const db = require('../model/db');
 const verifyToken = require('../middleware/auth');
router.patch('/postquantity', verifyToken,(req, res) => {
    const { invoiceid,quantity } = req.body;

    // Get the product linked to this invoice
    const getInvoice = "SELECT product FROM invoices WHERE id = ?";

    db.query(getInvoice, [invoiceid], (err, invoiceResults) => {
        if (err) return res.status(500).json({ error: err.message });

        if (invoiceResults.length === 0) {
            return res.status(404).json({ message: "Invoice not found" });
        }

        const productId = invoiceResults[0].product;

        // Fetch price and point from product
        const getProduct = "SELECT price, point FROM products WHERE id = ?";

        db.query(getProduct, [productId], (err, productResults) => {
            if (err) return res.status(500).json({ error: err.message });

            if (productResults.length === 0) {
                return res.status(404).json({ message: "Product not found" });
            }

            const { price, point } = productResults[0];
            const total = price * quantity;
            const calculatedPoint = point * quantity;

            // Update the invoice with quantity, total, point
            const updateSql = "UPDATE invoices SET quantity = ?, total = ?, point = ? WHERE id = ?";

            db.query(updateSql, [quantity, total, calculatedPoint, invoiceid], (err) => {
                if (err) return res.status(500).json({ error: err.message });

                res.status(200).json({
                    success: true,
                    message: "Quantity updated and total calculated",
                    invoiceid: parseInt(invoiceid),
                    quantity,
                    total,
                    point: calculatedPoint,
                });
                console.log(invoiceid);
            });
        });
    });
});

module.exports = router;