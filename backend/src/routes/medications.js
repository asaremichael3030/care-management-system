const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/medicationsController');

router.get(
  '/resident/:residentId',
  requireAuth,
  c.listByResident,
);

router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.listMedications,
);

router.get(
  '/:id/records',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.listRecords,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.getMedication,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.createMedication,
);

router.post(
  '/:id/record',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.recordAdministration,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.updateMedication,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  c.deleteMedication,
);

module.exports = router;