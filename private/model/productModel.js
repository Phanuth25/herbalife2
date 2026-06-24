import db from './db.js';

const Product = {
    findById: (id, callback) => {
        const sql = "SELECT * FROM products WHERE id = ?";
        db.query(sql, [id], callback);
    }
};

export default Product;
