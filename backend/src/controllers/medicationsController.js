const pool = require('../db/pool');
const { log } = require('../services/auditService');

async function isFamilyLinked(userId, residentId) {
  const result = await pool.query(
    'SELECT 1 FROM family_resident_links WHERE user_id = $1 AND resident_id = $2',
    [userId, residentId],
  );
  return result.rowCount > 0;
}

async function listMedications(req, res, next) {
  try {
    const { residentId } = req.query;
    const params = [];
    let where = '';
    if (residentId) {
      params.push(residentId);
      where = 'WHERE m.resident_id = $1';
    }
    const result = await pool.query(
      `SELECT m.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room
       FROM medications m
       JOIN residents r ON r.id = m.resident_id
       ${where}
       ORDER BY r.last_name, r.first_name, m.name`,
      params,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function listByResident(req, res, next) {
  try {
    const { residentId } = req.params;

    if (req.user.role === 'Family Member') {
      const linked = await isFamilyLinked(req.user.id, Number(residentId));
      if (!linked) {
        return res.status(403).json({ message: 'You do not have permission.' });
      }
    } else if (
      !['Administrator', 'Manager / Senior Carer', 'Care Worker'].includes(
        req.user.role,
      )
    ) {
      return res.status(403).json({ message: 'You do not have permission.' });
    }

    const result = await pool.query(
      `SELECT m.*,
              r.first_name AS resident_first_name,
              r.last_name AS resident_last_name,
              r.room AS resident_room
       FROM medications m
       JOIN residents r ON r.id = m.resident_id
       WHERE m.resident_id = $1
       ORDER BY m.name`,
      [residentId],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function getMedication(req, res, next) {
  try {
    const result = await pool.query(
      'SELECT * FROM medications WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Medication not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function createMedication(req, res, next) {
  try {
    const {
      resident_id,
      name,
      dosage,
      frequency,
      route,
      start_date,
      end_date,
      instructions,
      prescriber,
      is_active,
    } = req.body;

    if (!resident_id || !name) {
      return res
        .status(400)
        .json({ message: 'Resident and medication name are required.' });
    }

    const result = await pool.query(
      `INSERT INTO medications
        (resident_id, name, dosage, frequency, route, start_date, end_date,
         instructions, prescriber, is_active, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       RETURNING *`,
      [
        resident_id,
        name,
        dosage || null,
        frequency || null,
        route || null,
        start_date || null,
        end_date || null,
        instructions || null,
        prescriber || null,
        is_active === false ? false : true,
        req.user.id,
      ],
    );

    log(req, {
      action: 'create',
      entityType: 'medication',
      entityId: result.rows[0].id,
      description: `Created medication "${name}"`,
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function updateMedication(req, res, next) {
  try {
    const { id } = req.params;
    const {
      name,
      dosage,
      frequency,
      route,
      start_date,
      end_date,
      instructions,
      prescriber,
      is_active,
    } = req.body;

    const result = await pool.query(
      `UPDATE medications SET
         name = $1,
         dosage = $2,
         frequency = $3,
         route = $4,
         start_date = $5,
         end_date = $6,
         instructions = $7,
         prescriber = $8,
         is_active = $9,
         updated_at = NOW()
       WHERE id = $10
       RETURNING *`,
      [
        name,
        dosage || null,
        frequency || null,
        route || null,
        start_date || null,
        end_date || null,
        instructions || null,
        prescriber || null,
        is_active !== false,
        id,
      ],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Medication not found.' });
    }

    log(req, {
      action: 'update',
      entityType: 'medication',
      entityId: result.rows[0].id,
      description: `Updated medication id ${id}`,
    });

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function deleteMedication(req, res, next) {
  try {
    const result = await pool.query(
      'DELETE FROM medications WHERE id = $1',
      [req.params.id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Medication not found.' });
    }

    log(req, {
      action: 'delete',
      entityType: 'medication',
      entityId: Number(req.params.id),
      description: `Deleted medication id ${req.params.id}`,
    });

    res.json({ message: 'Medication deleted.' });
  } catch (error) {
    next(error);
  }
}

async function recordAdministration(req, res, next) {
  try {
    const { id } = req.params;
    const { status, notes } = req.body;

    const med = await pool.query(
      'SELECT id, resident_id FROM medications WHERE id = $1',
      [id],
    );
    if (med.rowCount === 0) {
      return res.status(404).json({ message: 'Medication not found.' });
    }

    const result = await pool.query(
      `INSERT INTO medication_records
        (medication_id, resident_id, administered_by, status, notes)
       VALUES ($1,$2,$3,$4,$5)
       RETURNING *`,
      [
        id,
        med.rows[0].resident_id,
        req.user.id,
        status || 'given',
        notes || null,
      ],
    );

    log(req, {
      action: 'record',
      entityType: 'medication',
      entityId: Number(id),
      description: `Recorded medication ${status || 'given'} for medication id ${id}`,
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function listRecords(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT mr.*,
              u.first_name AS administered_first_name,
              u.last_name AS administered_last_name
       FROM medication_records mr
       LEFT JOIN users u ON u.id = mr.administered_by
       WHERE mr.medication_id = $1
       ORDER BY mr.administered_at DESC`,
      [req.params.id],
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listMedications,
  listByResident,
  getMedication,
  createMedication,
  updateMedication,
  deleteMedication,
  recordAdministration,
  listRecords,
};