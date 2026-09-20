-- Notes recorded about a resident's day.
CREATE TABLE IF NOT EXISTS care_notes (
  id SERIAL PRIMARY KEY,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  note_type VARCHAR(60) NOT NULL,
  content TEXT NOT NULL,
  recorded_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  visible_to_family BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_care_notes_resident ON care_notes (resident_id);
CREATE INDEX IF NOT EXISTS idx_care_notes_recorded_at ON care_notes (recorded_at);