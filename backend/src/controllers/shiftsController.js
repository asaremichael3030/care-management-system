const pool = require('../db/pool');

// GET /api/shifts
async function listShifts(req, res, next) {
  try {
    const { staffId, date, from, to } = req.query;
    const params = [];
    const conditions = [];

    if (staffId) {
      params.push(staffId);
      conditions.push(`s.staff_id = $${params.length}`);
    }
    if (date) {
      params.push(date);
      conditions.push(`s.shift_date = $${params.length}`);
    }
    if (from) {
      params.push(from);
      conditions.push(`s.shift_date >= $${params.length}`);
    }
    if (to) {
      params.push(to);
      conditions.push(`s.shift_date <= $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `SELECT s.*,
              u.first_name AS staff_first_name,
              u.last_name AS staff_last_name,
              u.role AS staff_role,
              st.department AS staff_department
       FROM shifts s
       JOIN staff st ON st.id = s.staff_id
       JOIN users u ON u.id = st.user_id
       ${where}
       ORDER BY s.shift_date DESC, s.start_time`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/shifts/mine
// Returns the shifts of the currently logged-in user.
async function myShifts(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT s.*
       FROM shifts s
       JOIN staff st ON st.id = s.staff_id
       WHERE st.user_id = $1
       ORDER BY s.shift_date DESC, s.start_time`,
      [req.user.id],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/shifts/:id
async function getShift(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT * FROM shifts WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Shift not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// POST /api/shifts
async function createShift(req, res, next) {
  try {
    const {
      staff_id,
      shift_date,
      start_time,
      end_time,
      shift_type,
      status,
      notes,
    } = req.body;

    if (!staff_id || !shift_date || !start_time || !end_time) {
      return res.status(400).json({
        message: 'Staff, date, start time, and end time are required.',
      });
    }

    const result = await pool.query(
      `INSERT INTO shifts
        (staff_id, shift_date, start_time, end_time, shift_type, status, notes, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
       RETURNING *`,
      [
        staff_id,
        shift_date,
        start_time,
        end_time,
        shift_type || 'Morning',
        status || 'scheduled',
        notes || null,
        req.user.id,
      ],
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PUT /api/shifts/:id
async function updateShift(req, res, next) {
  try {
    const { id } = req.params;
    const {
      staff_id,
      shift_date,
      start_time,
      end_time,
      shift_type,
      status,
      notes,
    } = req.body;

    const result = await pool.query(
      `UPDATE shifts SET
         staff_id = $1,
         shift_date = $2,
         start_time = $3,
         end_time = $4,
         shift_type = $5,
         status = $6,
         notes = $7,
         updated_at = NOW()
       WHERE id = $8
       RETURNING *`,
      [
        staff_id,
        shift_date,
        start_time,
        end_time,
        shift_type || 'Morning',
        status || 'scheduled',
        notes || null,
        id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Shift not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// DELETE /api/shifts/:id
async function deleteShift(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM shifts WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Shift not found.' });
    }
    res.json({ message: 'Shift deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listShifts,
  myShifts,
  getShift,
  createShift,
  updateShift,
  deleteShift,
};