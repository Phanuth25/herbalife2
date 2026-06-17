const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Get token from "Bearer <token>"

    if (!token) {
        return res.status(401).json({ message: "No token provided" });
    }

    try {
        console.log('JWT_SECRET:', process.env.JWT_SECRET);
        console.log('Token received:', token);
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // attach user info to request
        next(); // proceed to the route handler
    } catch (err) {
            if (err.name === 'TokenExpiredError') {
                return res.status(401).json({ message: "Token expired" }); // ← DioClient catches this
            }
        return res.status(403).json({ message: "Invalid token" });
    }
};

module.exports = verifyToken;