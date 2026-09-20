const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const controller = require('../controllers/familyController');

// Family member fetches their own linked resident(s).
router.get(
  '/my-relative',
  requireAuth,
  requireRole('Family Member'),
  controller.myRelative,
);

// Admin and Manager manage links.
router.get(
  '/links',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  controller.listLinks,
);

router.post(
  '/links',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  controller.createLink,
);

router.delete(
  '/links/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  controller.deleteLink,
);

module.exports = router;