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
-- Add referencedb label column
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE referencedb ADD COLUMN referencedb_label TEXT;

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
