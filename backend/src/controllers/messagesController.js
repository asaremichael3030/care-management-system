const pool = require('../db/pool');
const { notify } = require('../services/notificationService');

// GET /api/messages/inbox - messages received by the logged-in user.
async function inbox(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT m.id, m.sender_id, m.recipient_id, m.subject, m.body,
              m.read_at, m.created_at,
              u.first_name AS sender_first_name,
              u.last_name AS sender_last_name,
              u.role AS sender_role
       FROM messages m
       JOIN users u ON u.id = m.sender_id
       WHERE m.recipient_id = $1
       ORDER BY m.created_at DESC`,
      [req.user.id],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/messages/sent - messages sent by the logged-in user.
async function sent(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT m.id, m.sender_id, m.recipient_id, m.subject, m.body,
              m.read_at, m.created_at,
              u.first_name AS recipient_first_name,
              u.last_name AS recipient_last_name,
              u.role AS recipient_role
       FROM messages m
       JOIN users u ON u.id = m.recipient_id
       WHERE m.sender_id = $1
       ORDER BY m.created_at DESC`,
      [req.user.id],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/messages/unread-count
async function unreadCount(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT COUNT(*)::int AS count FROM messages WHERE recipient_id = $1 AND read_at IS NULL',
      [req.user.id],
    );
    res.json({ count: result.rows[0].count });
  } catch (error) {
    next(error);
  }
}

// GET /api/messages/:id - only sender or recipient may read it.
async function getMessage(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT * FROM messages WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Message not found.' });
    }
    const m = result.rows[0];
    if (m.sender_id !== req.user.id && m.recipient_id !== req.user.id) {
      return res.status(403).json({ message: 'You do not have permission.' });
    }
    res.json(m);
  } catch (error) {
    next(error);
  }
}

// POST /api/messages
async function send(req, res, next) {
  try {
    const { recipient_id, subject, body } = req.body;

    if (!recipient_id || !body) {
      return res
        .status(400)
        .json({ message: 'Recipient and message body are required.' });
    }

    if (recipient_id === req.user.id) {
      return res
        .status(400)
        .json({ message: 'You cannot send a message to yourself.' });
    }

    const recipient = await pool.query(
      'SELECT id FROM users WHERE id = $1 AND status = $2',
      [recipient_id, 'active'],
    );
    if (recipient.rowCount === 0) {
      return res.status(404).json({ message: 'Recipient not found.' });
    }

    const result = await pool.query(
      `INSERT INTO messages (sender_id, recipient_id, subject, body)
       VALUES ($1,$2,$3,$4)
       RETURNING *`,
      [req.user.id, recipient_id, subject || null, body],
    );

    // Fire-and-forget notification. The notification helper catches
    // its own errors so a failure here cannot break the message send.
    notify({
      userId: recipient_id,
      type: 'message',
      title: subject && subject.trim().length > 0 ? subject : 'New message',
      body: body.length > 120 ? body.substring(0, 117) + '...' : body,
      link: 'messages',
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PATCH /api/messages/:id/read - marks the message as read for the recipient.
async function markRead(req, res, next) {
  try {
    const result = await pool.query(
      `UPDATE messages SET read_at = COALESCE(read_at, NOW())
       WHERE id = $1 AND recipient_id = $2
       RETURNING *`,
      [req.params.id, req.user.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Message not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// DELETE /api/messages/:id - only sender or recipient may delete it.
async function deleteMessage(req, res, next) {
  try {
    const result = await pool.query(
      `DELETE FROM messages
       WHERE id = $1 AND (sender_id = $2 OR recipient_id = $2)`,
      [req.params.id, req.user.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Message not found.' });
    }
    res.json({ message: 'Message deleted.' });
  } catch (error) {
    next(error);
  }
}

// GET /api/messages/contacts - list of users this user can message.
// For a Family Member, this includes only Care Home staff.
// For staff, this includes staff plus family members.
async function contacts(req, res, next) {
  try {
    let sql;
    const params = [];

    if (req.user.role === 'Family Member') {
      sql = `SELECT id, first_name, last_name, role
             FROM users
             WHERE status = 'active'
               AND role IN ('Administrator', 'Manager / Senior Carer', 'Care Worker')
             ORDER BY last_name, first_name`;
    } else {
      sql = `SELECT id, first_name, last_name, role
             FROM users
             WHERE status = 'active' AND id <> $1
             ORDER BY role, last_name, first_name`;
      params.push(req.user.id);
    }

    const result = await pool.query(sql, params);
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  inbox,
  sent,
  unreadCount,
  getMessage,
  send,
  markRead,
  deleteMessage,
  contacts,
};