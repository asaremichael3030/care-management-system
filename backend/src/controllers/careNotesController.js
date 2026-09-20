const pool = require('../db/pool');

async function isFamilyLinked(userId, residentId) {
  const result = await pool.query(
    'SELECT 1 FROM family_resident_links WHERE user_id = $1 AND resident_id = $2',
    [userId, residentId],
  );
  return result.rowCount > 0;
}

// GET /api/care-notes
async function listNotes(req, res, next) {
  try {
    const { residentId } = req.query;
    const params = [];
    let where = '';
    if (residentId) {
      params.push(residentId);
      where = 'WHERE n.resident_id = $1';
    }

    const result = await pool.query(
      `SELECT n.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room,
              u.first_name AS recorded_first_name,
              u.last_name AS recorded_last_name
       FROM care_notes n
       JOIN residents r ON r.id = n.resident_id
       LEFT JOIN users u ON u.id = n.recorded_by
       ${where}
       ORDER BY n.recorded_at DESC`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/care-notes/resident/:residentId
// Family members only see notes marked visible to family and only for
// residents they are linked to.
async function listByResident(req, res, next) {
  try {
    const { residentId } = req.params;

    let visibleFilter = '';
    if (req.user.role === 'Family Member') {
      const linked = await isFamilyLinked(req.user.id, Number(residentId));
      if (!linked) {
        return res.status(403).json({ message: 'You do not have permission.' });
      }
      visibleFilter = 'AND n.visible_to_family = TRUE';
    } else if (
      !['Administrator', 'Manager / Senior Carer', 'Care Worker'].includes(
        req.user.role,
      )
    ) {
      return res.status(403).json({ message: 'You do not have permission.' });
    }

    const result = await pool.query(
      `SELECT n.*,
              u.first_name AS recorded_first_name,
              u.last_name AS recorded_last_name
       FROM care_notes n
       LEFT JOIN users u ON u.id = n.recorded_by
       WHERE n.resident_id = $1 ${visibleFilter}
       ORDER BY n.recorded_at DESC`,
      [residentId],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// POST /api/care-notes
async function createNote(req, res, next) {
  try {
    const {
      resident_id,
      note_type,
      content,
      visible_to_family,
    } = req.body;

    if (!resident_id || !note_type || !content) {
      return res
        .status(400)
        .json({ message: 'Resident, note type, and content are required.' });
    }

    const result = await pool.query(
      `INSERT INTO care_notes
        (resident_id, note_type, content, recorded_by, visible_to_family)
       VALUES ($1,$2,$3,$4,$5)
       RETURNING *`,
      [
        resident_id,
        note_type,
        content,
        req.user.id,
        visible_to_family === true,
      ],
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// DELETE /api/care-notes/:id
async function deleteNote(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM care_notes WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Note not found.' });
    }
    res.json({ message: 'Note deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listNotes,
  listByResident,
  createNote,
  deleteNote,
};