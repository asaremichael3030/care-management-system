-- Daily care tasks assigned to staff.
CREATE TABLE IF NOT EXISTS care_tasks (
  id SERIAL PRIMARY KEY,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  assigned_to INTEGER REFERENCES users(id) ON DELETE SET NULL,
  task_type VARCHAR(60) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  due_date DATE,
  due_time TIME,
  status VARCHAR(30) NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'in_progress', 'completed', 'cancelled')
  ),
  completed_at TIMESTAMPTZ,
  completed_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  notes TEXT,
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_care_tasks_resident ON care_tasks (resident_id);
CREATE INDEX IF NOT EXISTS idx_care_tasks_assigned_to ON care_tasks (assigned_to);
CREATE INDEX IF NOT EXISTS idx_care_tasks_status ON care_tasks (status);
CREATE INDEX IF NOT EXISTS idx_care_tasks_due_date ON care_tasks (due_date);