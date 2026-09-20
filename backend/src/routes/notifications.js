const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const c = require('../controllers/notificationsController');

router.get('/', requireAuth, c.listMine);
router.get('/unread-count', requireAuth, c.unreadCount);
router.patch('/read-all', requireAuth, c.markAllRead);
router.patch('/:id/read', requireAuth, c.markRead);
router.delete('/:id', requireAuth, c.deleteNotification);

module.exports = router;