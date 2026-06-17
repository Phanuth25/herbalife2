    const express = require('express');
    const router = express.Router();
    const db = require('../model/db');
    const verifyToken = require('../middleware/auth');
    router.get('/profile/:id', verifyToken , (req, res) => {
        const userId = req.params.id;

        // Check if the columns match exactly with your database table 'infos'
        console.log(userId);
        const sql = "SELECT i.id,i.name, i.address, i.phone, i.email , i.point,i.photo, p.position,p.discount FROM users u INNER JOIN infos i ON u.userids = i.id INNER JOIN positions p ON p.id = i.position  WHERE i.id = ?";

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

            const info = results[0];

            // We use || null to ensure we don't send 'undefined'
            res.status(200).json({
                success: true,
                message: "Profile loaded",
                id: info.id || "No ID",
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
