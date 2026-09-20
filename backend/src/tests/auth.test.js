const request = require('supertest');
const app = require('../app');

describe('Auth endpoints', () => {
  test('rejects missing credentials', async () => {
    const res = await request(app).post('/api/auth/login').send({});
    expect(res.statusCode).toBe(400);
    expect(res.body.message).toMatch(/required/i);
  });

  test('rejects invalid email format', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'not-an-email', password: 'whatever' });
    expect(res.statusCode).toBe(400);
    expect(res.body.message).toMatch(/valid email/i);
  });

  test('rejects unknown user with generic message', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'nobody@example.com', password: 'whatever' });
    expect(res.statusCode).toBe(401);
    expect(res.body.message).toBe('Invalid email or password.');
  });

  test('rejects wrong password with generic message', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: process.env.ADMIN_EMAIL || 'admin@carehome.local',
        password: 'definitely-wrong',
      });
    expect(res.statusCode).toBe(401);
    expect(res.body.message).toBe('Invalid email or password.');
  });
});