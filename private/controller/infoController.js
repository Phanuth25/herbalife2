import Info from '../model/infoModel.js';
import User from '../model/userModel.js';

export const updatePoints = (req, res) => {
    const { userids, pointChange} = req.body;
    if (userids === undefined || pointChange === undefined) {
        return res.status(400).json({ error: "id, pointChange and isAddition are required" });
    }
    Info.updatePoints(userids, pointChange,(err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json({ 
            success: true, 
            message: "Points updated successfully",
            affectedRows: results.affectedRows 
        });
    });
};

export const getAllUsers = (req, res) => {
    User.findAllUser((err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json(results);
    });
};

export const updateRoleToAdmin = (req, res) => {
    const { id } = req.body;
    if (!id) {
        return res.status(400).json({ error: "User ID is required" });
    }
    User.updateRoletoAdmin(id, 'admin', (err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json({ success: true, message: "Role updated to admin" });
    });
};

export const updateRoleToUser = (req, res) => {
    const { id } = req.body;
    if (!id) {
        return res.status(400).json({ error: "User ID is required" });
    }
    User.updateRoletoUser(id, 'member', (err, results) => {
        if (err) {
            console.error("Database Error:", err.message);
            return res.status(500).json({ error: err.message });
        }
        res.status(200).json({ success: true, message: "Role updated to user" });
    });
};
