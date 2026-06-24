import User from '../model/userModel.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
const { sign, verify } = jwt;
const { compare, hash } = bcrypt;

const JWT_SECRET = process.env.JWT_SECRET;
const REFRESH_SECRET = process.env.REFRESH_SECRET;
const saltRounds = 12;

export function login(req, res) {
    const { userid, password } = req.body;
    User.findByUserId(userid, async (err, results) => {
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

        const isMatch = await compare(inputPassword, dbPassword);
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: "Incorrect password"
            });
        }

        const token = sign(
            { id: user.id, userid: user.userid },
            JWT_SECRET,
            { expiresIn: '15m' }
        );

        const refreshtoken = sign(
            { id: user.id, userid: user.userid },
            REFRESH_SECRET,
            { expiresIn: '7d' }
        );

        User.updateRefreshToken(user.id, refreshtoken, (updErr) => {
            if (updErr) return res.status(500).json({ error: "Failed to save session" });

            res.status(200).json({
                success: true,
                message: 'Login successful',
                token: token,
                refreshToken: refreshtoken,
                infoId: user.userids
            });
        });
    });
}

export function refresh(req, res) {
    const { token } = req.body;
    if (!token) return res.status(401).json({ message: "Refresh Token Required" });

    verify(token, REFRESH_SECRET, (err, decoded) => {
        if (err) return res.status(403).json({ message: "Invalid Refresh Token" });

        User.findByRefreshToken(decoded.id, token, (dbErr, results) => {
            if (dbErr || results.length === 0) {
                return res.status(403).json({ message: "Token revoked or user not found" });
            }

            const user = results[0];
            const newAccessToken = sign(
                { id: user.id, userid: user.userid },
                JWT_SECRET,
                { expiresIn: '15m' }
            );

            res.json({ token: newAccessToken, accessToken: newAccessToken });
        });
    });
}

export function registerUser(req, res) {
    const { userid, password, userids } = req.body;

    if (!userid || !password || !userids) {
        return res.status(400).json({ success: false, message: "Missing required fields" });
    }

    User.findByUserId(userid, async (err, results) => {
        if (err) return res.status(500).json({ success: false, message: err.message });

        if (results.length > 0) {
            return res.status(409).json({
                success: false,
                message: "User ID already exists"
            });
        }

        try {
            const hashedPassword = await hash(String(password), saltRounds);
            User.create(userid, hashedPassword, userids, (err, insertResult) => {
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
}
