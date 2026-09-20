-- Activities are events organised by the care home.
CREATE TABLE IF NOT EXISTS activities (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  activity_date DATE NOT NULL,
  activity_time TIME,
  location VARCHAR(150),
  status VARCHAR(30) NOT NULL DEFAULT 'scheduled' CHECK (
    status IN ('scheduled', 'completed', 'cancelled')
  ),
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activities_date ON activities (activity_date);
CREATE INDEX IF NOT EXISTS idx_activities_status ON activities (status);