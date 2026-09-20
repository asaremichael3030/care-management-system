// Handles unknown routes with a JSON 404 response.
function notFound(req, res) {
  res.status(404).json({ message: 'Route not found' });
}

module.exports = notFound;