const db = require('./db');

const Info = {
    getProfileById: (id, callback) => {
        const sql = `
            SELECT i.id, i.name, i.address, i.phone, i.email, i.point, i.photo, p.position, p.discount 
            FROM users u 
            INNER JOIN infos i ON u.userids = i.id 
            INNER JOIN positions p ON p.id = i.position  
            WHERE i.id = ?
        `;
        db.query(sql, [id], callback);
    },

    create: (data, callback) => {
        const { name, address, phone, email, point, position, imageUrl } = data;
        const sql = "INSERT INTO infos (name, address, phone, email, point, position, photo) VALUES (?, ?, ?, ?, ?, ?, ?)";
        db.query(sql, [name, address, phone, email, point, position, imageUrl], callback);
    },

    updatePhoto: (id, imageUrl, callback) => {
        const sql = "UPDATE infos SET photo = ? WHERE id = ?";
        db.query(sql, [imageUrl, id], callback);
    },

    updatePoints: (id, pointChange, isAddition, callback) => {
        const operator = isAddition ? '+' : '-';
        const sql = `UPDATE infos SET point = point ${operator} ? WHERE id = ?`;
        db.query(sql, [pointChange, id], callback);
    }
};

module.exports = Info;
