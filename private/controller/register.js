const express = require('express');
const router = express.Router();
const db = require('../model/db');
const multer = require('multer');
const cloudinary = require('./cloudinary');

const storage = multer.memoryStorage();
const upload = multer({ storage });
router.use(express.json());

router.post('/register', upload.single('image'), async (req, res) => {
    const { name, address, phone, email } = req.body;

    // 1. Validation
    if (!name || !email) {
        return res.status(400).json({ error: "Name and Email are required" });
    }

    if (!req.file) {
        return res.status(400).json({ error: "Image file is required" });
    }

    try {
        // 2. Upload image to Cloudinary
        const result = await new Promise((resolve, reject) => {
            cloudinary.uploader.upload_stream(
                { folder: 'uploads' },
                (error, result) => {
                    if (error) reject(error);
                    else resolve(result);
                }
            ).end(req.file.buffer);
        });

        const imageUrl = result.secure_url;

         const  point = 0.0;
         const  position = 1;
        // 3. Database Query (Must be inside the try block or use the imageUrl here)
        const sql = "INSERT INTO infos (name, address, phone, email, point, position ,photo ) VALUES (?, ?, ?, ?, ?, ?, ?)";

        db.query(sql, [name, address, phone, email, point, position, imageUrl], (err, results) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }

            res.status(200).json({
                success: true,
                message: "Registered successfully",
                userid: results.insertId
            });
        });

    } catch (error) {
        console.error("Upload Error:", error);
        return res.status(500).json({ error: "Failed to upload image to Cloudinary" });
    }
});

module.exports = router;