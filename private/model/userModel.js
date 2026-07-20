import db from './db.js';

const User = {
    findByUserId: (userid, callback) => {
        const sql = "SELECT * FROM users WHERE userid = ?";
        db.query(sql, [userid], callback);
    },

    findById: (id, callback) => {
        const sql = "SELECT * FROM users WHERE id = ?";
        db.query(sql, [id], callback);
    },


    findAllUser: (callback) => {
        const sql = `select info.name,info.id,u.role
                     from infos info inner join users u on info.id=u.userids`;
        db.query(sql, callback);
    },
    updateRoletoAdmin: (id, role, callback) => {
        const sql = "UPDATE users SET role = ? WHERE userids = ?";
        db.query(sql, [role, id], callback);
    },
    updateRoletoUser: (id, role, callback) => {
        const sql = "UPDATE users SET role = ? WHERE userids = ?";
        db.query(sql, [role, id], callback);
    },
    updateRefreshToken: (id, token, callback) => {
        const sql = "UPDATE users SET refresh_token = ? WHERE id = ?";
        db.query(sql, [token, id], callback);
    },

    findByRefreshToken: (id, token, callback) => {
        const sql = "SELECT * FROM users WHERE id = ? AND refresh_token = ?";
        db.query(sql, [id, token], callback);
    },

    create: (userid, hashedPassword, userids, callback) => {
        const sql = "INSERT INTO users (userid, password, userids) VALUES (?, ?, ?)";
        db.query(sql, [userid, hashedPassword, userids], callback);
    }
};

export default User;
