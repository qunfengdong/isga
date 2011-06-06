SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create referencetype and referencedb tables
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE referencetag(
  referencetag_id SERIAL PRIMARY KEY,
  referencetag_name TEXT NOT NULL UNIQUE
);

CREATE TABLE reference(
  reference_id SERIAL PRIMARY KEY,
  reference_name TEXT NOT NULL UNIQUE,
  reference_path TEXT NOT NULL UNIQUE,
  reference_description TEXT NOT NULL,
  referencetag_id INTEGER REFERENCES referencetag(referencetag_id) NOT NULL
);

CREATE TABLE referencerelease(
  referencerelease_id SERIAL PRIMARY KEY,
  reference_id INTEGER REFERENCES reference(reference_id) NOT NULL,
  referencerelease_release TEXT NOT NULL UNIQUE,
  referencerelease_version TEXT NOT NULL,
  referencerelease_path TEXT NOT NULL UNIQUE
);

CREATE TABLE referencetype (
  referencetype_id SERIAL PRIMARY KEY,
  referencetype_name TEXT NOT NULL UNIQUE,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL
);

CREATE TABLE referencedb (
  referencedb_id SERIAL PRIMARY KEY,
  referencetype_id INTEGER REFERENCES referencetype(referencetype_id) NOT NULL,
  referencerelease_id INTEGER REFERENCES referencerelease(referencerelease_id) NOT NULL,
  pipelinestatus_id INTEGER REFERENCES pipelinestatus(pipelinestatus_id)NOT NULL,
  referencedb_path TEXT NOT NULL
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Echo to print text
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/Echo', 'Text Echo', FALSE, 'none');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Tools for Account Management
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/Account/Manage', 'Account Management', TRUE, '2columnright');
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/Account/Manage') );

INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/Account/List', 'Account Listing', TRUE, '2columnright');
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/Account/List') );

INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/Account/Search', 'Account Search', TRUE, '2columnright');
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/Account/Search') );

--INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) VALUES ('/submit/Account/Search', 'Account::Search', TRUE, 'none');
--INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
--  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'), 
--           (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/Account/Search') );

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) VALUES ('/submit/Account/EditUserClass', 'Account::EditUserClass', TRUE, 'none');
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/Account/EditUserClass') );
