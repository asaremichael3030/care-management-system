const pool = require('./pool');

// Simple check that the database connection works.
async function testConnection() {
  try {
    const result = await pool.query('SELECT NOW() AS now');
    console.log('Database connected. Server time:', result.rows[0].now);
    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error('Database connection failed:', error.message);
    await pool.end();
    process.exit(1);
  }
}

testConnection();