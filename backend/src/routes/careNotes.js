const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/careNotesController');

router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.listNotes,
);

router.get(
  '/resident/:residentId',
  requireAuth,
  c.listByResident,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.createNote,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.deleteNote,
);

module.exports = router;