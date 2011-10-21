SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create archived tag,type,format columns for FileCollections
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE filecollection ADD COLUMN archive_id INTEGER;
ALTER TABLE filecollection ADD COLUMN filetype_id INTEGER REFERENCES filetype(filetype_id);
ALTER TABLE filecollection ADD COLUMN fileformat_id INTEGER REFERENCES fileformat(fileformat_id);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create file format and type for compressed archives
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary )
  VALUES ( 'Compressed Tar Archive', 'tar.gz', 
  	   'A compressed archive format for storing multiple files as a single file', TRUE );

INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary )
  VALUES ( 'Tar Archive', 'tar', 'An archive format for storing multiple files as a single file', TRUE );

INSERT INTO filetype ( filetype_name, filetype_help ) VALUES 
       ( 'Archived File Collection', 'A compressed archive of a file collection' );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Tweak running script table to support error logging and scheduling jobs through table
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE runningscript ALTER COLUMN runningscript_pid DROP NOT NULL;
ALTER TABLE runningscript ADD COLUMN runningscript_error TEXT;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add ergatis ergatis-v2r16-cgbr1
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO ergatisinstall (ergatisinstall_name, ergatisinstall_version) VALUES ('ergatis-v2r16-cgbr1', 'ergatis-v2r16-cgbr1');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Run/Analysis page
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/Run/Analysis', 'Run Analysis', TRUE, '2columnright');

