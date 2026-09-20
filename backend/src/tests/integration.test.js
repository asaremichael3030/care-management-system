const request = require('supertest');
const app = require('../app');
const pool = require('../db/pool');

describe('Full flow integration', () => {
  let adminToken;
  let managerToken;
  let familyToken;
  let residentId;

  beforeAll(async () => {
    const admin = await request(app)
      .post('/api/auth/login')
      .send({
        email: process.env.ADMIN_EMAIL || 'admin@carehome.local',
        password: process.env.ADMIN_PASSWORD || 'ChangeThisNow123!',
      });
    adminToken = admin.body.token;

    const manager = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'manager@carehome.local',
        password: 'Manager123!',
      });
    managerToken = manager.body.token;

    const family = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'family@carehome.local',
        password: 'Family123!',
      });
    familyToken = family.body.token;
  });

  afterAll(async () => {
    if (residentId) {
      await pool.query('DELETE FROM residents WHERE id = $1', [residentId]);
    }
  });

  test('admin creates a resident that manager and family can see in the correct way', async () => {
    // Admin creates the resident.
    const createRes = await request(app)
      .post('/api/residents')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        first_name: 'Integration',
        last_name: 'Test',
        room: '500',
        status: 'active',
      });
    expect(createRes.statusCode).toBe(201);
    residentId = createRes.body.id;

    // Manager sees it in the full list.
    const mgrList = await request(app)
      .get('/api/residents')
      .set('Authorization', `Bearer ${managerToken}`);
    expect(mgrList.statusCode).toBe(200);
    expect(mgrList.body.find((r) => r.id === residentId)).toBeTruthy();

    // Family member cannot list all residents.
    const famList = await request(app)
      .get('/api/residents')
      .set('Authorization', `Bearer ${familyToken}`);
    expect(famList.statusCode).toBe(403);
  });

  test('manager can create a care plan, and audit log records it', async () => {
    const planRes = await request(app)
      .post('/api/care-plans')
      .set('Authorization', `Bearer ${managerToken}`)
      .send({
        resident_id: residentId,
        title: 'Integration Care Plan',
        care_need: 'Test need',
        goal: 'Test goal',
        status: 'active',
      });
    expect(planRes.statusCode).toBe(201);

    // Admin can see the audit log entry.
    const logs = await request(app)
      .get('/api/audit-logs?entityType=care_plan')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(logs.statusCode).toBe(200);
    const found = logs.body.find(
      (l) => l.description && l.description.includes('Integration Care Plan'),
    );
    expect(found).toBeTruthy();
  });

  test('admin sees summary report with the new data', async () => {
    const res = await request(app)
      .get('/api/reports/summary')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.residents.total).toBeGreaterThan(0);
    expect(res.body.carePlans.total).toBeGreaterThan(0);
  });

  test('family member cannot access reports', async () => {
    const res = await request(app)
      .get('/api/reports/summary')
      .set('Authorization', `Bearer ${familyToken}`);
    expect(res.statusCode).toBe(403);
  });

  test('family member cannot access audit logs', async () => {
    const res = await request(app)
      .get('/api/audit-logs')
      .set('Authorization', `Bearer ${familyToken}`);
    expect(res.statusCode).toBe(403);
  });

  test('cleanup: admin deletes the resident', async () => {
    const res = await request(app)
      .delete(`/api/residents/${residentId}`)
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.statusCode).toBe(200);
    residentId = null;
  });
});