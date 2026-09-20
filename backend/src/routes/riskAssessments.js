const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/riskAssessmentsController');

router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.listRiskAssessments,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.getRiskAssessment,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.createRiskAssessment,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.updateRiskAssessment,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  c.deleteRiskAssessment,
);

module.exports = router;