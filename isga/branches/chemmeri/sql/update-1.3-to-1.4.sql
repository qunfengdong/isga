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

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create environments for executing jobs.
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE jobenvironmentpartition (
  jobenvironmentpartition_id SERIAL PRIMARY KEY,
  jobenvironmentpartition_name TEXT UNIQUE NOT NULL,
  jobenvironmentpartition_class TEXT NOT NULL
);

INSERT INTO jobenvironmentpartition ( jobenvironmentpartition_name, jobenvironmentpartition_class ) VALUES ( 'SGEEnvironment', 'ISGA::SGEEnvironment');
INSERT INTO jobenvironmentpartition ( jobenvironmentpartition_name, jobenvironmentpartition_class ) VALUES ( 'UnixEnvironment', 'ISGA::UnixEnvironment');

CREATE TABLE jobenvironment (
  jobenvironment_id SERIAL PRIMARY KEY,
  jobenvironmentpartition_id INTEGER REFERENCES jobenvironmentpartition(jobenvironmentpartition_id) NOT NULL,
  jobenvironment_name TEXT NOT NULL UNIQUE,
  jobenvironment_path TEXT NOT NULL,
  jobenvironment_shell TEXT NOT NULL
);

CREATE TABLE sgeenvironment (
  jobenvironment_id INTEGER REFERENCES jobenvironment(jobenvironment_id) NOT NULL,
  sgeenvironment_executablepath TEXT NOT NULL,
  sgeenvironment_cell TEXT NOT NULL,
  sgeenvironment_execdport INTEGER NOT NULL,
  sgeenvironment_qmasterport INTEGER NOT NULL,
  sgeenvironment_root TEXT NOT NULL,
  sgeenvironment_queue TEXT NOT NULL
);

CREATE TABLE unixenvironment (
  jobenvironment_id INTEGER REFERENCES jobenvironment(jobenvironment_id) NOT NULL,
  unixenvironment_nice INTEGER NOT NULL
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- New use cases for environments
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation) 
  VALUES ('/SiteConfiguration/ListEnvironments', TRUE, 'Execution Environments', '2columnright', FALSE);
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/SiteConfiguration/ListEnvironments') );

INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation) 
  VALUES ('/SiteConfiguration/ViewEnvironment', TRUE, 'View Execution Environment', '2columnright', FALSE);
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/SiteConfiguration/ViewEnvironment') );

INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation) 
  VALUES ('/SiteConfiguration/EditEnvironment', TRUE, 'Edit Execution Environments', '2columnright', FALSE);
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/SiteConfiguration/EditEnvironment') );

INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation) 
  VALUES ('/SiteConfiguration/AddUnixEnvironment', TRUE, 'Add Unix Execution Environments', '2columnright', FALSE);
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/SiteConfiguration/AddUnixEnvironment') );

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin) 
  VALUES ('/submit/SiteConfiguration/AddUnixEnvironment', 'SiteConfiguration::AddUnixEnvironment', TRUE);
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/SiteConfiguration/AddUnixEnvironment') );

INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation) 
  VALUES ('/SiteConfiguration/AddSGEEnvironment', TRUE, 'Add SGE Execution Environments', '2columnright', FALSE);
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/SiteConfiguration/AddSGEEnvironment') );

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin) 
  VALUES ('/submit/SiteConfiguration/AddSGEEnvironment', 'SiteConfiguration::AddSGEEnvironment', TRUE);
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/SiteConfiguration/AddSGEEnvironment') );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Job Configuration tools
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) VALUES (
  '/JobConfiguration/View', 'Job Configuration', TRUE, '2columnright');
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) VALUES (
  '/JobConfiguration/Edit', 'Job Configuration Edit', TRUE, '2columnright');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin) VALUES ('/submit/JobConfiguration/Edit', 'JobConfiguration::Edit', TRUE);

INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/JobConfiguration/View') );
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/JobConfiguration/Edit') );
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/JobConfiguration/Edit') );

CREATE TABLE jobconfiguration (
  jobconfiguration_id SERIAL PRIMARY KEY,
  configurationvariable_id INTEGER REFERENCES configurationvariable(configurationvariable_id) NOT NULL,
  jobtype_id INTEGER REFERENCES jobtype(jobtype_id) NOT NULL,
  userclass_id INTEGER REFERENCES userclass(userclass_id),
  jobconfiguration_type TEXT REFERENCES configurationtype(configurationtype_name) NOT NULL DEFAULT 'JobConfiguration',
  jobconfiguration_value TEXT NOT NULL,
  CONSTRAINT jobconfiguration_k UNIQUE (configurationvariable_id, jobtype_id, userclass_id)
);


INSERT INTO configurationtype (configurationtype_name) VALUES ('JobConfiguration');

DROP TABLE toolconfiguration;
DELETE FROM configurationvariable WHERE configurationvariable_name = 'tool_is_installed';
DELETE FROM configurationtype WHERE configurationtype_name = 'ToolConfiguration';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add job_environment configuration variable
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description) 
 VALUES ( 'JobConfiguration', 'IndexedObject', 'job_environment',
          '---
NAME: job_environment
TITLE: job_environment
REQUIRED: 1
ERROR: ''not_null''
', 
          'Defines the environment under which this job will be executed.'
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Temporary Job Configuration
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO jobconfiguration ( configurationvariable_id, jobtype_id, jobconfiguration_type, jobconfiguration_value )
 VALUES ((SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'job_environment'),
         (SELECT jobtype_id FROM jobtype WHERE jobtype_name = 'Blast'), 'JobConfiguration', 3);

INSERT INTO jobconfiguration ( configurationvariable_id, jobtype_id, jobconfiguration_type, jobconfiguration_value )
 VALUES ((SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = ''),
         (SELECT jobtype_id FROM jobtype WHERE jobtype_name = 'Blast'), 'JobConfiguration', '');

INSERT INTO jobconfiguration ( configurationvariable_id, jobtype_id, jobconfiguration_type, jobconfiguration_value )
 VALUES ((SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = ''),
         (SELECT jobtype_id FROM jobtype WHERE jobtype_name = 'Blast'), 'JobConfiguration', '');

--INSERT INTO jobconfiguration ( configurationvariable_id, jobtype_id, jobconfiguration_type, jobconfiguration_value )
-- VALUES ((SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = ''),
--         (SELECT jobtype_id FROM jobtype WHERE jobtype_name = 'Blast'), 'JobConfiguration', '');

