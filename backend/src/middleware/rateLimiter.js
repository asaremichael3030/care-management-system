const rateLimit = require('express-rate-limit');

// Limits login attempts to slow down brute-force attacks.
// 10 attempts per 15 minutes per IP address.
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many login attempts. Please try again later.' },
});

// Limits invitation sends per IP to prevent email spam.
// 20 invitations per hour per IP.
const invitationLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many invitations sent. Please try again later.' },
});

module.exports = { loginLimiter, invitationLimiter };