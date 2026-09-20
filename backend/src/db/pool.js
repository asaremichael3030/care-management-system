const { Pool } = require('pg');
require('dotenv').config();

// Shared PostgreSQL connection pool.
const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // Use the full connection string
  ssl: {
    // This is required for connecting to Neon from a cloud host like Render.
    rejectUnauthorized: false,
  },
});

module.exports = pool;  