const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/usersController');

// List and read are open to Administrator and Manager.
// (Managers need this for pickers in other screens.)
router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.listUsers,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.getUser,
);

// Only the Administrator can update, reset passwords, or delete users.
router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  c.updateUser,
);

router.post(
  '/:id/reset-password',
  requireAuth,
  requireRole('Administrator'),
  c.resetPassword,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  c.deleteUser,
);

module.exports = router;