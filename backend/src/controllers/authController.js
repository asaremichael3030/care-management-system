const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db/pool');
const { log } = require('../services/auditService');
const {
  isValidEmail,
  isValidPassword,
  cleanString,
} = require('../utils/validation');

// POST /api/auth/login
async function login(req, res, next) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res
        .status(400)
        .json({ message: 'Email and password are required.' });
    }

    if (!isValidEmail(email)) {
      return res
        .status(400)
        .json({ message: 'Please enter a valid email address.' });
    }

    const result = await pool.query(
      'SELECT id, first_name, last_name, email, phone, password_hash, role, status FROM users WHERE email = $1',
      [email.trim().toLowerCase()],
    );

    if (result.rowCount === 0) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const user = result.rows[0];

    if (user.status !== 'active') {
      return res.status(403).json({ message: 'Account is not active.' });
    }

    const passwordMatches = await bcrypt.compare(password, user.password_hash);
    if (!passwordMatches) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1d' },
    );

    log(req, {
      action: 'login',
      entityType: 'user',
      entityId: user.id,
      description: `${user.email} logged in as ${user.role}`,
    });

    res.json({
      token,
      user: {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        status: user.status,
      },
    });
  } catch (error) {
    next(error);
  }
}

// GET /api/auth/profile
async function getProfile(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT id, first_name, last_name, email, phone, role, status FROM users WHERE id = $1',
      [req.user.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PUT /api/auth/profile
async function updateProfile(req, res, next) {
  try {
    const { first_name, last_name, phone } = req.body;

    const result = await pool.query(
      `UPDATE users SET
         first_name = COALESCE($1, first_name),
         last_name = COALESCE($2, last_name),
         phone = COALESCE($3, phone),
         updated_at = NOW()
       WHERE id = $4
       RETURNING id, first_name, last_name, email, phone, role, status`,
      [
        cleanString(first_name, 100),
        cleanString(last_name, 100),
        cleanString(phone, 30),
        req.user.id,
      ],
    );

    log(req, {
      action: 'update',
      entityType: 'user',
      entityId: req.user.id,
      description: 'Updated own profile',
    });

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// POST /api/auth/change-password
async function changePassword(req, res, next) {
  try {
    const { current_password, new_password } = req.body;

    if (!current_password || !new_password) {
      return res
        .status(400)
        .json({ message: 'Current and new password are required.' });
    }

    if (!isValidPassword(new_password)) {
      return res.status(400).json({
        message:
          'New password must be at least 8 characters and include a letter and a number.',
      });
    }

    const result = await pool.query(
      'SELECT password_hash FROM users WHERE id = $1',
      [req.user.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const matches = await bcrypt.compare(
      current_password,
      result.rows[0].password_hash,
    );
    if (!matches) {
      return res
        .status(400)
        .json({ message: 'Current password is incorrect.' });
    }

    const hash = await bcrypt.hash(new_password, 10);
    await pool.query(
      'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
      [hash, req.user.id],
    );

    log(req, {
      action: 'update',
      entityType: 'user',
      entityId: req.user.id,
      description: 'Changed own password',
    });

    res.json({ message: 'Password changed.' });
  } catch (error) {
    next(error);
  }
}

module.exports = { login, getProfile, updateProfile, changePassword };