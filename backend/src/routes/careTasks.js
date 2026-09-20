const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');
const c = require('../controllers/careTasksController');

router.get(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.listTasks,
);

router.get(
  '/mine',
  requireAuth,
  requireRole('Care Worker', 'Manager / Senior Carer', 'Administrator'),
  c.myTasks,
);

router.get(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.getTask,
);

router.post(
  '/',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.createTask,
);

router.put(
  '/:id',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer'),
  c.updateTask,
);

router.patch(
  '/:id/complete',
  requireAuth,
  requireRole('Administrator', 'Manager / Senior Carer', 'Care Worker'),
  c.completeTask,
);

router.delete(
  '/:id',
  requireAuth,
  requireRole('Administrator'),
  c.deleteTask,
);

module.exports = router;