SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- convert reference release and version
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE referencerelease ADD COLUMN tempdate DATE;
UPDATE referencerelease SET tempdate = date(referencerelease_version);
ALTER TABLE referencerelease ALTER COLUMN tempdate SET NOT NULL;
UPDATE referencerelease SET referencerelease_version = referencerelease_release;
ALTER TABLE referencerelease DROP COLUMN referencerelease_release;
ALTER TABLE referencerelease RENAME COLUMN tempdate TO referencerelease_release;

ALTER TABLE referencerelease ADD COLUMN pipelinestatus_id INTEGER REFERENCES pipelinestatus(pipelinestatus_id);
UPDATE referencerelease SET pipelinestatus_id = a.b FROM (SELECT DISTINCT referencerelease_id AS a, pipelinestatus_id AS b FROM referencedb) AS a
    WHERE referencerelease.referencerelease_id = a.a;
ALTER TABLE referencerelease ALTER COLUMN pipelinestatus_id SET NOT NULL;
ALTER TABLE referencedb DROP COLUMN pipelinestatus_id;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencelabel and referenceformat controlled vocabularies
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE referenceformat ( referenceformat_name TEXT PRIMARY KEY );
CREATE TABLE referencelabel ( referencelabel_name TEXT PRIMARY KEY );
INSERT INTO referencelabel VALUES ('Assembled Genome');
INSERT INTO referencelabel VALUES ('Proteome');

CREATE TABLE referencetemplate (
  referencetemplate_id SERIAL PRIMARY KEY,
  reference_id INTEGER REFERENCES reference(reference_id) NOT NULL,
  referencetemplate_format TEXT REFERENCES referenceformat(referenceformat_name) NOT NULL,
  referencetemplate_label TEXT REFERENCES referencelabel(referencelabel_name)
);

create UNIQUE INDEX referencetemplate_idx on referencetemplate( reference_id,referencetemplate_format,(coalesce(referencetemplate_label,'*** NULL IS HERE ***')));

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Migrate referencetype to referenceformat
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referenceformat ( SELECT referencetype_name FROM referencetype );

ALTER TABLE referencedb ADD COLUMN label TEXT;
UPDATE referencedb SET label = 'Assembled Genome' WHERE referencedb_path ~ '/genome';
UPDATE referencedb SET label = 'Proteome' WHERE referencedb_path ~ '/protein';
UPDATE referencedb SET label = 'Proteome' WHERE referencedb_path ~ '/peptide';


INSERT INTO referencetemplate ( reference_id, referencetemplate_format, referencetemplate_label )
SELECT c.reference_id, b.referencetype_name, a.label FROM referencedb a, referencetype b,
  ( SELECT max(referencerelease_id) AS referencerelease_id, reference_id FROM referencerelease
    GROUP BY reference_id) AS c
  WHERE a.referencetype_id = b.referencetype_id AND a.referencerelease_id = c.referencerelease_id;

ALTER TABLE referencedb ADD COLUMN referencetemplate_id INTEGER REFERENCES referencetemplate(referencetemplate_id);

UPDATE referencedb SET referencetemplate_id = a.referencetemplate_id 
 FROM referencetemplate a, referencetype b, referencerelease c
 WHERE referencedb.referencetype_id = b.referencetype_id AND b.referencetype_name = a.referencetemplate_format 
       AND referencedb.label = a.referencetemplate_label AND referencedb.referencerelease_id = c.referencerelease_id
       AND c.reference_id = a.reference_id;

UPDATE referencedb SET referencetemplate_id = a.referencetemplate_id 
 FROM referencetemplate a, referencetype b, referencerelease c
 WHERE referencedb.referencetype_id = b.referencetype_id AND b.referencetype_name = a.referencetemplate_format 
       AND referencedb.label IS NULL AND a.referencetemplate_label IS NULL 
       AND referencedb.referencerelease_id = c.referencerelease_id AND c.reference_id = a.reference_id;

ALTER TABLE referencedb DROP COLUMN label;
ALTER TABLE referencedb DROP COLUMN referencetype_id;
DROP TABLE referencetype;

ALTER TABLE reference DROP COLUMN referencetag_id;
DROP TABLE referencetag;


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Modify run_builder table to store link to previous run software
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE runbuilder ADD COLUMN run_id INTEGER REFERENCES run(run_id);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Modify reference table to have link
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE reference ADD COLUMN reference_link TEXT;
ALTER TABLE reference DROP CONSTRAINT "reference_reference_path_key";

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add software use cases
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/SoftwareConfiguration/View', 'View Software Configuration', TRUE, '2columnright');
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/SoftwareConfiguration/List', 'List Software Configurations', TRUE, '2columnright');

INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/SoftwareConfiguration/AddRelease', 'Add Software Release', TRUE, '2columnright');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Software/AddRelease', 'Software::AddRelease', TRUE, 'none');

INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/SoftwareConfiguration/EditRelease', 'Edit Software Release', TRUE, '2columnright');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Software/EditRelease', 'Software::EditRelease', TRUE, 'none');

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Software/SetPipelineSoftware', 'Software::SetPipelineSoftware', TRUE, 'none');

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Reference/AddRelease', 'Reference::AddRelease', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Reference/EditRelease', 'Reference::EditRelease', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Reference/SetPipelineReference', 'Reference::SetPipelineReference', TRUE, 'none');


-------------------------------------------------------------------
-------------------------------------------------------------------
-- modify referencedb table to be used for pipelines
-------------------------------------------------------------------
-------------------------------------------------------------------
--ALTER TABLE referencedb ADD COLUMN reference_id INTEGER REFERENCES reference(reference_id);
--UPDATE referencedb SET reference_id = referencerelease.reference_id FROM referencerelease
--  WHERE referencedb.referencerelease_id = referencerelease.referencerelease_id;
ALTER TABLE referencerelease ADD CONSTRAINT referencerelease_key2 UNIQUE (reference_id, referencerelease_id);
--ALTER TABLE referencedb ADD CONSTRAINT referencedb_fk FOREIGN KEY (reference_id, referencerelease_id) 
--        REFERENCES referencerelease(reference_id, referencerelease_id);

CREATE TABLE pipelinereference (
  pipelinereference_id SERIAL PRIMARY KEY,
  pipeline_id INTEGER REFERENCES globalpipeline(pipeline_id) NOT NULL,
  reference_id INTEGER REFERENCES reference(reference_id) NOT NULL,
  referencerelease_id INTEGER,
  pipelinereference_note TEXT,
  CONSTRAINT pipelinereference_key2 UNIQUE (pipeline_id, reference_id ),
  CONSTRAINT pipelinereference_fk FOREIGN KEY (reference_id,referencerelease_id) REFERENCES referencerelease(reference_id,referencerelease_id)
);

CREATE TABLE runreference (
  run_id INTEGER REFERENCES run(run_id) NOT NULL,
  referencerelease_id INTEGER NOT NULL,
  CONSTRAINT runrelease_pk UNIQUE (run_id, referencerelease_id )
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add tables for software used in pipelines
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE software (
  software_id SERIAL PRIMARY KEY,
  software_name TEXT NOT NULL UNIQUE,
  software_link TEXT
);

CREATE TABLE softwarerelease (
  softwarerelease_id SERIAL PRIMARY KEY,
  software_id INTEGER REFERENCES software(software_id) NOT NULL,
  softwarerelease_release date NOT NULL,
  softwarerelease_version TEXT NOT NULL,
  pipelinestatus_id INTEGER REFERENCES pipelinestatus(pipelinestatus_id) NOT NULL,
  softwarerelease_path TEXT NOT NULL,
  CONSTRAINT software_release_k2 UNIQUE (software_id, softwarerelease_id)
);

CREATE TABLE pipelinesoftware (
  pipelinesoftware_id SERIAL PRIMARY KEY,
  pipeline_id INTEGER REFERENCES globalpipeline(pipeline_id) NOT NULL,
  software_id INTEGER REFERENCES software(software_id) NOT NULL,
  softwarerelease_id INTEGER,
  pipelinesoftware_note TEXT,
  CONSTRAINT pipelinesoftware_key2 UNIQUE (pipeline_id, software_id ),
  CONSTRAINT pipelinesoftware_fk FOREIGN KEY (software_id,softwarerelease_id) REFERENCES softwarerelease(software_id,softwarerelease_id)
);

CREATE TABLE runsoftware (
  run_id INTEGER REFERENCES run(run_id) NOT NULL,
  softwarerelease_id INTEGER NOT NULL,
  CONSTRAINT runsoftware_pk UNIQUE (run_id, softwarerelease_id )
);


-------------------------------------------------------------------
-------------------------------------------------------------------
-- View RunBuilder Protocol (TEMPORARY HACK!!!!!)
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/RunBuilder/ViewProtocol', 'Run Protocol', TRUE, '1column');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add DependencyType column to component
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE dependencytype (
 dependencytype_name TEXT PRIMARY KEY
);

INSERT INTO dependencytype ( dependencytype_name ) VALUES ( 'Depends On' );
INSERT INTO dependencytype ( dependencytype_name ) VALUES ( 'Part Of' );

ALTER TABLE component ADD COLUMN component_dependencytype TEXT REFERENCES dependencytype(dependencytype_name);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Drop obsolete pages
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/EditCluster';
DELETE FROM usecase WHERE usecase_name = '/Pipeline/ViewComponents';
  
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
-- Create mapping table for runs and masked components
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE maskedcomponent (
  run_id INTEGER REFERENCES run(run_id) NOT NULL,
  component_id INTEGER REFERENCES component(component_id) NOT NULL,
  CONSTRAINT maskedcomponent_pk UNIQUE (run_id, component_id )
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add account creation policy site configuration
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO configurationvariable ( configurationvariable_name, configurationvariable_type, configurationvariable_form,
       	    			    configurationvariable_description, configurationvariable_datatype )
  VALUES ( 'new_account_policy', 'SiteConfiguration',
'---
templ: select
NAME: tool_is_installed
TITLE: tool_is_installed
REQUIRED: 1
OPTION: [ Open, Closed, Confirmation ]
ERROR: [ [''Number::matches'', 1, 2, 3] ]
OPT_VAL: [1,2, 3]
',
'<p>Determine the account creation policy for this installation.</p>
<ul>
 <li><strong>Open</strong> - Users may create accounts and use them immediately with no oversight</li>
 <li><strong>Closed</strong> - Accounts may only be created by administrators using the create_isga_user.pl script</li>
 <li><strong>Confirmation Required</strong> - Users may request accounts, but requests must be confirmed by an administrator before they can be used.</li>
</ul>
', 
'string' );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Fix ergatis_submission_directory description
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE configurationvariable SET configurationvariable_description = 'Full path to the temporary directory where Ergatis pipelines are built for this project (usually pipelines_building).' WHERE configurationvariable_name = 'ergatis_submission_directory';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Run/Analysis page
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/Run/Analysis', 'Run Analysis', TRUE, '2columnright');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add FileType for Run Analysis page
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO filetype (filetype_name, filetype_help) VALUES ('Run Analysis', 'Contains the name, value, and description of various post run analysis performed on a pipeline run.');
INSERT INTO filetype (filetype_name, filetype_help) VALUES ('Run Parameters', 'Contains the run parameter values used for a pipeline run.');
INSERT INTO filetype (filetype_name, filetype_help) VALUES ('Run Analysis Histogram', 'A histogram for various bins of data.');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Transcriptome tables
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE transcriptome (
  transcriptome_id SERIAL PRIMARY KEY,
  run_id INTEGER REFERENCES run(run_id) NOT NULL UNIQUE 
);

CREATE TABLE nrhit (
  nrhit_id SERIAL PRIMARY KEY,
  transcriptome_id INTEGER REFERENCES transcriptome(transcriptome_id) NOT NULL,
  nrhit_hit TEXT NOT NULL,
  nrhit_description TEXT NOT NULL,
  nrhit_evalue TEXT NOT NULL
);

CREATE TABLE transcriptomecontig (
  transcriptomecontig_id SERIAL PRIMARY KEY,
  transcriptome_id INTEGER REFERENCES transcriptome(transcriptome_id) NOT NULL,
  transcriptomecontig_name TEXT NOT NULL,
  transcriptomecontig_length INTEGER NOT NULL,
  nrhit_id INTEGER REFERENCES nrhit(nrhit_id),
  transcriptomecontig_paraloggroup INTEGER,
  transcriptomecontig_paralogcount INTEGER,
  CONSTRAINT transcritomecontig_name_k2 UNIQUE (transcriptome_id, transcriptomecontig_name )
);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add transcriptome use cases
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/WorkBench/TranscriptomeQueryResult', 'Transcriptome Results', TRUE, '2columnright');
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet)
  VALUES ('/TranscriptomeContig/View', 'Transcriptome Contig', TRUE, '2columnright');

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Run/InstallTranscriptomeData', 'Run::InstallTranscriptomeData', TRUE, 'none');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add transcriptome use cases
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/PipelineBuilder/ResetComponent', 'PipelineBuilder::ResetComponent', TRUE, 'none');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add clusteroutput default base name column
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE clusteroutput ADD COLUMN clusteroutput_basename TEXT;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- change foreign key for user pipeline templates
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE userpipeline DROP CONSTRAINT "userpipeline_userpipeline_template_fkey";
ALTER TABLE userpipeline ADD CONSTRAINT userpipeline_userpipeline_template_fkey 
    FOREIGN KEY (userpipeline_template) REFERENCES pipeline(pipeline_id);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- add siteconfiguration entries for local and shared tmp
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description)
 VALUES ( 'SiteConfiguration', 'path', 'local_tmp',
          '---
NAME: local_tmp
TITLE: local_tmp
REQUIRED: 1
ERROR: ''File::isPath''
',
          'Directory for local disk tmp space.  Please use full path.'
);

-- blank to start with
INSERT INTO siteconfiguration ( configurationvariable_id, siteconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'local_tmp'), '');

INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description)
 VALUES ( 'SiteConfiguration', 'path', 'shared_tmp',
          '---
NAME: shared_tmp
TITLE: shared_tmp
REQUIRED: 1
ERROR: ''File::isPath''
',
          'Directory for shared disk tmp space.  This is important if you use a cluster to perform Toolbox jobs.  Please use full path.'
);

-- blank to start with
INSERT INTO siteconfiguration ( configurationvariable_id, siteconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'shared_tmp'), '');
