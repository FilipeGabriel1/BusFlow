const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: 'LightMobile123',
  database: 'busflow',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4'
});

// Teste de conexão
pool.getConnection()
  .then(conn => {
    console.log('✅ Conectado ao MySQL - banco: busflow');
    conn.release();
  })
  .catch(err => {
    console.error('❌ Erro ao conectar ao MySQL:', err.message);
  });

module.exports = pool;
