const pool = require('../db/pool');
const { log } = require('../services/auditService');
const { cleanString } = require('../utils/validation');

// GET /api/activities
async function listActivities(req, res, next) {
  try {
    const { status, from, to } = req.query;
    const params = [];
    const conditions = [];

    if (status) {
      params.push(status);
      conditions.push(`a.status = $${params.length}`);
    }
    if (from) {
      params.push(from);
      conditions.push(`a.activity_date >= $${params.length}`);
    }
    if (to) {
      params.push(to);
      conditions.push(`a.activity_date <= $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `SELECT a.*,
              u.first_name AS created_first_name,
              u.last_name AS created_last_name
       FROM activities a
       LEFT JOIN users u ON u.id = a.created_by
       ${where}
       ORDER BY a.activity_date ASC, a.activity_time ASC NULLS LAST`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// POST /api/activities
async function createActivity(req, res, next) {
  try {
    const { title, description, activity_date, activity_time, location, status } =
      req.body;

    if (!title || !activity_date) {
      return res
        .status(400)
        .json({ message: 'Title and activity date are required.' });
    }

    const result = await pool.query(
      `INSERT INTO activities
        (title, description, activity_date, activity_time, location, status, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       RETURNING *`,
      [
        cleanString(title, 200),
        cleanString(description, 2000),
        activity_date,
        activity_time || null,
        cleanString(location, 150),
        status || 'scheduled',
        req.user.id,
      ],
    );

    log(req, {
      action: 'create',
      entityType: 'activity',
      entityId: result.rows[0].id,
      description: `Created activity "${title}"`,
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PUT /api/activities/:id
async function updateActivity(req, res, next) {
  try {
    const { title, description, activity_date, activity_time, location, status } =
      req.body;

    const result = await pool.query(
      `UPDATE activities SET
         title = $1,
         description = $2,
         activity_date = $3,
         activity_time = $4,
         location = $5,
         status = $6,
         updated_at = NOW()
       WHERE id = $7
       RETURNING *`,
      [
        cleanString(title, 200),
        cleanString(description, 2000),
        activity_date,
        activity_time || null,
        cleanString(location, 150),
        status || 'scheduled',
        req.params.id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Activity not found.' });
    }

    log(req, {
      action: 'update',
      entityType: 'activity',
      entityId: result.rows[0].id,
      description: `Updated activity id ${req.params.id}`,
    });

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// DELETE /api/activities/:id
async function deleteActivity(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM activities WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Activity not found.' });
    }

    log(req, {
      action: 'delete',
      entityType: 'activity',
      entityId: Number(req.params.id),
      description: `Deleted activity id ${req.params.id}`,
    });

    res.json({ message: 'Activity deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = { listActivities, createActivity, updateActivity, deleteActivity };