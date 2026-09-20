const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const controller = require('../controllers/carePlansController');

// Family members use listByResident through /api/care-plans/resident/:id.
// The controller itself checks the family link, so we allow the route
// to be called by any authenticated user.
router.get(
  '/resident/:residentId',
  requireAuth,
  controller.listByResident,
);

router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  controller.listCarePlans,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  controller.getCarePlan,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  controller.createCarePlan,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  controller.updateCarePlan,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  controller.deleteCarePlan,
);

module.exports = router;