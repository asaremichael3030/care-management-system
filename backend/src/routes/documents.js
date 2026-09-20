const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/documentsController');

// Family members hit this through the top-level list endpoint. The
// controller itself filters by family link and visible_to_family.
router.get(
  '/',
  requireAuth,
  c.listDocuments,
);

router.get(
  '/resident/:residentId',
  requireAuth,
  c.listByResident,
);

router.get(
  '/:id',
  requireAuth,
  c.getDocument,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.createDocument,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.updateDocument,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.deleteDocument,
);

module.exports = router;