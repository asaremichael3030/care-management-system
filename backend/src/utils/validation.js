// Very simple email format check. Not perfect but catches obvious errors.
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function isValidEmail(email) {
  return typeof email === 'string' && EMAIL_REGEX.test(email.trim());
}

// Password must be at least 8 characters and contain at least one letter
// and one digit. Kept simple on purpose.
function isValidPassword(password) {
  if (typeof password !== 'string' || password.length < 8) return false;
  const hasLetter = /[A-Za-z]/.test(password);
  const hasDigit = /\d/.test(password);
  return hasLetter && hasDigit;
}

// Trims and caps a string. Returns null for empty input.
function cleanString(value, maxLength) {
  if (value === undefined || value === null) return null;
  const s = String(value).trim();
  if (s.length === 0) return null;
  return s.length > maxLength ? s.substring(0, maxLength) : s;
}

module.exports = { isValidEmail, isValidPassword, cleanString };