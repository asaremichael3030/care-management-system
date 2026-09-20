const pool = require('../db/pool');

// GET /api/care-tasks
async function listTasks(req, res, next) {
  try {
    const { status, residentId, assignedTo } = req.query;
    const params = [];
    const conditions = [];

    if (status) {
      params.push(status);
      conditions.push(`t.status = $${params.length}`);
    }
    if (residentId) {
      params.push(residentId);
      conditions.push(`t.resident_id = $${params.length}`);
    }
    if (assignedTo) {
      params.push(assignedTo);
      conditions.push(`t.assigned_to = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `SELECT t.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room,
              u.first_name AS assigned_first_name,
              u.last_name AS assigned_last_name
       FROM care_tasks t
       JOIN residents r ON r.id = t.resident_id
       LEFT JOIN users u ON u.id = t.assigned_to
       ${where}
       ORDER BY t.due_date NULLS LAST, t.due_time NULLS LAST, t.created_at DESC`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/care-tasks/mine
async function myTasks(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT t.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room
       FROM care_tasks t
       JOIN residents r ON r.id = t.resident_id
       WHERE t.assigned_to = $1
       ORDER BY t.due_date NULLS LAST, t.due_time NULLS LAST`,
      [req.user.id],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/care-tasks/:id
async function getTask(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT * FROM care_tasks WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// POST /api/care-tasks
async function createTask(req, res, next) {
  try {
    const {
      resident_id,
      assigned_to,
      task_type,
      title,
      description,
      due_date,
      due_time,
      notes,
    } = req.body;

    if (!resident_id || !task_type || !title) {
      return res
        .status(400)
        .json({ message: 'Resident, task type, and title are required.' });
    }

    const result = await pool.query(
      `INSERT INTO care_tasks
        (resident_id, assigned_to, task_type, title, description,
         due_date, due_time, notes, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
       RETURNING *`,
      [
        resident_id,
        assigned_to || null,
        task_type,
        title,
        description || null,
        due_date || null,
        due_time || null,
        notes || null,
        req.user.id,
      ],
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PUT /api/care-tasks/:id
async function updateTask(req, res, next) {
  try {
    const { id } = req.params;
    const {
      assigned_to,
      task_type,
      title,
      description,
      due_date,
      due_time,
      status,
      notes,
    } = req.body;

    const result = await pool.query(
      `UPDATE care_tasks SET
         assigned_to = $1,
         task_type = $2,
         title = $3,
         description = $4,
         due_date = $5,
         due_time = $6,
         status = $7,
         notes = $8,
         updated_at = NOW()
       WHERE id = $9
       RETURNING *`,
      [
        assigned_to || null,
        task_type,
        title,
        description || null,
        due_date || null,
        due_time || null,
        status || 'pending',
        notes || null,
        id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PATCH /api/care-tasks/:id/complete
async function completeTask(req, res, next) {
  try {
    const { id } = req.params;
    const { notes } = req.body;

    const result = await pool.query(
      `UPDATE care_tasks SET
         status = 'completed',
         completed_at = NOW(),
         completed_by = $1,
         notes = COALESCE($2, notes),
         updated_at = NOW()
       WHERE id = $3
       RETURNING *`,
      [req.user.id, notes || null, id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// DELETE /api/care-tasks/:id
async function deleteTask(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM care_tasks WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Task not found.' });
    }
    res.json({ message: 'Task deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listTasks,
  myTasks,
  getTask,
  createTask,
  updateTask,
  completeTask,
  deleteTask,
};