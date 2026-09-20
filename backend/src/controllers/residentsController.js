const pool = require('../db/pool');
const { log } = require('../services/auditService');

async function listResidents(req, res, next) {
  try {
    const result = await pool.query(
      `SELECT id, first_name, last_name, date_of_birth, gender, room,
              admission_date, status, emergency_contact_name,
              emergency_contact_phone, care_needs, allergies, important_notes,
              created_at, updated_at
       FROM residents
       ORDER BY last_name, first_name`,
    );
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
}

async function getResident(req, res, next) {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT * FROM residents WHERE id = $1',
      [id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Resident not found.' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function createResident(req, res, next) {
  try {
    const {
      first_name,
      last_name,
      date_of_birth,
      gender,
      room,
      admission_date,
      status,
      emergency_contact_name,
      emergency_contact_phone,
      care_needs,
      allergies,
      important_notes,
    } = req.body;

    if (!first_name || !last_name) {
      return res
        .status(400)
        .json({ message: 'First name and last name are required.' });
    }

    const result = await pool.query(
      `INSERT INTO residents
        (first_name, last_name, date_of_birth, gender, room, admission_date,
         status, emergency_contact_name, emergency_contact_phone,
         care_needs, allergies, important_notes)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
       RETURNING *`,
      [
        first_name,
        last_name,
        date_of_birth || null,
        gender || null,
        room || null,
        admission_date || null,
        status || 'active',
        emergency_contact_name || null,
        emergency_contact_phone || null,
        care_needs || null,
        allergies || null,
        important_notes || null,
      ],
    );

    log(req, {
      action: 'create',
      entityType: 'resident',
      entityId: result.rows[0].id,
      description: `Created resident ${first_name} ${last_name}`,
    });

    res.status(201).json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function updateResident(req, res, next) {
  try {
    const { id } = req.params;
    const {
      first_name,
      last_name,
      date_of_birth,
      gender,
      room,
      admission_date,
      status,
      emergency_contact_name,
      emergency_contact_phone,
      care_needs,
      allergies,
      important_notes,
    } = req.body;

    const result = await pool.query(
      `UPDATE residents SET
         first_name = $1,
         last_name = $2,
         date_of_birth = $3,
         gender = $4,
         room = $5,
         admission_date = $6,
         status = $7,
         emergency_contact_name = $8,
         emergency_contact_phone = $9,
         care_needs = $10,
         allergies = $11,
         important_notes = $12,
         updated_at = NOW()
       WHERE id = $13
       RETURNING *`,
      [
        first_name,
        last_name,
        date_of_birth || null,
        gender || null,
        room || null,
        admission_date || null,
        status || 'active',
        emergency_contact_name || null,
        emergency_contact_phone || null,
        care_needs || null,
        allergies || null,
        important_notes || null,
        id,
      ],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Resident not found.' });
    }

    log(req, {
      action: 'update',
      entityType: 'resident',
      entityId: result.rows[0].id,
      description: `Updated resident ${result.rows[0].first_name} ${result.rows[0].last_name}`,
    });

    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
}

async function deleteResident(req, res, next) {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'DELETE FROM residents WHERE id = $1',
      [id],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Resident not found.' });
    }

    log(req, {
      action: 'delete',
      entityType: 'resident',
      entityId: Number(id),
      description: `Deleted resident id ${id}`,
    });

    res.json({ message: 'Resident deleted.' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listResidents,
  getResident,
  createResident,
  updateResident,
  deleteResident,
};