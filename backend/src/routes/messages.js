const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const c = require('../controllers/messagesController');

router.get('/inbox', requireAuth, c.inbox);
router.get('/sent', requireAuth, c.sent);
router.get('/unread-count', requireAuth, c.unreadCount);
router.get('/contacts', requireAuth, c.contacts);

router.get('/:id', requireAuth, c.getMessage);
router.post('/', requireAuth, c.send);
router.patch('/:id/read', requireAuth, c.markRead);
router.delete('/:id', requireAuth, c.deleteMessage);

module.exports = router;