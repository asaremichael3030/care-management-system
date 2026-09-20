const pool = require('../db/pool');

// Helper that runs a query and returns the first row only.
async function one(sql, params = []) {
  const result = await pool.query(sql, params);
  return result.rows[0];
}

// Helper that runs a query and returns all rows.
async function many(sql, params = []) {
  const result = await pool.query(sql, params);
  return result.rows;
}

// GET /api/reports/summary
async function summary(req, res, next) {
  try {
    // Resident totals.
    const residentsTotal = await one(
      'SELECT COUNT(*)::int AS count FROM residents',
    );
    const residentsByStatus = await many(
      `SELECT status, COUNT(*)::int AS count
       FROM residents
       GROUP BY status
       ORDER BY status`,
    );

    // Medication totals.
    const medicationsActive = await one(
      'SELECT COUNT(*)::int AS count FROM medications WHERE is_active = TRUE',
    );
    const medicationsTotal = await one(
      'SELECT COUNT(*)::int AS count FROM medications',
    );
    const medicationRecordsThisMonth = await one(
      `SELECT COUNT(*)::int AS count
       FROM medication_records
       WHERE administered_at >= date_trunc('month', NOW())`,
    );

    // Incident totals.
    const incidentsTotal = await one(
      'SELECT COUNT(*)::int AS count FROM incidents',
    );
    const incidentsByStatus = await many(
      `SELECT status, COUNT(*)::int AS count
       FROM incidents
       GROUP BY status
       ORDER BY status`,
    );
    const incidentsByType = await many(
      `SELECT incident_type AS type, COUNT(*)::int AS count
       FROM incidents
       GROUP BY incident_type
       ORDER BY count DESC, incident_type
       LIMIT 5`,
    );
    const incidentsThisMonth = await one(
      `SELECT COUNT(*)::int AS count
       FROM incidents
       WHERE occurred_date >= date_trunc('month', NOW())`,
    );

    // Care task totals.
    const tasksTotal = await one(
      'SELECT COUNT(*)::int AS count FROM care_tasks',
    );
    const tasksByStatus = await many(
      `SELECT status, COUNT(*)::int AS count
       FROM care_tasks
       GROUP BY status
       ORDER BY status`,
    );
    const tasksCompleted = await one(
      `SELECT COUNT(*)::int AS count
       FROM care_tasks
       WHERE status = 'completed'`,
    );

    // Staff and shifts.
    const staffTotal = await one(
      'SELECT COUNT(*)::int AS count FROM staff',
    );
    const staffByRole = await many(
      `SELECT u.role, COUNT(*)::int AS count
       FROM staff s
       JOIN users u ON u.id = s.user_id
       GROUP BY u.role
       ORDER BY u.role`,
    );
    const staffByStatus = await many(
      `SELECT employment_status AS status, COUNT(*)::int AS count
       FROM staff
       GROUP BY employment_status
       ORDER BY employment_status`,
    );
    const shiftsThisWeek = await one(
      `SELECT COUNT(*)::int AS count
       FROM shifts
       WHERE shift_date >= date_trunc('week', NOW())
         AND shift_date < date_trunc('week', NOW()) + INTERVAL '7 days'`,
    );

    // Care plans.
    const carePlansTotal = await one(
      'SELECT COUNT(*)::int AS count FROM care_plans',
    );
    const carePlansByStatus = await many(
      `SELECT status, COUNT(*)::int AS count
       FROM care_plans
       GROUP BY status
       ORDER BY status`,
    );
    const carePlansDue = await one(
      `SELECT COUNT(*)::int AS count
       FROM care_plans
       WHERE review_date IS NOT NULL
         AND review_date <= NOW() + INTERVAL '30 days'
         AND status IN ('active', 'under_review')`,
    );
    const carePlansOverdue = await one(
      `SELECT COUNT(*)::int AS count
       FROM care_plans
       WHERE review_date IS NOT NULL
         AND review_date < NOW()
         AND status IN ('active', 'under_review')`,
    );

    // Family and messages.
    const familiesLinked = await one(
      'SELECT COUNT(DISTINCT user_id)::int AS count FROM family_resident_links',
    );
    const messagesTotal = await one(
      'SELECT COUNT(*)::int AS count FROM messages',
    );
    const messagesThisWeek = await one(
      `SELECT COUNT(*)::int AS count
       FROM messages
       WHERE created_at >= date_trunc('week', NOW())`,
    );

    res.json({
      residents: {
        total: residentsTotal.count,
        byStatus: residentsByStatus,
      },
      medications: {
        total: medicationsTotal.count,
        active: medicationsActive.count,
        recordsThisMonth: medicationRecordsThisMonth.count,
      },
      incidents: {
        total: incidentsTotal.count,
        thisMonth: incidentsThisMonth.count,
        byStatus: incidentsByStatus,
        byType: incidentsByType,
      },
      careTasks: {
        total: tasksTotal.count,
        completed: tasksCompleted.count,
        byStatus: tasksByStatus,
      },
      staff: {
        total: staffTotal.count,
        byRole: staffByRole,
        byStatus: staffByStatus,
      },
      shifts: {
        thisWeek: shiftsThisWeek.count,
      },
      carePlans: {
        total: carePlansTotal.count,
        dueForReview: carePlansDue.count,
        overdue: carePlansOverdue.count,
        byStatus: carePlansByStatus,
      },
      family: {
        linked: familiesLinked.count,
      },
      messages: {
        total: messagesTotal.count,
        thisWeek: messagesThisWeek.count,
      },
    });
  } catch (error) {
    next(error);
  }
}

module.exports = { summary };