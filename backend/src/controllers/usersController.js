const bcrypt = require('bcryptjs');
const pool = require('../db/pool');
const { log } = require('../services/auditService');
const {
  isValidEmail,
  isValidPassword,
  cleanString,
} = require('../utils/validation');

const ALLOWED_ROLES = [
  'Administrator',
  'Manager / Senior Carer',
  'Care Worker',
  'Family Member',
];

const ALLOWED_STATUSES = ['active', 'inactive', 'invited', 'suspended'];

// GET /api/users
async function listUsers(req, res, next) {
  try {
    const { role, status, search } = req.query;
    const params = [];
    const conditions = [];

    if (role) {
      params.push(role);
      conditions.push(`role = $${params.length}`);
    }
    if (status) {
      params.push(status);
      conditions.push(`status = $${params.length}`);
    }
    if (search) {
      params.push(`%${search.trim().toLowerCase()}%`);
      conditions.push(
        `(LOWER(email) LIKE $${params.length} OR LOWER(first_name) LIKE $${params.length} OR LOWER(last_name) LIKE $${params.length})`,
      );
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `SELECT id, first_name, last_name, email, phone, role, status,
              created_at, updated_at
       FROM users
       ${where}
       ORDER BY role, last_name, first_name`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/users/:id
async function getUser(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT id, first_name, last_name, email, phone, role, status,
              created_at, updated_at
       FROM users WHERE id = $1`,
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PUT /api/users/:id - updates non-password fields.
async function updateUser(req, res, next) {
  try {
    const { first_name, last_name, phone, role, status } = req.body;
    const { id } = req.params;

    if (role && !ALLOWED_ROLES.includes(role)) {
      return res.status(400).json({ message: 'Invalid role.' });
    }
    if (status && !ALLOWED_STATUSES.includes(status)) {
      return res.status(400).json({ message: 'Invalid status.' });
    }

    // Do not allow the last Administrator to be demoted.
    if (role && role !== 'Administrator') {
      const admins = await pool.query(
        "SELECT COUNT(*)::int AS c FROM users WHERE role = 'Administrator' AND id <> $1",
        [id],
      );
      if (admins.rows[0].c === 0) {
        return res
          .status(400)
          .json({ message: 'Cannot change the last Administrator role.' });
      }
    }

    const result = await pool.query(
      `UPDATE users SET
         first_name = COALESCE($1, first_name),
         last_name = COALESCE($2, last_name),
         phone = COALESCE($3, phone),
         role = COALESCE($4, role),
         status = COALESCE($5, status),
         updated_at = NOW()
       WHERE id = $6
       RETURNING id, first_name, last_name, email, phone, role, status, created_at, updated_at`,
      [
        cleanString(first_name, 100),
        cleanString(last_name, 100),
        cleanString(phone, 30),
        role || null,
        status || null,
        id,
      ],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    log(req, {
      action: 'update',
      entityType: 'user',
      entityId: Number(id),
      description: `Updated user id ${id}`,
    });

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// POST /api/users/:id/reset-password - Admin sets a new password.
async function resetPassword(req, res, next) {
  try {
    const { password } = req.body;
    const { id } = req.params;

    if (!isValidPassword(password)) {
      return res.status(400).json({
        message:
          'Password must be at least 8 characters and include a letter and a number.',
      });
    }

    const hash = await bcrypt.hash(password, 10);
    const result = await pool.query(
      `UPDATE users SET password_hash = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING id, email`,
      [hash, id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    log(req, {
      action: 'update',
      entityType: 'user',
      entityId: Number(id),
      description: `Reset password for user ${result.rows[0].email}`,
    });

    res.json({ message: 'Password updated.' });
  } catch (error) {
    next(error);
  }
}

// DELETE /api/users/:id
async function deleteUser(req, res, next) {
  try {
    const { id } = req.params;

    // Do not allow deleting yourself.
    if (Number(id) === req.user.id) {
      return res
        .status(400)
        .json({ message: 'You cannot delete your own account.' });
    }

    // Do not allow deleting the last Administrator.
    const admins = await pool.query(
      "SELECT COUNT(*)::int AS c FROM users WHERE role = 'Administrator' AND id <> $1",
      [id],
    );
    if (admins.rows[0].c === 0) {
      const target = await pool.query(
        'SELECT role FROM users WHERE id = $1',
        [id],
      );
      if (target.rowCount > 0 && target.rows[0].role === 'Administrator') {
        return res
          .status(400)
          .json({ message: 'Cannot delete the last Administrator.' });
      }
    }

    const result = await pool.query(
      'DELETE FROM users WHERE id = $1 RETURNING email',
      [id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    log(req, {
      action: 'delete',
      entityType: 'user',
      entityId: Number(id),
      description: `Deleted user ${result.rows[0].email}`,
    });

    res.json({ message: 'User deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listUsers,
  getUser,
  updateUser,
  resetPassword,
  deleteUser,
};