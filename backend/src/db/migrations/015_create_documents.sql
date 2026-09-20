-- Documents are references to files stored elsewhere.
CREATE TABLE IF NOT EXISTS documents (
  id SERIAL PRIMARY KEY,
  resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  document_type VARCHAR(80) NOT NULL DEFAULT 'Other',
  description TEXT,
  file_url TEXT NOT NULL,
  visible_to_family BOOLEAN NOT NULL DEFAULT FALSE,
  uploaded_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_documents_resident ON documents (resident_id);
CREATE INDEX IF NOT EXISTS idx_documents_type ON documents (document_type);