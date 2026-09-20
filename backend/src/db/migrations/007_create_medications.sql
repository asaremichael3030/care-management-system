CREATE TABLE IF NOT EXISTS medications (
  id SERIAL PRIMARY KEY,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  dosage VARCHAR(80),
  frequency VARCHAR(120),
  route VARCHAR(80),
  start_date DATE,
  end_date DATE,
  instructions TEXT,
  prescriber VARCHAR(200),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_medications_resident ON medications (resident_id);
CREATE INDEX IF NOT EXISTS idx_medications_active ON medications (is_active);