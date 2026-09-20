const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/auditLogsController');

router.get(
  '/',
  requireAuth,
  requireRole('Administrator'),
  c.listAuditLogs,
);

module.exports = router;