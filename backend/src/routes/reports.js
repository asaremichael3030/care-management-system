const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/reportsController');

router.get(
  '/summary',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.summary,
);

module.exports = router;