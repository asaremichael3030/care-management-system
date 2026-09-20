const pool = require('../db/pool');

async function isFamilyLinked(userId, residentId) {
  const result = await pool.query(
    'SELECT 1 FROM family_resident_links WHERE user_id = $1 AND resident_id = $2',
    [userId, residentId],
  );
  return result.rowCount > 0;
}

// GET /api/documents
async function listDocuments(req, res, next) {
  try {
    const { residentId } = req.query;
    const params = [];
    const conditions = [];

    if (residentId) {
      params.push(residentId);
      conditions.push(`d.resident_id = $${params.length}`);
    }

    // Family members only see documents for their linked resident
    // that are also marked visible to family.
    if (req.user.role === 'Family Member') {
      conditions.push(`d.visible_to_family = TRUE`);
      conditions.push(
        `d.resident_id IN (
          SELECT resident_id FROM family_resident_links WHERE user_id = $${params.length + 1}
        )`,
      );
      params.push(req.user.id);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await pool.query(
      `SELECT d.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room,
              u.first_name AS uploaded_first_name,
              u.last_name AS uploaded_last_name
       FROM documents d
       JOIN residents r ON r.id = d.resident_id
       LEFT JOIN users u ON u.id = d.uploaded_by
       ${where}
       ORDER BY d.created_at DESC`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/documents/resident/:residentId
async function listByResident(req, res, next) {
  try {
    const { residentId } = req.params;

    let visibleFilter = '';
    if (req.user.role === 'Family Member') {
      const linked = await isFamilyLinked(req.user.id, Number(residentId));
      if (!linked) {
        return res.status(403).json({ message: 'You do not have permission.' });
      }
      visibleFilter = 'AND d.visible_to_family = TRUE';
    } else if (
      !['Administrator', 'Manager / Senior Carer', 'Care Worker'].includes(
        req.user.role,
      )
    ) {
      return res.status(403).json({ message: 'You do not have permission.' });
    }

    const result = await pool.query(
      `SELECT d.*,
              u.first_name AS uploaded_first_name,
              u.last_name AS uploaded_last_name
       FROM documents d
       LEFT JOIN users u ON u.id = d.uploaded_by
       WHERE d.resident_id = $1 ${visibleFilter}
       ORDER BY d.created_at DESC`,
      [residentId],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/documents/:id
async function getDocument(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT * FROM documents WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Document not found.' });
    }
    const d = result.rows[0];

    if (req.user.role === 'Family Member') {
      if (!d.visible_to_family) {
        return res.status(403).json({ message: 'You do not have permission.' });
      }
      const linked = await isFamilyLinked(req.user.id, d.resident_id);
      if (!linked) {
        return res.status(403).json({ message: 'You do not have permission.' });
      }
    }

    res.json(d);
  } catch (error) {
    next(error);
  }
}

// POST /api/documents
async function createDocument(req, res, next) {
  try {
    const {
      resident_id,
      title,
      document_type,
      description,
      file_url,
      visible_to_family,
    } = req.body;

    if (!resident_id || !title || !file_url) {
      return res.status(400).json({
        message: 'Resident, title, and file URL are required.',
      });
    }

    const result = await pool.query(
      `INSERT INTO documents
        (resident_id, title, document_type, description, file_url,
         visible_to_family, uploaded_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       RETURNING *`,
      [
        resident_id,
        title,
        document_type || 'Other',
        description || null,
        file_url,
        visible_to_family === true,
        req.user.id,
      ],
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PUT /api/documents/:id
async function updateDocument(req, res, next) {
  try {
    const { id } = req.params;
    const {
      title,
      document_type,
      description,
      file_url,
      visible_to_family,
    } = req.body;

    const result = await pool.query(
      `UPDATE documents SET
         title = $1,
         document_type = $2,
         description = $3,
         file_url = $4,
         visible_to_family = $5,
         updated_at = NOW()
       WHERE id = $6
       RETURNING *`,
      [
        title,
        document_type || 'Other',
        description || null,
        file_url,
        visible_to_family === true,
        id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Document not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// DELETE /api/documents/:id
async function deleteDocument(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM documents WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Document not found.' });
    }
    res.json({ message: 'Document deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listDocuments,
  listByResident,
  getDocument,
  createDocument,
  updateDocument,
  deleteDocument,
};