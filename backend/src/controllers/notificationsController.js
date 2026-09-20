const pool = require('../db/pool');

// GET /api/notifications - my notifications.
async function listMine(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT id, user_id, type, title, body, link, read_at, created_at
       FROM notifications
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [req.user.id],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/notifications/unread-count
async function unreadCount(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT COUNT(*)::int AS count
       FROM notifications
       WHERE user_id = $1 AND read_at IS NULL`,
      [req.user.id],
    );
    res.json({ count: result.rows[0].count });
  } catch (error) {
    next(error);
  }
}

// PATCH /api/notifications/:id/read
async function markRead(req, res, next) {
  try {
    const result = await pool.query(
      `UPDATE notifications SET read_at = COALESCE(read_at, NOW())
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [req.params.id, req.user.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Notification not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PATCH /api/notifications/read-all
async function markAllRead(req, res, next) {
  try {
    await pool.query(
      `UPDATE notifications SET read_at = NOW()
       WHERE user_id = $1 AND read_at IS NULL`,
      [req.user.id],
    );
    res.json({ message: 'All notifications marked as read.' });
  } catch (error) {
    next(error);
  }
}

// DELETE /api/notifications/:id
async function deleteNotification(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM notifications WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Notification not found.' });
    }
    res.json({ message: 'Notification deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listMine,
  unreadCount,
  markRead,
  markAllRead,
  deleteNotification,
};