SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create table for monitoring running scripts
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE runningscript (
  runningscript_id SERIAL PRIMARY KEY,
  runningscript_pid INTEGER NOT NULL UNIQUE,
  runningscript_createdat TIMESTAMP NOT NULL DEFAULT now(),
  runningscript_command TEXT NOT NULL
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create table for downloading run evidence and supporting table entries
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE runevidencedownload (
  runevidencedownload_id SERIAL PRIMARY KEY,
  run_id INTEGER REFERENCES run(run_id) NOT NULL UNIQUE,
  runevidencedownload_requestedat TIMESTAMP NOT NULL DEFAULT now(),
  runevidencedownload_createdat TIMESTAMP,
  runevidencedownload_status TEXT REFERENCES jobstatus(jobstatus_name) NOT NULL
);

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) VALUES ('/submit/Run/BuildEvidenceDownload', 'Run::BuildEvidenceDownload', TRUE, 'none');

INSERT INTO notificationtype ( notificationtype_name, notificationpartition_id, notificationtype_subject, notificationtype_template ) VALUES (
  'Run Raw Data Download Ready', 
  (SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = 'RunNotification'),
  'The Raw Data from your ISGA Run is ready',
  'run_evidence_download.mas'
);

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

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) VALUES ('/submit/Account/EditStatus', 'Account::EditStatus', TRUE, 'none');
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/Account/EditStatus') );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Tools for Pipeline Management
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) VALUES ('/submit/GlobalPipeline/EditStatus', 'GlobalPipeline::EditStatus', TRUE, 'none');
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'), 
           (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/GlobalPipeline/EditStatus') );

INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description) 
 VALUES ( 'PipelineConfiguration', 'boolean', 'access_permitted',
          '---
templ: select
NAME: access_permitted
TITLE: Access Permitted
REQUIRED: 1
OPTION: [ TRUE, FALSE ]
ERROR: [ [''Number::matches'', 0, 1] ]
OPT_VAL: [ 1,0]
', 
          'Determines if users can access this pipeline. The setting for an individual class of users will override the global setting for users in that class.'
);

-- add for all existing pipelines
INSERT INTO pipelineconfiguration ( configurationvariable_id, pipeline_id, pipelineconfiguration_type, pipelineconfiguration_value ) 
  SELECT configurationvariable_id, pipeline_id, 'PipelineConfiguration', 1 FROM configurationvariable, globalpipeline
            WHERE configurationvariable_name = 'access_permitted' AND configurationvariable_type = 'PipelineConfiguration';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Remove pipeline_is_installed config var
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM configurationvariable WHERE configurationvariable_name = 'pipeline_is_installed';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- change login requierments for usecase
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE usecase SET usecase_requireslogin=FALSE WHERE usecase_name='/Pipeline/ClusterOptions';
UPDATE usecase SET usecase_requireslogin=FALSE WHERE usecase_name='/Pipeline/ViewParameters';
