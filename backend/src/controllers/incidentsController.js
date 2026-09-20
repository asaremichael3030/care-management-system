const pool = require('../db/pool');
const { log } = require('../services/auditService');

async function listIncidents(req, res, next) {
  try {
    const { status, residentId } = req.query;
    const params = [];
    const conditions = [];

    if (status) {
      params.push(status);
      conditions.push(`i.status = $${params.length}`);
    }
    if (residentId) {
      params.push(residentId);
      conditions.push(`i.resident_id = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `SELECT i.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room,
              u.first_name AS reporter_first_name,
              u.last_name AS reporter_last_name
       FROM incidents i
       LEFT JOIN residents r ON r.id = i.resident_id
       LEFT JOIN users u ON u.id = i.reported_by
       ${where}
       ORDER BY i.occurred_date DESC, i.occurred_time DESC NULLS LAST, i.created_at DESC`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function getIncident(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT * FROM incidents WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Incident not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function createIncident(req, res, next) {
  try {
    const {
      resident_id,
      incident_type,
      occurred_date,
      occurred_time,
      location,
      description,
      people_involved,
      action_taken,
    } = req.body;

    if (!incident_type || !occurred_date || !description) {
      return res.status(400).json({
        message: 'Incident type, date, and description are required.',
      });
    }

    const result = await pool.query(
      `INSERT INTO incidents
        (resident_id, incident_type, occurred_date, occurred_time, location,
         description, people_involved, action_taken, reported_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
       RETURNING *`,
      [
        resident_id || null,
        incident_type,
        occurred_date,
        occurred_time || null,
        location || null,
        description,
        people_involved || null,
        action_taken || null,
        req.user.id,
      ],
    );

    log(req, {
      action: 'create',
      entityType: 'incident',
      entityId: result.rows[0].id,
      description: `Reported ${incident_type} incident`,
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function updateIncident(req, res, next) {
  try {
    const { id } = req.params;
    const {
      resident_id,
      incident_type,
      occurred_date,
      occurred_time,
      location,
      description,
      people_involved,
      action_taken,
      status,
    } = req.body;

    const result = await pool.query(
      `UPDATE incidents SET
         resident_id = $1,
         incident_type = $2,
         occurred_date = $3,
         occurred_time = $4,
         location = $5,
         description = $6,
         people_involved = $7,
         action_taken = $8,
         status = $9,
         updated_at = NOW()
       WHERE id = $10
       RETURNING *`,
      [
        resident_id || null,
        incident_type,
        occurred_date,
        occurred_time || null,
        location || null,
        description,
        people_involved || null,
        action_taken || null,
        status || 'open',
        id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Incident not found.' });
    }

    log(req, {
      action: 'update',
      entityType: 'incident',
      entityId: result.rows[0].id,
      description: `Updated incident id ${id}`,
    });

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function deleteIncident(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM incidents WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Incident not found.' });
    }

    log(req, {
      action: 'delete',
      entityType: 'incident',
      entityId: Number(req.params.id),
      description: `Deleted incident id ${req.params.id}`,
    });

    res.json({ message: 'Incident deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listIncidents,
  getIncident,
  createIncident,
  updateIncident,
  deleteIncident,
};