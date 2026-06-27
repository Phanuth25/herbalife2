import db from './db.js';

const Invoice = {
    getByUserId: (userId, callback) => {
        const sql = `
            SELECT
                inv.id,
                inv.userid,
                p.name,
                inv.product,
                inv.quantity,
                inv.total,
                inv.point,
                inv.datetime
            FROM invoices inv
            INNER JOIN products p ON inv.product = p.id
            WHERE inv.userid = ? AND (inv.ispurchase != 1 OR inv.ispurchase IS NULL)
        `;
        db.query(sql, [userId], callback);
    },

    create: (data, callback) => {
        const { userid, product, quantity, total, point } = data;
        const sql = "INSERT INTO invoices (userid, product, quantity, total, point) VALUES (?, ?, ?, ?, ?)";
        db.query(sql, [userid, product, quantity, total, point], callback);
    },

    delete: (id, callback) => {
        const sql = "DELETE FROM invoices WHERE id = ?";
        db.query(sql, [id], callback);
    },

    updateQuantity: (id, quantity, total, point, callback) => {
        const sql = "UPDATE invoices SET quantity = ?, total = ?, point = ? WHERE id = ?";
        db.query(sql, [quantity, total, point, id], callback);
    },

    markAsPurchased: (userid, callback) => {
        const sql = "UPDATE invoices SET ispurchase = 1 WHERE userid = ?";
        db.query(sql, [userid], callback);
    },

    selectPurchased: (userid,callback) => {
        const sql = "SELECT * FROM herbalife2.invview where userid = ?";
        db.query(sql, [userid], callback);
    }
};



export default Invoice;
