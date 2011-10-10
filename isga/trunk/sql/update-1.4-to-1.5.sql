SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create archived tag column for file collections
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE filecollection ADD COLUMN archive_id INTEGER;

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
-- Add ergatis ergatis-v2r16-cgbr1
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO ergatisinstall (ergatisinstall_name, ergatisinstall_version) VALUES ('ergatis-v2r16-cgbr1', 'ergatis-v2r16-cgbr1');

