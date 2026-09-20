-- Risk assessments describe the risks a resident faces and how they are managed.
CREATE TABLE IF NOT EXISTS risk_assessments (
  id SERIAL PRIMARY KEY,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  risk_type VARCHAR(80) NOT NULL,
  risk_level VARCHAR(30) NOT NULL DEFAULT 'low' CHECK (
    risk_level IN ('low', 'medium', 'high', 'critical')
  ),
  description TEXT,
  mitigation TEXT,
  review_date DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (
    status IN ('active', 'under_review', 'closed')
  ),
  assessed_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_resident ON risk_assessments (resident_id);
CREATE INDEX IF NOT EXISTS idx_risk_assessments_level ON risk_assessments (risk_level);
CREATE INDEX IF NOT EXISTS idx_risk_assessments_review ON risk_assessments (review_date);