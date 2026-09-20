-- Incidents record anything unusual that happened in the care home.
CREATE TABLE IF NOT EXISTS incidents (
  id SERIAL PRIMARY KEY,
  resident_id INTEGER REFERENCES residents(id) ON DELETE SET NULL,
  incident_type VARCHAR(80) NOT NULL,
  occurred_date DATE NOT NULL,
  occurred_time TIME,
  location VARCHAR(120),
  description TEXT NOT NULL,
  people_involved TEXT,
  action_taken TEXT,
  reported_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'open' CHECK (
    status IN ('open', 'under_review', 'resolved', 'closed')
  ),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_incidents_resident ON incidents (resident_id);
CREATE INDEX IF NOT EXISTS idx_incidents_status ON incidents (status);
CREATE INDEX IF NOT EXISTS idx_incidents_date ON incidents (occurred_date);