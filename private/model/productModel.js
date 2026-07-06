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
        const { name, price, point, image_url } = data;
        const sql = "INSERT INTO products (name, price,point, image_url) VALUES (?, ?, ?, ?)";
        db.query(sql, [name, price, point, image_url], callback);
    },
    delete: (id, callback) => {
        const sql = "DELETE FROM products WHERE id = ?";
        db.query(sql, [id], callback);
    },
    update: (data, callback) => {
        const { name, price, point, image_url, id } = data;
        const sql = "UPDATE products SET name = ?, price = ?, point = ?, image_url = ? WHERE id = ?";
        db.query(sql, [name, price, point, image_url, id], callback);
    }
};

export default Product;
