import Invoice from '../model/invoiceModel.js';
import Product from '../model/productModel.js';
import db from '../model/db.js';

export function getItems(req, res) {
    const userId = req.params.id;
    Invoice.getByUserId(userId, (err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json({
            success: true,
            message: results.length > 0 ? "Cart loaded" : "Cart is empty",
            data: results
        });
    });
}

export function postItem(req, res) {
    const { userid, product, quantity } = req.body;
    Product.findById(product, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ message: "Product not found" });

        const productData = results[0];
        const total = productData.price * quantity;
        const point = productData.point * quantity;

        Invoice.create({ userid, product, quantity, total, point }, (err, insertResults) => {
            if (err) return res.status(500).json({ error: err.message });

            res.status(200).json({
                success: true,
                message: "Purchased successfully",
                invoiceId: insertResults.insertId,
                total: total,
                point: point,
            });
        });
    });
}

export function deleteItem(req, res) {
    const product = req.params.product;
    Invoice.delete(product, (err, results) => {
        if (err) {
            console.error("Database error:", err);
            return res.status(500).json({ error: "Database error" });
        }
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: "Item not found" });
        }
        res.status(200).json({
            success: true,
            message: "Removed successfully",
        });
    });
}

export function updateQuantity(req, res) {
    const { invoiceid, quantity } = req.body;

    const getInvoice = "SELECT product FROM invoices WHERE id = ?";

    db.query(getInvoice, [invoiceid], (err, invoiceResults) => {
        if (err) return res.status(500).json({ error: err.message });
        if (invoiceResults.length === 0) return res.status(404).json({ message: "Invoice not found" });

        const productId = invoiceResults[0].product;
        Product.findById(productId, (err, productResults) => {
            if (err) return res.status(500).json({ error: err.message });
            if (productResults.length === 0) return res.status(404).json({ message: "Product not found" });

            const { price, point } = productResults[0];
            const total = price * quantity;
            const calculatedPoint = point * quantity;

            Invoice.updateQuantity(invoiceid, quantity, total, calculatedPoint, (err) => {
                if (err) return res.status(500).json({ error: err.message });

                res.status(200).json({
                    success: true,
                    message: "Quantity updated and total calculated",
                    invoiceid: parseInt(invoiceid),
                    quantity,
                    total,
                    point: calculatedPoint,
                });
            });
        });
    });
}

export function markAsPurchasedByUserController(req, res) {
    const userid = req.params.userid;
    if (!userid) {
        return res.status(400).json({ message: "User ID is required" });
    }

    Invoice.markAsPurchased(userid, (err, result) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "No unpurchased invoices found for this user" });
        }

        return res.status(200).json({
            message: "successfully",
            updated: result.affectedRows
        });
    });
}

export function selectPurchased(req, res) {
    const userid = req.params.userid;

    Invoice.selectPurchased(userid, (err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({
                success: false,
                message: "Failed to load purchased items",
                data: null
            });
        }

        if (!Array.isArray(results)) {
            console.error("Unexpected result shape from selectPurchased:", results);
            return res.status(500).json({
                success: false,
                message: "Failed to load purchased items",
                data: null
            });
        }

        return res.status(200).json({
            success: true,
            message: results.length > 0 ? "Purchased items loaded" : "No purchased items found",
            data: results
        });
    });
}
