const request = require('supertest');
const app = require('../app');

describe('Health endpoint', () => {
  test('GET /api/health returns ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.service).toBe('care-management-system-backend');
  });
});