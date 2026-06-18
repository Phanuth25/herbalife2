const express = require('express');
const router = express.Router();
const db = require('../model/db');
const verifyToken = require('../middleware/auth');

router.get('/profile/:userId', (req, res) => {
    const userId = req.params.userId;

    // Fixed query: search by u.userid (Member ID) instead of i.id
    const sql = `
        SELECT i.id, i.name, i.address, i.phone, i.email, i.point, i.photo, p.position, p.discount 
        FROM users u 
        INNER JOIN infos i ON u.userids = i.id 
        INNER JOIN positions p ON p.id = i.position  
        WHERE i.id = ?
    `;

    db.query(sql, [userId], (err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }

        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: "User profile not found"
            });
        }

        const info = results[0];

        res.status(200).json({
            success: true,
            message: "Profile loaded",
            id: info.id,
            email: info.email || "No Email",
            phone: info.phone || "No Phone",
            address: info.address || "No Address",
            name: info.name || "No Name",
            point: info.point,
            position: info.position || "No Position",
            discount: info.discount || "No Discount",
            photo: info.photo || "No Photo"
        });
    });
});

module.exports = router;