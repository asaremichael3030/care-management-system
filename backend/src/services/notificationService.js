const pool = require('../db/pool');

// Creates a notification for a user.
// Safe to call from any controller. Errors are logged but never thrown
// so a notification failure does not break the main action.
async function notify({ userId, type, title, body, link }) {
  try {
    await pool.query(
      `INSERT INTO notifications (user_id, type, title, body, link)
       VALUES ($1, $2, $3, $4, $5)`,
      [userId, type || 'system', title, body || null, link || null],
    );
  } catch (error) {
    console.error('Failed to create notification:', error.message);
  }
}

// Creates the same notification for many users.
async function notifyMany(userIds, payload) {
  for (const id of userIds) {
    await notify({ userId: id, ...payload });
  }
}

module.exports = { notify, notifyMany };