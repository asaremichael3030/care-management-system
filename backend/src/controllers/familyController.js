const pool = require('../db/pool');
const { log } = require('../services/auditService');

async function listLinks(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT l.id, l.user_id, l.resident_id, l.relationship, l.is_primary,
              l.created_at,
              u.first_name AS user_first_name, u.last_name AS user_last_name,
              u.email AS user_email,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room
       FROM family_resident_links l
       JOIN users u ON u.id = l.user_id
       JOIN residents r ON r.id = l.resident_id
       ORDER BY r.last_name, r.first_name, u.last_name`,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function createLink(req, res, next) {
  try {
    const { user_id, resident_id, relationship, is_primary } = req.body;

    if (!user_id || !resident_id) {
      return res
        .status(400)
        .json({ message: 'user_id and resident_id are required.' });
    }

    const result = await pool.query(
      `INSERT INTO family_resident_links
        (user_id, resident_id, relationship, is_primary)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [user_id, resident_id, relationship || null, is_primary === true],
    );

    log(req, {
      action: 'create',
      entityType: 'family_link',
      entityId: result.rows[0].id,
      description: `Linked user ${user_id} to resident ${resident_id}`,
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({
        message: 'This family member is already linked to that resident.',
      });
    }
    next(error);
  }
}

async function deleteLink(req, res, next) {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'DELETE FROM family_resident_links WHERE id = $1',
      [id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Link not found.' });
    }

    log(req, {
      action: 'delete',
      entityType: 'family_link',
      entityId: Number(id),
      description: `Removed family link id ${id}`,
    });

    res.json({ message: 'Link removed.' });
  } catch (error) {
    next(error);
  }
}

async function myRelative(req, res, next) {
  try {
    const userId = req.user.id;
    const result = await pool.query(
      `SELECT r.*
       FROM residents r
       JOIN family_resident_links l ON l.resident_id = r.id
       WHERE l.user_id = $1
       ORDER BY l.is_primary DESC, r.last_name, r.first_name`,
      [userId],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

module.exports = { listLinks, createLink, deleteLink, myRelative };