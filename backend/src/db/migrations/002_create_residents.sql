-- Residents table. Residents are not users and cannot log in.
CREATE TABLE IF NOT EXISTS residents (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE,
  gender VARCHAR(30),
  room VARCHAR(20),
  admission_date DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (
    status IN ('active', 'on_leave', 'discharged', 'deceased')
  ),
  emergency_contact_name VARCHAR(150),
  emergency_contact_phone VARCHAR(30),
  care_needs TEXT,
  allergies TEXT,
  important_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_residents_last_name ON residents (last_name);
CREATE INDEX IF NOT EXISTS idx_residents_status ON residents (status);