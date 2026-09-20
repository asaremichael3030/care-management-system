-- Staff profiles extend the users table with employment information.
-- Only users with staff roles (Administrator, Manager, Care Worker) belong here.
CREATE TABLE IF NOT EXISTS staff (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  job_title VARCHAR(120),
  department VARCHAR(120),
  employment_status VARCHAR(30) NOT NULL DEFAULT 'active' CHECK (
    employment_status IN ('active', 'on_leave', 'suspended', 'left')
  ),
  hire_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_staff_user ON staff (user_id);
CREATE INDEX IF NOT EXISTS idx_staff_status ON staff (employment_status);