const request = require('supertest');
const app = require('../app');
const pool = require('../db/pool');

let token;
let createdId;

beforeAll(async () => {
  const login = await request(app)
    .post('/api/auth/login')
    .send({
      email: process.env.ADMIN_EMAIL || 'admin@carehome.local',
      password: process.env.ADMIN_PASSWORD || 'ChangeThisNow123!',
    });
  token = login.body.token;
  expect(token).toBeTruthy();
});

afterAll(async () => {
  // Clean up any leftover test resident.
  if (createdId) {
    await pool.query('DELETE FROM residents WHERE id = $1', [createdId]);
  }
});

describe('Residents endpoints', () => {
  test('requires authentication for listing', async () => {
    const res = await request(app).get('/api/residents');
    expect(res.statusCode).toBe(401);
  });

  test('creates a resident', async () => {
    const res = await request(app)
      .post('/api/residents')
      .set('Authorization', `Bearer ${token}`)
      .send({
        first_name: 'Test',
        last_name: 'Resident',
        room: '99',
        status: 'active',
      });
    expect(res.statusCode).toBe(201);
    expect(res.body.first_name).toBe('Test');
    createdId = res.body.id;
  });

  test('lists residents and includes the created one', async () => {
    const res = await request(app)
      .get('/api/residents')
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(200);
    const found = res.body.find((r) => r.id === createdId);
    expect(found).toBeTruthy();
    expect(found.last_name).toBe('Resident');
  });

  test('updates a resident', async () => {
    const res = await request(app)
      .put(`/api/residents/${createdId}`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        first_name: 'Test',
        last_name: 'ResidentUpdated',
        room: '99',
        status: 'active',
      });
    expect(res.statusCode).toBe(200);
    expect(res.body.last_name).toBe('ResidentUpdated');
  });

  test('deletes a resident', async () => {
    const res = await request(app)
      .delete(`/api/residents/${createdId}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.statusCode).toBe(200);
    createdId = null;
  });
});