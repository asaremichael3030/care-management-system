const { Pool } = require('pg');
require('dotenv').config();

// If DATABASE_URL is set (production on Render), use it with SSL.
// Otherwise fall back to the individual DB_* variables (local development).
const useConnectionString = !!process.env.DATABASE_URL;

const pool = useConnectionString
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    })
  : new Pool({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

module.exports = pool;