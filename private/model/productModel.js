import db from './db.js';

const Product = {
    selectById: (id, callback) => {
        const sql = "SELECT * FROM products WHERE id = ?";
        db.query(sql, [id], callback);
    },
    selectAll: (callback) => {
        const sql = "SELECT * FROM products";
        db.query(sql, callback);
    },
    create: (data, callback) => {
        const { name, price, point, image } = data;
        const sql = "INSERT INTO products (name, price,point, image) VALUES (?, ?, ?, ?)";
        db.query(sql, [name, price, point, image], callback);
    },
    delete: (id, callback) => {
        const sql = "DELETE FROM products WHERE id = ?";
        db.query(sql, [id], callback);
    },
    update: (id, data, callback) => {
        const { name, price, point, image } = data;
        const sql = "UPDATE products SET name = ?, price = ?, point = ?, image = ? WHERE id = ?";
        db.query(sql, [name, price, point, image, id], callback);
    }
};

export default Product;
