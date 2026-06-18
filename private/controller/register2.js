const express = require('express');
const router = express.Router();
const db = require('../model/db');
const bcrypt = require('bcrypt');
const saltRounds = 12;

router.use(express.json());

router.post('/register2', (req, res) => {
    const { userid, password, userids } = req.body;

    if (!userid || !password || !userids) {
        return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    const checkSql = "SELECT * FROM users WHERE userid = ?";
    db.query(checkSql, [userid], async (err, results) => {
        if (err) return res.status(500).json({ success: false, message: err.message });

        if (results.length > 0) {
            return res.status(409).json({ 
                success: false, 
                message: "User ID already exists" 
            });
        }

        try {
            const hashedPassword = await bcrypt.hash(String(password), saltRounds);
            const insertSql = "INSERT INTO users (userid, password, userids) VALUES (?, ?, ?)";
            
            db.query(insertSql, [userid, hashedPassword, userids], (err, insertResult) => {
                if (err) return res.status(500).json({ success: false, message: err.message });

                res.status(200).json({
                    success: true,
                    message: "Registered successfully",
                    id: insertResult.insertId
                });
            });
        } catch (hashError) {
            res.status(500).json({ success: false, message: "Error securing password" });
        }
    });
});

module.exports = router;
