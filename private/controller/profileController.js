const Info = require('../model/infoModel');
const cloudinary = require('./cloudinary');

exports.getProfile = (req, res) => {
    const userId = req.params.userId;
    Info.getProfileById(userId, (err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }
        if (results.length === 0) {
            return res.status(404).json({ success: false, message: "User profile not found" });
        }
        const info = results[0];
        res.status(200).json({
            success: true,
            message: "Profile loaded",
            ...info,
            email: info.email || "No Email",
            phone: info.phone || "No Phone",
            address: info.address || "No Address",
            name: info.name || "No Name",
            position: info.position || "No Position",
            discount: info.discount || "No Discount",
            photo: info.photo || "No Photo"
        });
    });
};

exports.registerInfo = async (req, res) => {
    const { name, address, phone, email } = req.body;
    if (!name || !email) return res.status(400).json({ error: "Name and Email are required" });
    if (!req.file) return res.status(400).json({ error: "Image file is required" });

    try {
        const result = await new Promise((resolve, reject) => {
            cloudinary.uploader.upload_stream({ folder: 'uploads' }, (error, result) => {
                if (error) reject(error);
                else resolve(result);
            }).end(req.file.buffer);
        });

        const imageUrl = result.secure_url;
        Info.create({ name, address, phone, email, point: 0.0, position: 1, imageUrl }, (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(200).json({ success: true, message: "Registered successfully", userid: results.insertId });
        });
    } catch (error) {
        console.error("Upload Error:", error);
        return res.status(500).json({ error: "Failed to upload image to Cloudinary" });
    }
};

exports.updatePhoto = async (req, res) => {
    const { id } = req.body;
    if (!id || !req.file) return res.status(400).json({ error: "User ID and Image are required" });

    try {
        const result = await new Promise((resolve, reject) => {
            cloudinary.uploader.upload_stream({ folder: 'uploads' }, (error, result) => {
                if (error) reject(error);
                else resolve(result);
            }).end(req.file.buffer);
        });

        Info.updatePhoto(id, result.secure_url, (err) => {
            if (err) return res.status(500).json({ error: err.message });
            res.status(200).json({ success: true, message: "Updated successfully", photo: result.secure_url });
        });
    } catch (error) {
        return res.status(500).json({ error: "Failed to upload image" });
    }
};

exports.plusPoints = (req, res) => {
    const { id, point } = req.body;
    Info.updatePoints(id, point, true, (err, result) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: "Record not found" });
        res.status(200).json({ success: true, message: "Points updated successfully", updated: point });
    });
};

exports.removePoints = (req, res) => {
    const { id, point } = req.body;
    Info.updatePoints(id, point, false, (err, result) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: "Record not found" });
        res.status(200).json({ success: true, message: "Points deducted successfully", point: point });
    });
};
