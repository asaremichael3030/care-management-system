const pool = require('../db/pool');

// Writes an audit entry. Never throws so a logging failure cannot
// break the main action.
async function log(req, { action, entityType, entityId, description }) {
  try {
    const userId = req && req.user ? req.user.id : null;
    const ip =
      req && req.headers
        ? (req.headers['x-forwarded-for'] ||
            req.socket?.remoteAddress ||
            '').toString().split(',')[0].trim()
        : null;

    await pool.query(
      `INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id, description, ip_address)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [
        userId,
        action,
        entityType,
        entityId || null,
        description || null,
        ip || null,
      ],
    );
  } catch (error) {
    console.error('Audit log write failed:', error.message);
  }
}

module.exports = { log };