const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/invitationsController');

// Public routes (no auth needed to verify or accept an invitation).
router.get('/verify/:token', c.verifyInvitation);
router.post('/accept', c.acceptInvitation);

// Only Administrator can send invitations.
router.post(
  '/send',
  requireAuth,
  requireRole('Administrator'),
  c.sendInvitation,
);

module.exports = router;