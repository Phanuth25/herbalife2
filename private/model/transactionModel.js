import db from './db.js';

const Transaction = {
    create: (data, callback) => {
        const { userid, md5, amount, bill_number, status } = data;
        const sql = "INSERT INTO transactions (userid, md5, amount, bill_number, status) VALUES (?, ?, ?, ?, ?)";
        db.query(sql, [userid, md5, amount, bill_number, status], callback);
    },

    updateStatusByMd5: (md5, status, callback) => {
        const sql = "UPDATE transactions SET status = ? WHERE md5 = ?";
        db.query(sql, [status, md5], callback);
    },

    getByUserId: (userid, callback) => {
        const sql = "SELECT * FROM transactions WHERE userid = ? ORDER BY created_at DESC";
        db.query(sql, [userid], callback);
    }
};

export default Transaction;
