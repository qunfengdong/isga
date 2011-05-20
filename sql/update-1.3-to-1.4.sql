SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create referencetype and referencedb tables
-------------------------------------------------------------------
-------------------------------------------------------------------

CREATE TABLE referencetype (
  referencetype_id SERIAL PRIMARY KEY,
  referencetype_name TEXT NOT NULL UNIQUE,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id)
);

CREATE TABLE referencedb (
  referencedb_id SERIAL PRIMARY KEY,
  referencetype_id INTEGER REFERENCES referencetype(referencetype_id) NOT NULL,
  referencedb_name TEXT NOT NULL,
--  referencedb_available BOOLEAN NOT NULL,
  referencedb_path TEXT NOT NULL,
  referencedb_description TEXT
);
