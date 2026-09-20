const pool = require('../db/pool');

// GET /api/risk-assessments
async function listRiskAssessments(req, res, next) {
  try {
    const { residentId } = req.query;
    const params = [];
    let where = '';
    if (residentId) {
      params.push(residentId);
      where = 'WHERE ra.resident_id = $1';
    }
    const result = await pool.query(
      `SELECT ra.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room,
              u.first_name AS assessed_first_name,
              u.last_name AS assessed_last_name
       FROM risk_assessments ra
       JOIN residents r ON r.id = ra.resident_id
       LEFT JOIN users u ON u.id = ra.assessed_by
       ${where}
       ORDER BY
         CASE ra.risk_level
           WHEN 'critical' THEN 1
           WHEN 'high' THEN 2
           WHEN 'medium' THEN 3
           ELSE 4
         END,
         ra.review_date NULLS LAST,
         ra.created_at DESC`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

// GET /api/risk-assessments/:id
async function getRiskAssessment(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT * FROM risk_assessments WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Risk assessment not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// POST /api/risk-assessments
async function createRiskAssessment(req, res, next) {
  try {
    const {
      resident_id,
      risk_type,
      risk_level,
      description,
      mitigation,
      review_date,
      status,
      assessed_by,
    } = req.body;

    if (!resident_id || !risk_type) {
      return res
        .status(400)
        .json({ message: 'Resident and risk type are required.' });
    }

    const result = await pool.query(
      `INSERT INTO risk_assessments
        (resident_id, risk_type, risk_level, description, mitigation,
         review_date, status, assessed_by, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
       RETURNING *`,
      [
        resident_id,
        risk_type,
        risk_level || 'low',
        description || null,
        mitigation || null,
        review_date || null,
        status || 'active',
        assessed_by || null,
        req.user.id,
      ],
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// PUT /api/risk-assessments/:id
async function updateRiskAssessment(req, res, next) {
  try {
    const { id } = req.params;
    const {
      risk_type,
      risk_level,
      description,
      mitigation,
      review_date,
      status,
      assessed_by,
    } = req.body;

    const result = await pool.query(
      `UPDATE risk_assessments SET
         risk_type = $1,
         risk_level = $2,
         description = $3,
         mitigation = $4,
         review_date = $5,
         status = $6,
         assessed_by = $7,
         updated_at = NOW()
       WHERE id = $8
       RETURNING *`,
      [
        risk_type,
        risk_level || 'low',
        description || null,
        mitigation || null,
        review_date || null,
        status || 'active',
        assessed_by || null,
        id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Risk assessment not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

// DELETE /api/risk-assessments/:id
async function deleteRiskAssessment(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM risk_assessments WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Risk assessment not found.' });
    }
    res.json({ message: 'Risk assessment deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listRiskAssessments,
  getRiskAssessment,
  createRiskAssessment,
  updateRiskAssessment,
  deleteRiskAssessment,
};