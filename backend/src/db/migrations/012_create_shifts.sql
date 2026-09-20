-- Shifts assign a staff member to a working window.
CREATE TABLE IF NOT EXISTS shifts (
  id SERIAL PRIMARY KEY,
  staff_id INTEGER NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  shift_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  shift_type VARCHAR(50) NOT NULL DEFAULT 'Morning' CHECK (
    shift_type IN ('Morning', 'Afternoon', 'Night', 'Long Day', 'Split', 'On Call', 'Other')
  ),
  status VARCHAR(30) NOT NULL DEFAULT 'scheduled' CHECK (
    status IN ('scheduled', 'completed', 'cancelled', 'no_show')
  ),
  notes TEXT,
  created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_shifts_staff ON shifts (staff_id);
CREATE INDEX IF NOT EXISTS idx_shifts_date ON shifts (shift_date);
CREATE INDEX IF NOT EXISTS idx_shifts_status ON shifts (status);