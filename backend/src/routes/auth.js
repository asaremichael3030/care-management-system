const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middleware/authMiddleware');
const authController = require('../controllers/authController');

router.post('/login', authController.login);

// Self-service routes for the logged-in user.
router.get('/profile', requireAuth, authController.getProfile);
router.put('/profile', requireAuth, authController.updateProfile);
router.post('/change-password', requireAuth, authController.changePassword);

module.exports = router;