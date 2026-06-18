require('dotenv').config({ path: './private/.env' });
const express = require('express');
const router = express.Router();
const db = require('../model/db');
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET;
const REFRESH_SECRET = process.env.REFRESH_SECRET;
const bcrypt = require('bcrypt');

router.use(express.json());

router.post('/login', (req, res) => {
    const { userid, password } = req.body; 
    const sql = "SELECT * FROM users WHERE userid = ?";

    db.query(sql, [userid], async (err, results) => {
        if (err) return res.status(500).json({ error: err.message });

        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: "User ID not found"
            });
        }

        const user = results[0];
        const dbPassword = String(user.password).trim();
        const inputPassword = String(password).trim();
        
        const isMatch = await bcrypt.compare(inputPassword, dbPassword);
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: "Incorrect password"
            });
        }

        const token = jwt.sign(
            { id: user.id, userid: user.userid },
            JWT_SECRET,
            { expiresIn: '15m' }
        );

        const refreshtoken = jwt.sign(
            { id: user.id, userid: user.userid },
            REFRESH_SECRET,
            { expiresIn: '7d' }
        );

        const updateSql = "UPDATE users SET refresh_token = ? WHERE id = ?";
        db.query(updateSql, [refreshtoken, user.id], (updErr) => {
            if (updErr) return res.status(500).json({ error: "Failed to save session" });

            res.status(200).json({
                success: true,
                message: 'Login successful',
                token: token,
                refreshToken: refreshtoken,
                infoId: user.userids // Added this to link to the infos table correctly
            });
        });
    });
});

router.post('/refresh', (req, res) => {
    const { token } = req.body;
    if (!token) return res.status(401).json({ message: "Refresh Token Required" });

    jwt.verify(token, REFRESH_SECRET, (err, decoded) => {
        if (err) return res.status(403).json({ message: "Invalid Refresh Token" });

        const sql = "SELECT * FROM users WHERE id = ? AND refresh_token = ?";
        db.query(sql, [decoded.id, token], (dbErr, results) => {
            if (dbErr || results.length === 0) {
                return res.status(403).json({ message: "Token revoked or user not found" });
            }

            const user = results[0];
            const newAccessToken = jwt.sign(
                { id: user.id, userid: user.userid },
                JWT_SECRET,
                { expiresIn: '15m' }
            );

            res.json({ token: newAccessToken, accessToken: newAccessToken });
        });
    });
});

module.exports = router;