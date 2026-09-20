require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('./pool');

// Creates the first Administrator account from values in .env.
async function seedAdmin() {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  const firstName = process.env.ADMIN_FIRST_NAME || 'Admin';
  const lastName = process.env.ADMIN_LAST_NAME || 'User';

  if (!email || !password) {
    console.error('Set ADMIN_EMAIL and ADMIN_PASSWORD in .env first.');
    process.exit(1);
  }

  const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
  if (existing.rowCount > 0) {
    console.log('Admin already exists. Skipping.');
    await pool.end();
    return;
  }

  const hash = await bcrypt.hash(password, 10);
  await pool.query(
    `INSERT INTO users (first_name, last_name, email, password_hash, role, status)
     VALUES ($1, $2, $3, $4, 'Administrator', 'active')`,
    [firstName, lastName, email, hash],
  );

  console.log('Admin user created:', email);
  await pool.end();
}

seedAdmin().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});