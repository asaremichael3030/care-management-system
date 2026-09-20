CREATE TABLE IF NOT EXISTS medication_records (
  id SERIAL PRIMARY KEY,
  medication_id INTEGER NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  administered_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  administered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  status VARCHAR(30) NOT NULL DEFAULT 'given' CHECK (
    status IN ('given', 'refused', 'missed', 'held')
  ),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_med_records_medication ON medication_records (medication_id);
CREATE INDEX IF NOT EXISTS idx_med_records_resident ON medication_records (resident_id);
CREATE INDEX IF NOT EXISTS idx_med_records_administered ON medication_records (administered_at);