require('dotenv').config();

process.env.NODE_ENV = 'test';
process.env.JEST_SILENT = 'true';

// No pool.end() here. Jest will force-exit after all tests, which
// closes the pool and releases the event loop automatically.