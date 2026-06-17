require('dotenv').config({ path: './private/.env' });
const mysql = require('mysql2');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

pool.getConnection((err, connection) => {
  if (err) {
    console.error('Database connection error: ', err.message);
  } else {
    if (connection) connection.release();
    console.log('Database connected successfully!');
  }
});

module.exports = pool;