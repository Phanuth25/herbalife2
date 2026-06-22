const db = require('./db');

const Product = {
    findById: (id, callback) => {
        const sql = "SELECT * FROM products WHERE id = ?";
        db.query(sql, [id], callback);
    }
};

module.exports = Product;
