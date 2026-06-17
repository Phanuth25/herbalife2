const express = require('express');
const router = express.Router();
const db = require('../model/db');
const multer = require('multer');
const cloudinary = require('./cloudinary');
 const verifyToken = require('../middleware/auth');
const storage = multer.memoryStorage();
const upload = multer({ storage });
router.use(express.json());

router.patch('/upload', upload.single('image'), verifyToken,async (req, res) => {
    const { id } = req.body; // ✅ get user id from request

    if (!id) {
        return res.status(400).json({ error: "User ID is required" });
    }

    if (!req.file) {
        return res.status(400).json({ error: "Image file is required" });
    }

    try {
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

        const sql = "UPDATE infos SET photo = ? WHERE id = ?"; // ✅ only update this user

        db.query(sql, [imageUrl, id], (err, results) => {
            if (err) return res.status(500).json({ error: err.message });

            res.status(200).json({
                success: true,
                message: "Updated successfully",
                photo: imageUrl, // ✅ return new URL so Flutter can update UI
            });
        });

    } catch (error) {
        console.error("Upload Error:", error);
        return res.status(500).json({ error: "Failed to upload image to Cloudinary" });
    }
});

module.exports = router;