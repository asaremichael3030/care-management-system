const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const controller = require('../controllers/residentsController');

// Care Worker can only read. Admin and Manager can also create and update.
router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  controller.listResidents,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  controller.getResident,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  controller.createResident,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  controller.updateResident,
);

// Only Administrator can delete.
router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  controller.deleteResident,
);

module.exports = router;