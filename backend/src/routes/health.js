const express = require('express');
const router = express.Router();

// Health check endpoint.
router.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'care-management-system-backend',
    time: new Date().toISOString(),
  });
});

module.exports = router;