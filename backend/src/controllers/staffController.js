const bcrypt = require('bcryptjs');
const pool = require('../db/pool');
const { log } = require('../services/auditService');
const {
  isValidEmail,
  isValidPassword,
  cleanString,
} = require('../utils/validation');

const STAFF_ROLES = ['Administrator', 'Manager / Senior Carer', 'Care Worker'];

// Shared SELECT used by listStaff, getStaff and createStaff so the shape
// of the response is always the same.
const STAFF_SELECT = `
  SELECT s.id, s.user_id, s.job_title, s.department,
         s.employment_status, s.hire_date, s.notes,
         u.first_name, u.last_name, u.email, u.phone, u.role,
         u.status AS user_status
  FROM staff s
  JOIN users u ON u.id = s.user_id
`;

async function listStaff(req, res, next) {
  try {
    const { role, status } = req.query;
    const params = [];
    const conditions = [];

    if (role) {
      params.push(role);
      conditions.push(`u.role = $${params.length}`);
    }
    if (status) {
      params.push(status);
      conditions.push(`s.employment_status = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `${STAFF_SELECT} ${where} ORDER BY u.last_name, u.first_name`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function getStaff(req, res, next) {
  try {
    const result = await pool.query(
      `${STAFF_SELECT} WHERE s.id = $1`,
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Staff member not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function createStaff(req, res, next) {
  const client = await pool.connect();
  try {
    const {
      first_name,
      last_name,
      email,
      phone,
      password,
      role,
      job_title,
      department,
      employment_status,
      hire_date,
      notes,
    } = req.body;

    if (!first_name || !last_name || !email || !password || !role) {
      return res.status(400).json({
        message:
          'First name, last name, email, password, and role are required.',
      });
    }

    if (!isValidEmail(email)) {
      return res
        .status(400)
        .json({ message: 'Please enter a valid email address.' });
    }

    if (!isValidPassword(password)) {
      return res.status(400).json({
        message:
          'Password must be at least 8 characters and include a letter and a number.',
      });
    }

    if (!STAFF_ROLES.includes(role)) {
      return res.status(400).json({
        message:
          'Role must be Administrator, Manager / Senior Carer, or Care Worker.',
      });
    }

    await client.query('BEGIN');

    const existing = await client.query(
      'SELECT id FROM users WHERE email = $1',
      [email.trim().toLowerCase()],
    );
    if (existing.rowCount > 0) {
      await client.query('ROLLBACK');
      return res
        .status(409)
        .json({ message: 'A user with this email already exists.' });
    }

    const hash = await bcrypt.hash(password, 10);

    const userResult = await client.query(
      `INSERT INTO users
         (first_name, last_name, email, phone, password_hash, role, status)
       VALUES ($1,$2,$3,$4,$5,$6,'active')
       RETURNING id`,
      [
        cleanString(first_name, 100),
        cleanString(last_name, 100),
        email.trim().toLowerCase(),
        cleanString(phone, 30),
        hash,
        role,
      ],
    );

    const userId = userResult.rows[0].id;

    const staffResult = await client.query(
      `INSERT INTO staff
        (user_id, job_title, department, employment_status, hire_date, notes)
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING id`,
      [
        userId,
        cleanString(job_title, 120),
        cleanString(department, 120),
        employment_status || 'active',
        hire_date || null,
        cleanString(notes, 2000),
      ],
    );

    const staffId = staffResult.rows[0].id;

    await client.query('COMMIT');

    // Fetch the joined row so the response shape matches listStaff.
    const joined = await pool.query(
      `${STAFF_SELECT} WHERE s.id = $1`,
      [staffId],
    );

    log(req, {
      action: 'create',
      entityType: 'staff',
      entityId: staffId,
      description: `Created staff ${first_name} ${last_name} (${role})`,
    });

    res.status(201).json(joined.rows[0]);
  } catch (error) {
    await client.query('ROLLBACK');
    next(error);
  } finally {
    client.release();
  }
}

async function updateStaff(req, res, next) {
  try {
    const { job_title, department, employment_status, hire_date, notes } =
      req.body;

    const result = await pool.query(
      `UPDATE staff SET
         job_title = $1,
         department = $2,
         employment_status = $3,
         hire_date = $4,
         notes = $5,
         updated_at = NOW()
       WHERE id = $6
       RETURNING id`,
      [
        cleanString(job_title, 120),
        cleanString(department, 120),
        employment_status || 'active',
        hire_date || null,
        cleanString(notes, 2000),
        req.params.id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Staff member not found.' });
    }

    const staffId = result.rows[0].id;

    const joined = await pool.query(
      `${STAFF_SELECT} WHERE s.id = $1`,
      [staffId],
    );

    log(req, {
      action: 'update',
      entityType: 'staff',
      entityId: staffId,
      description: `Updated staff id ${staffId}`,
    });

    res.json(joined.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function deleteStaff(req, res, next) {
  try {
    const staff = await pool.query(
      'SELECT user_id FROM staff WHERE id = $1',
      [req.params.id],
    );
    if (staff.rowCount === 0) {
      return res.status(404).json({ message: 'Staff member not found.' });
    }

    await pool.query('DELETE FROM users WHERE id = $1', [
      staff.rows[0].user_id,
    ]);

    log(req, {
      action: 'delete',
      entityType: 'staff',
      entityId: Number(req.params.id),
      description: `Deleted staff id ${req.params.id}`,
    });

    res.json({ message: 'Staff member removed.' });
  } catch (error) {
    next(error);
  }
}

module.exports = { listStaff, getStaff, createStaff, updateStaff, deleteStaff };