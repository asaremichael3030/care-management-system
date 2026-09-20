CREATE TABLE IF NOT EXISTS care_plans (
  id SERIAL PRIMARY KEY,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  care_need TEXT,
  goal TEXT,
  care_actions TEXT,
  frequency VARCHAR(80),
  assigned_staff_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  start_date DATE,
  review_date DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (
    status IN ('active', 'under_review', 'completed', 'archived')
  ),
  notes TEXT,
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_care_plans_resident ON care_plans (resident_id);
CREATE INDEX IF NOT EXISTS idx_care_plans_status ON care_plans (status);
CREATE INDEX IF NOT EXISTS idx_care_plans_review_date ON care_plans (review_date);