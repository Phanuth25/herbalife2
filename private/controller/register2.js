const express = require('express');
const router = express.Router();
const db = require('../model/db');
const bcrypt = require('bcrypt');
const saltRounds = 12; // Recommended minimum for production
router.use(express.json());

router.post('/register2', (req, res) => {
    const { userid, password, userids } = req.body;

    // 1. Corrected the parameters: only pass [userid] for one '?'
    const checkSql = "SELECT * FROM users WHERE userid = ?";

    db.query(checkSql, [userid], async (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        // 2. results is the array. If length > 0, the user exists.
        if (results.length > 0) {
            return res.status(409).json({ // 409 is 'Conflict'
                success: false,
                message: "User ID already exists"
            });
        }

        // 3. If we reached here, the user doesn't exist. Proceed to INSERT.
        const insertSql = "INSERT INTO users (userid, password, userids) VALUES (?, ?, ?)";
         passwords = String(password);
         const hashedPassword = await bcrypt.hash(passwords, saltRounds);
        db.query(insertSql, [userid, hashedPassword, userids], (err, insertResult) => {
            if (err) return res.status(500).json({ error: err.message });

            res.status(200).json({
                success: true,
                message: "Registered successfully",
                // Note: userids is from your req.body,
                // but usually you want the DB generated ID: insertResult.insertId
                id: insertResult.insertId
            });
        });
    });
});

module.exports = router;575