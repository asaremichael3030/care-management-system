const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const pool = require('../db/pool');
const {
  sendEmail,
  buildInvitationEmail,
} = require('../services/emailService');
const { log } = require('../services/auditService');
const {
  isValidEmail,
  isValidPassword,
} = require('../utils/validation');

const STAFF_ROLES = [
  'Administrator',
  'Manager / Senior Carer',
  'Care Worker',
  'Family Member',
];

function newToken() {
  return crypto.randomBytes(32).toString('hex');
}

function expiryDate() {
  const hours = Number(process.env.INVITATION_EXPIRY_HOURS) || 48;
  const d = new Date();
  d.setHours(d.getHours() + hours);
  return d;
}

// POST /api/invitations/send
async function sendInvitation(req, res, next) {
  const client = await pool.connect();
  try {
    const { first_name, last_name, email, role, phone } = req.body;

    if (!first_name || !last_name || !email || !role) {
      return res.status(400).json({
        message: 'First name, last name, email, and role are required.',
      });
    }

    if (!isValidEmail(email)) {
      return res
        .status(400)
        .json({ message: 'Please enter a valid email address.' });
    }

    if (!STAFF_ROLES.includes(role)) {
      return res.status(400).json({ message: 'Invalid role.' });
    }

    // In production, refuse to run without email configured so nobody
    // is silently left without an invitation.
    const apiKey = process.env.RESEND_API_KEY || '';
    const isProduction = process.env.NODE_ENV === 'production';
    if (isProduction && apiKey.trim().length === 0) {
      return res.status(500).json({
        message: 'Email sending is not configured on this server.',
      });
    }

    await client.query('BEGIN');

    let userId;
    const existing = await client.query(
      'SELECT id FROM users WHERE email = $1',
      [email.trim().toLowerCase()],
    );

    if (existing.rowCount > 0) {
      userId = existing.rows[0].id;
      await client.query(
        `UPDATE users
         SET first_name = $1, last_name = $2, role = $3,
             phone = COALESCE($4, phone),
             status = 'invited', updated_at = NOW()
         WHERE id = $5`,
        [first_name, last_name, role, phone || null, userId],
      );
    } else {
      const placeholder = crypto.randomBytes(32).toString('hex');
      const result = await client.query(
        `INSERT INTO users
           (first_name, last_name, email, phone, password_hash, role, status)
         VALUES ($1,$2,$3,$4,$5,$6,'invited')
         RETURNING id`,
        [
          first_name,
          last_name,
          email.trim().toLowerCase(),
          phone || null,
          placeholder,
          role,
        ],
      );
      userId = result.rows[0].id;
    }

    await client.query(
      `UPDATE invitations
       SET used_at = NOW()
       WHERE user_id = $1 AND used_at IS NULL`,
      [userId],
    );

    const token = newToken();
    const expires = expiryDate();

    await client.query(
      `INSERT INTO invitations (user_id, token, expires_at, created_by)
       VALUES ($1, $2, $3, $4)`,
      [userId, token, expires, req.user.id],
    );

    await client.query('COMMIT');

    const base = (process.env.APP_URL || 'http://localhost:5173').replace(
      /\/+$/,
      '',
    );
    const acceptUrl = `${base}/#/accept-invitation?token=${token}`;

    const { subject, text, html } = buildInvitationEmail({
      firstName: first_name,
      acceptUrl,
    });

    try {
      await sendEmail({ to: email, subject, text, html });
    } catch (emailError) {
      console.error('Email send failed:', emailError.message);
    }

    log(req, {
      action: 'create',
      entityType: 'invitation',
      entityId: userId,
      description: `Invitation sent to ${email} (${role})`,
    });

    res.status(201).json({
      message: 'Invitation sent.',
      email,
      expiresAt: expires,
      devLink: apiKey.trim().length === 0 ? acceptUrl : undefined,
    });
  } catch (error) {
    await client.query('ROLLBACK');
    next(error);
  } finally {
    client.release();
  }
}

// GET /api/invitations/verify/:token
async function verifyInvitation(req, res, next) {
  try {
    const { token } = req.params;
    const result = await pool.query(
      `SELECT i.id, i.user_id, i.expires_at, i.used_at,
              u.first_name, u.last_name, u.email, u.role
       FROM invitations i
       JOIN users u ON u.id = i.user_id
       WHERE i.token = $1`,
      [token],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Invitation not found.' });
    }
    const inv = result.rows[0];
    if (inv.used_at) {
      return res.status(410).json({ message: 'Invitation already used.' });
    }
    if (new Date(inv.expires_at) < new Date()) {
      return res.status(410).json({ message: 'Invitation has expired.' });
    }
    res.json({
      first_name: inv.first_name,
      last_name: inv.last_name,
      email: inv.email,
      role: inv.role,
      expires_at: inv.expires_at,
    });
  } catch (error) {
    next(error);
  }
}

// POST /api/invitations/accept
async function acceptInvitation(req, res, next) {
  try {
    const { token, password } = req.body;

    if (!token || !password) {
      return res
        .status(400)
        .json({ message: 'Token and password are required.' });
    }

    if (!isValidPassword(password)) {
      return res.status(400).json({
        message:
          'Password must be at least 8 characters and include a letter and a number.',
      });
    }

    const result = await pool.query(
      `SELECT i.id, i.user_id, i.expires_at, i.used_at
       FROM invitations i
       WHERE i.token = $1`,
      [token],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Invitation not found.' });
    }
    const inv = result.rows[0];
    if (inv.used_at) {
      return res.status(410).json({ message: 'Invitation already used.' });
    }
    if (new Date(inv.expires_at) < new Date()) {
      return res.status(410).json({ message: 'Invitation has expired.' });
    }

    const hash = await bcrypt.hash(password, 10);

    await pool.query(
      `UPDATE users
       SET password_hash = $1, status = 'active', updated_at = NOW()
       WHERE id = $2`,
      [hash, inv.user_id],
    );

    await pool.query(
      'UPDATE invitations SET used_at = NOW() WHERE id = $1',
      [inv.id],
    );

    log(req, {
      action: 'update',
      entityType: 'invitation',
      entityId: inv.user_id,
      description: `Invitation accepted for user id ${inv.user_id}`,
    });

    res.json({
      message: 'Password set successfully. You can now log in.',
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { sendInvitation, verifyInvitation, acceptInvitation };