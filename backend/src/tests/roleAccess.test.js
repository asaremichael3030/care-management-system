const request = require('supertest');
const app = require('../app');

describe('Role-based access control', () => {
  let adminToken;
  let familyToken;

  beforeAll(async () => {
    const adminLogin = await request(app)
      .post('/api/auth/login')
      .send({
        email: process.env.ADMIN_EMAIL || 'admin@carehome.local',
        password: process.env.ADMIN_PASSWORD || 'ChangeThisNow123!',
      });
    adminToken = adminLogin.body.token;

    const familyLogin = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'family@carehome.local',
        password: 'Family123!',
      });
    familyToken = familyLogin.body.token;
  });

  test('admin can list residents', async () => {
    const res = await request(app)
      .get('/api/residents')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
  });

  test('family member cannot list all residents', async () => {
    const res = await request(app)
      .get('/api/residents')
      .set('Authorization', `Bearer ${familyToken}`);
    expect(res.statusCode).toBe(403);
  });

  test('family member cannot list audit logs', async () => {
    const res = await request(app)
      .get('/api/audit-logs')
      .set('Authorization', `Bearer ${familyToken}`);
    expect(res.statusCode).toBe(403);
  });

  test('family member cannot create a resident', async () => {
    const res = await request(app)
      .post('/api/residents')
      .set('Authorization', `Bearer ${familyToken}`)
      .send({ first_name: 'X', last_name: 'Y' });
    expect(res.statusCode).toBe(403);
  });

  test('family member can access their linked relative', async () => {
    const res = await request(app)
      .get('/api/family/my-relative')
      .set('Authorization', `Bearer ${familyToken}`);
    expect(res.statusCode).toBe(200);
  });
});