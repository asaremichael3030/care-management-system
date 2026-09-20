const pool = require('../db/pool');

// GET /api/audit-logs
async function listAuditLogs(req, res, next) {
  try {
    const { action, entityType, userId, limit } = req.query;
    const params = [];
    const conditions = [];

    if (action) {
      params.push(action);
      conditions.push(`a.action = $${params.length}`);
    }
    if (entityType) {
      params.push(entityType);
      conditions.push(`a.entity_type = $${params.length}`);
    }
    if (userId) {
      params.push(userId);
      conditions.push(`a.user_id = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const cap = Math.min(Number(limit) || 200, 500);

    const result = await pool.query(
      `SELECT a.id, a.user_id, a.action, a.entity_type, a.entity_id,
              a.description, a.ip_address, a.created_at,
              u.first_name, u.last_name, u.role
       FROM audit_logs a
       LEFT JOIN users u ON u.id = a.user_id
       ${where}
       ORDER BY a.created_at DESC
       LIMIT ${cap}`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

module.exports = { listAuditLogs };