const pool = require('../db/pool');
const { log } = require('../services/auditService');

async function isFamilyLinked(userId, residentId) {
  const result = await pool.query(
    'SELECT 1 FROM family_resident_links WHERE user_id = $1 AND resident_id = $2',
    [userId, residentId],
  );
  return result.rowCount > 0;
}

async function listCarePlans(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT cp.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room,
              u.first_name AS staff_first_name,
              u.last_name AS staff_last_name
       FROM care_plans cp
       JOIN residents r ON r.id = cp.resident_id
       LEFT JOIN users u ON u.id = cp.assigned_staff_id
       ORDER BY cp.review_date NULLS LAST, cp.created_at DESC`,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function getCarePlan(req, res, next) {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT cp.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room
       FROM care_plans cp
       JOIN residents r ON r.id = cp.resident_id
       WHERE cp.id = $1`,
      [id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Care plan not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function listByResident(req, res, next) {
  try {
    const { residentId } = req.params;

    if (req.user.role === 'Family Member') {
      const linked = await isFamilyLinked(req.user.id, Number(residentId));
      if (!linked) {
        return res.status(403).json({ message: 'You do not have permission.' });
      }
    } else if (
      !['Administrator', 'Manager / Senior Carer', 'Care Worker'].includes(
        req.user.role,
      )
    ) {
      return res.status(403).json({ message: 'You do not have permission.' });
    }

    const result = await pool.query(
      `SELECT cp.*,
              u.first_name AS staff_first_name,
              u.last_name AS staff_last_name
       FROM care_plans cp
       LEFT JOIN users u ON u.id = cp.assigned_staff_id
       WHERE cp.resident_id = $1
       ORDER BY cp.review_date NULLS LAST, cp.created_at DESC`,
      [residentId],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function createCarePlan(req, res, next) {
  try {
    const {
      resident_id,
      title,
      care_need,
      goal,
      care_actions,
      frequency,
      assigned_staff_id,
      start_date,
      review_date,
      status,
      notes,
    } = req.body;

    if (!resident_id || !title) {
      return res
        .status(400)
        .json({ message: 'Resident and title are required.' });
    }

    const result = await pool.query(
      `INSERT INTO care_plans
        (resident_id, title, care_need, goal, care_actions, frequency,
         assigned_staff_id, start_date, review_date, status, notes, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
       RETURNING *`,
      [
        resident_id,
        title,
        care_need || null,
        goal || null,
        care_actions || null,
        frequency || null,
        assigned_staff_id || null,
        start_date || null,
        review_date || null,
        status || 'active',
        notes || null,
        req.user.id,
      ],
    );

    log(req, {
      action: 'create',
      entityType: 'care_plan',
      entityId: result.rows[0].id,
      description: `Created care plan "${title}"`,
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function updateCarePlan(req, res, next) {
  try {
    const { id } = req.params;
    const {
      title,
      care_need,
      goal,
      care_actions,
      frequency,
      assigned_staff_id,
      start_date,
      review_date,
      status,
      notes,
    } = req.body;

    const result = await pool.query(
      `UPDATE care_plans SET
         title = $1,
         care_need = $2,
         goal = $3,
         care_actions = $4,
         frequency = $5,
         assigned_staff_id = $6,
         start_date = $7,
         review_date = $8,
         status = $9,
         notes = $10,
         updated_at = NOW()
       WHERE id = $11
       RETURNING *`,
      [
        title,
        care_need || null,
        goal || null,
        care_actions || null,
        frequency || null,
        assigned_staff_id || null,
        start_date || null,
        review_date || null,
        status || 'active',
        notes || null,
        id,
      ],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Care plan not found.' });
    }

    log(req, {
      action: 'update',
      entityType: 'care_plan',
      entityId: result.rows[0].id,
      description: `Updated care plan id ${id}`,
    });

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function deleteCarePlan(req, res, next) {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'DELETE FROM care_plans WHERE id = $1',
      [id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Care plan not found.' });
    }

    log(req, {
      action: 'delete',
      entityType: 'care_plan',
      entityId: Number(id),
      description: `Deleted care plan id ${id}`,
    });

    res.json({ message: 'Care plan deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listCarePlans,
  getCarePlan,
  listByResident,
  createCarePlan,
  updateCarePlan,
  deleteCarePlan,
};