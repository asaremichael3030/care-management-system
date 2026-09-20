CREATE TABLE IF NOT EXISTS family_resident_links (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  relationship VARCHAR(80),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, resident_id)
);

CREATE INDEX IF NOT EXISTS idx_family_links_user ON family_resident_links (user_id);
CREATE INDEX IF NOT EXISTS idx_family_links_resident ON family_resident_links (resident_id);