const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/staffController');

router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.listStaff,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.getStaff,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator'),
  c.createStaff,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.updateStaff,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  c.deleteStaff,
);

module.exports = router;