const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/shiftsController');

router.get(
  '/mine',
  requireAuth,
  c.myShifts,
);

router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.listShifts,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.getShift,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.createShift,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.updateShift,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  c.deleteShift,
);

module.exports = router;