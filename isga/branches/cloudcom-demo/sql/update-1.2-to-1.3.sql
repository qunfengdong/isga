SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Add notification types for upload requests
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO notificationtype ( notificationtype_name, notificationpartition_id, notificationtype_subject, notificationtype_template ) VALUES
  ( 'Upload Request Complete', ( SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = 'AccountNotification' ), 'Your ISGA upload request is complete', 'upload_request_complete.mas');

INSERT INTO notificationtype ( notificationtype_name, notificationpartition_id, notificationtype_subject, notificationtype_template ) VALUES
  ( 'Upload Request Failed', ( SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = 'AccountNotification' ), 'Your ISGA upload request failed', 'upload_request_failed.mas');

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Don't force empty file descriptions
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE fileresource ALTER COLUMN fileresource_description DROP NOT NULL;

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Add use cases for upload requested pages
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation) 
  VALUES ('/RunBuilder/UploadRequested', TRUE, 'Upload Requested', '2columnright', FALSE);

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Add table for passing upload request information to upload script
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE uploadrequestpartition (
  uploadrequestpartition_id SERIAL PRIMARY KEY,
  uploadrequestpartition_name TEXT UNIQUE NOT NULL,
  uploadrequestpartition_class TEXT NOT NULL
);

INSERT INTO uploadrequestpartition ( uploadrequestpartition_name, uploadrequestpartition_class ) VALUES ( 'RunBuilderUploadRequest', 'ISGA::RunBuilderUploadRequest' );
INSERT INTO uploadrequestpartition ( uploadrequestpartition_name, uploadrequestpartition_class ) VALUES ( 'JobUploadRequest', 'ISGA::JobUploadRequest' );

CREATE TABLE uploadrequest (
  uploadrequest_id SERIAL PRIMARY KEY,
  uploadrequestpartition_id INTEGER REFERENCES uploadrequestpartition(uploadrequestpartition_id) NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  uploadrequest_url TEXT NOT NULL,
  uploadrequest_description TEXT,
  uploadrequest_status TEXT REFERENCES jobstatus(jobstatus_name) NOT NULL,
  uploadrequest_createdat TIMESTAMP NOT NULL,
  uploadrequest_finishedat TIMESTAMP,
  uploadrequest_exception TEXT,
  uploadrequest_username TEXT
);

CREATE TABLE runbuilderuploadrequest (
  uploadrequest_id INTEGER REFERENCES uploadrequest(uploadrequest_id) PRIMARY KEY,
  runbuilder_id INTEGER REFERENCES runbuilder(runbuilder_id) NOT NULL,
  pipelineinput_id INTEGER REFERENCES pipelineinput(pipelineinput_id) NOT NULL
);

CREATE TABLE jobuploadrequest (
  uploadrequest_id INTEGER REFERENCES uploadrequest(uploadrequest_id) PRIMARY KEY,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL
);

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Remove direct file upload - it isn't used making it a security concern
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM usecase WHERE usecase_name = '/File/Upload';
DELETE FROM usecase WHERE usecase_name = '/submit/File/Upload';

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Add upload size limit to site configuration
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description)
 VALUES ( 'SiteConfiguration', 'integer', 'upload_size_limit',
          '---
NAME: upload_size_limit
TITLE: upload_size_limit
REQUIRED: 1
ERROR: ''int''
',
          'The maximum file size (in MB) that may be uploaded to the server. Larger files must be supplied via a dowload link.'
);

INSERT INTO siteconfiguration ( configurationvariable_id, siteconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'upload_size_limit'), 100);


-------------------------------------------------------------------
-------------------------------------------------------------------
--  Add component subclasses
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE component ADD COLUMN component_subclass TEXT;

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Replace '' coordinates in workflow with NULL
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE workflow SET workflow_coordinates = NULL WHERE workflow_coordinates = '';

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Get rid of hacky blank component names
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE component ALTER COLUMN component_name DROP NOT NULL;
UPDATE component SET component_name = NULL WHERE component_name = '';

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Remove cruft components from prok. annotation
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM component WHERE component_ergatisname = 'formatdb.workbench_nuc';
DELETE FROM component WHERE component_ergatisname = 'formatdb.workbench_prot';

-------------------------------------------------------------------
-------------------------------------------------------------------
--  Add new status for published pipelines
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO pipelinestatus ( pipelinestatus_name) VALUES ( 'Published' );

ALTER TABLE pipelinestatus ADD COLUMN pipelinestatus_isavailable BOOLEAN;
UPDATE pipelinestatus SET pipelinestatus_isavailable = TRUE WHERE pipelinestatus_name IN ( 'Available', 'Published' );
UPDATE pipelinestatus SET pipelinestatus_isavailable = FALSE WHERE pipelinestatus_isavailable IS NULL;
ALTER TABLE pipelinestatus ALTER COLUMN pipelinestatus_isavailable SET NOT NULL;


-------------------------------------------------------------------
-------------------------------------------------------------------
--  Add Ergatis projects
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE ergatisinstall (
  ergatisinstall_id SERIAL PRIMARY KEY,
  ergatisinstall_name TEXT NOT NULL,
  ergatisinstall_version TEXT NOT NULL
);

INSERT INTO ergatisinstall ( ergatisinstall_name, ergatisinstall_version ) 
       VALUES ( 'ergatis-v2r11-cgbr1', 'ergatis-v2r11-cgbr1' );

-------------------------------------------------------------------
-------------------------------------------------------------------
--  update component template to be ergatis install specific
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE componenttemplate DROP CONSTRAINT componenttemplate_componenttemplate_name_key;
ALTER TABLE componenttemplate ADD COLUMN ergatisinstall_id INTEGER REFERENCES ergatisinstall(ergatisinstall_id);
UPDATE componenttemplate SET ergatisinstall_id = ( SELECT ergatisinstall_id FROM ergatisinstall WHERE ergatisinstall_name = 'ergatis-v2r11-cgbr1' );
ALTER TABLE componenttemplate ALTER COLUMN ergatisinstall_id SET NOT NULL;
ALTER TABLE componenttemplate DROP COLUMN componenttemplate_formpath;
ALTER TABLE componenttemplate ADD CONSTRAINT componenttemplate_name_version_key UNIQUE ( componenttemplate_name, ergatisinstall_id );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- update cluster to be ergatis install specific
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE cluster DROP CONSTRAINT cluster_cluster_name_key;
ALTER TABLE cluster DROP CONSTRAINT cluster_cluster_subclass_key;
ALTER TABLE cluster ADD COLUMN ergatisinstall_id INTEGER REFERENCES ergatisinstall(ergatisinstall_id);
UPDATE cluster SET ergatisinstall_id = ( SELECT ergatisinstall_id FROM ergatisinstall WHERE ergatisinstall_name = 'ergatis-v2r11-cgbr1' );
ALTER TABLE cluster ALTER COLUMN ergatisinstall_id SET NOT NULL;
ALTER TABLE cluster ADD CONSTRAINT cluster_name_version_key UNIQUE ( cluster_name, ergatisinstall_id );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- update clusterinput to be ergatis install specific
-------------------------------------------------------------------
-------------------------------------------------------------------

ALTER TABLE clusterinput DROP CONSTRAINT clusterinput_clusterinput_name_key;
ALTER TABLE clusterinput ADD COLUMN ergatisinstall_id INTEGER REFERENCES ergatisinstall(ergatisinstall_id);
UPDATE clusterinput SET ergatisinstall_id = ( SELECT ergatisinstall_id FROM ergatisinstall WHERE ergatisinstall_name = 'ergatis-v2r11-cgbr1' );
ALTER TABLE clusterinput ALTER COLUMN ergatisinstall_id SET NOT NULL;
ALTER TABLE clusterinput ADD CONSTRAINT clusterinput_name_version_key UNIQUE ( clusterinput_name, ergatisinstall_id );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- add subclass pipeline for cluster inputs
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE clusterinput ADD COLUMN clusterinput_subclass TEXT;
UPDATE clusterinput SET clusterinput_subclass = 'CDSFASTA' WHERE clusterinput_name = 'CDS_FASTA';
UPDATE clusterinput SET clusterinput_subclass = 'COGBSML' WHERE clusterinput_name = 'COG_BSML';
UPDATE clusterinput SET clusterinput_subclass = 'FullTranslatedList' WHERE clusterinput_name = 'FULL_TRANSLATED_LIST';
UPDATE clusterinput SET clusterinput_subclass = 'GenePrediction' WHERE clusterinput_name = 'Gene_Prediction';
UPDATE clusterinput SET clusterinput_subclass = 'OverlapAnalysisEvidenceList' WHERE clusterinput_name = 'Overlap_Analysis_Evidence_Input';
UPDATE clusterinput SET clusterinput_subclass = 'OverlapAnalysisRNAInput' WHERE clusterinput_name = 'Overlap_Analysis_RNA_Input';
UPDATE clusterinput SET clusterinput_subclass = 'PFuncEvidence' WHERE clusterinput_name = 'P_Func_Evidence';
UPDATE clusterinput SET clusterinput_subclass = 'ParseEvidenceFeatureInput' WHERE clusterinput_name = 'Parse_Evidence_Feature_Input';
UPDATE clusterinput SET clusterinput_subclass = 'FRGInput' WHERE clusterinput_name = 'FRG_Input';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- update component to be ergatis install specific
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE component DROP CONSTRAINT component_component_ergatisname_key;
ALTER TABLE component DROP CONSTRAINT component_cluster_index_key;

ALTER TABLE component ADD COLUMN ergatisinstall_id INTEGER REFERENCES ergatisinstall(ergatisinstall_id);
UPDATE component SET ergatisinstall_id = ( SELECT ergatisinstall_id FROM ergatisinstall WHERE ergatisinstall_name = 'ergatis-v2r11-cgbr1' );
ALTER TABLE component ALTER COLUMN ergatisinstall_id SET NOT NULL;
ALTER TABLE component ADD CONSTRAINT component_name_version_key UNIQUE ( component_ergatisname, ergatisinstall_id );
ALTER TABLE component ADD CONSTRAINT component_cluster_index_version_key UNIQUE (cluster_id, component_index, ergatisinstall_id);  

-------------------------------------------------------------------
-------------------------------------------------------------------
--  pipeline versioning
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE globalpipeline ADD COLUMN globalpipeline_version INTEGER;
UPDATE globalpipeline SET globalpipeline_version = 1;
ALTER TABLE globalpipeline ALTER COLUMN globalpipeline_version SET NOT NULL;
ALTER TABLE globalpipeline ADD CONSTRAINT globalpipeline_ck UNIQUE (pipeline_id, globalpipeline_version);

ALTER TABLE globalpipeline ADD COLUMN globalpipeline_release TEXT;
UPDATE globalpipeline SET globalpipeline_release = 'Jan 2010' 
  WHERE globalpipeline_image = '/include/img/prokaryote-annotation-pipeline.png';
UPDATE globalpipeline SET globalpipeline_release = 'Jun 2010' 
  WHERE globalpipeline_image = '/include/img/assembly-pipeline.png';
ALTER TABLE globalpipeline ALTER COLUMN globalpipeline_release SET NOT NULL;

ALTER TABLE globalpipeline ADD COLUMN ergatisinstall_id INTEGER REFERENCES ergatisinstall(ergatisinstall_id);
UPDATE globalpipeline SET ergatisinstall_id = 
( SELECT ergatisinstall_id FROM ergatisinstall WHERE ergatisinstall_name = 'ergatis-v2r11-cgbr1' );
ALTER TABLE globalpipeline ALTER COLUMN ergatisinstall_id SET NOT NULL;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Fix misnamed column in emailnotification table
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE emailnotification RENAME COLUMN notification_email TO emailnotification_email;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Migrate file_repository configuration variables to site configuration
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description) 
 VALUES ( 'SiteConfiguration', 'path', 'file_repository',
          '---
NAME: file_repository
TITLE: file_repository
REQUIRED: 1
ERROR: ''File::isPath''
', 
	  'Directory to store files uploaded to ISGA from users.  Please use full path.'
);

-- blank to start with
INSERT INTO siteconfiguration ( configurationvariable_id, siteconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'file_repository'), '');


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create ergatis_project_directory pipeline configuration variable
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description) 
 VALUES ( 'PipelineConfiguration', 'path', 'ergatis_project_directory',
          '---
NAME: ergatis_project_directory
TITLE: ergatis_project_directory
REQUIRED: 1
ERROR: ''File::isPath''
', 
	  'Directory where this ergatis project is installed.  Please use full path.'
);

-- blank to start with needed for all pipelines
INSERT INTO pipelineconfiguration ( configurationvariable_id, pipeline_id, pipelineconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'ergatis_project_directory'), 
 (SELECT pipeline_id FROM globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation'), '');

-- blank to start with needed for all pipelines
INSERT INTO pipelineconfiguration ( configurationvariable_id, pipeline_id, pipelineconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'ergatis_project_directory'), 
 (SELECT pipeline_id FROM globalpipeline WHERE globalpipeline_subclass = 'CeleraAssembly'), '');


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create ergatis_submission_directory pipeline configuration variable
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description) 
 VALUES ( 'PipelineConfiguration', 'path', 'ergatis_submission_directory',
          '---
NAME: ergatis_submission_directory
TITLE: ergatis_submission_directory
REQUIRED: 1
ERROR: ''File::isPath''
', 
	  'Directory where this ergatis project is installed.  Please use full path.'
);


-- blank to start with needed for all pipelines
INSERT INTO pipelineconfiguration ( configurationvariable_id, pipeline_id, pipelineconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'ergatis_submission_directory'), 
 (SELECT pipeline_id FROM globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation'), '');

-- blank to start with needed for all pipelines
INSERT INTO pipelineconfiguration ( configurationvariable_id, pipeline_id, pipelineconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'ergatis_submission_directory'), 
 (SELECT pipeline_id FROM globalpipeline WHERE globalpipeline_subclass = 'CeleraAssembly'), '');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create ergatis_project_name pipeline configuration variable
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description) 
 VALUES ( 'PipelineConfiguration', 'string', 'ergatis_project_name',
          '---
NAME: ergatis_project_name
TITLE: ergatis_project_name
REQUIRED: 1
ERROR: ''not_null''
', 
	  'Name stored in ergatis web interface for the ergatis project where this pipeline is run.'
);


-- blank to start with needed for all pipelines
INSERT INTO pipelineconfiguration ( configurationvariable_id, pipeline_id, pipelineconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'ergatis_project_name'), 
 (SELECT pipeline_id FROM globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation'), '');

-- blank to start with needed for all pipelines
INSERT INTO pipelineconfiguration ( configurationvariable_id, pipeline_id, pipelineconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'ergatis_project_name'), 
 (SELECT pipeline_id FROM globalpipeline WHERE globalpipeline_subclass = 'CeleraAssembly'), '');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add shareable resources
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE shareableresource ( shareableresource_name TEXT PRIMARY KEY );
INSERT INTO shareableresource ( shareableresource_name ) VALUES ( 'ISGA::Run' );
INSERT INTO shareableresource ( shareableresource_name ) VALUES ( 'ISGA::UserPipeline' );
INSERT INTO shareableresource ( shareableresource_name ) VALUES ( 'ISGA::File' );
INSERT INTO shareableresource ( shareableresource_name ) VALUES ( 'ISGA::FileCollection' );

CREATE TABLE resourceshare (
  resourceshare_id SERIAL PRIMARY KEY,
  party_id INTEGER REFERENCES party(party_id) NOT NULL,
  resourceshare_resource INTEGER NOT NULL,
  resourceshare_resourceclass TEXT REFERENCES shareableresource(shareableresource_name) NOT NULL,
  CONSTRAINT partyresourcemap_ck1 UNIQUE (party_id, resourceshare_resource, resourceshare_resourceclass)
  );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Fix news archival column name
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE news RENAME COLUMN news_expireson TO news_archiveon;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add new job types for Hawkeye and remove old and unused jobtypes
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO jobtype (jobtype_name, jobtype_class) VALUES ('CeleraToHawkeye', 'ISGA::Job::CeleraToHawkeye');
INSERT INTO jobtype (jobtype_name, jobtype_class) VALUES ('NewblerToHawkeye', 'ISGA::Job::NewblerToHawkeye');
INSERT INTO jobtype (jobtype_name, jobtype_class) VALUES ('MiraToHawkeye', 'ISGA::Job::MiraToHawkeye');
DELETE FROM toolconfiguration WHERE jobtype_id = ( SELECT jobtype_id FROM jobtype WHERE jobtype_name = 'Hawkeye' );
DELETE FROM jobtype WHERE jobtype_name = 'MEME';
DELETE FROM jobtype WHERE jobtype_name = 'MSA';
DELETE FROM jobtype WHERE jobtype_name = 'Hawkeye';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add new generic job usecase and remove old and unused ones
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation) 
  VALUES ('/WorkBench/Form', TRUE, 'Workbench Submission', '2columnright', FALSE);

INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_hasdocumentation)
  VALUES ('/submit/WorkBench/RunJob', 'WorkBench::RunJob', TRUE, FALSE);

INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation)
  VALUES ('/WorkBench/Result', TRUE, 'Workbench Result', '2columnright', FALSE);

INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation)
  VALUES ('/WorkBench/GenomeFeatureQueryResult', TRUE, 'Genome Feature Search Results', '2columnright', FALSE);

DELETE FROM usecase WHERE usecase_name = '/WorkBench/Blast';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/Blast';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/MSA';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/ConfirmMSA';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/Blast';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/MSA';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/MSA';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/ProtDist';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/ProtPars';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/ProtML';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/DnaPars';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/DnaDist';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/DnaML';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/ProtDist';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/ProtPars';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/ProtML';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/DnaPars';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/DnaDist';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/DnaML';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/ProtDist';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/ProtPars';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/ProtML';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/DnaDist';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/DnaPars';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/DnaML';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/NewblerToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/NewblerToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/NewblerToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/CeleraToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/CeleraToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/CeleraToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/MiraToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/MiraToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/MiraToHawkeye';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/Hawkeye';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/HawkeyeInputUpload';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/NewblerForConsed';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/NewblerScaffold4Consed';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/NewblerForConsed';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/SffToFasta';
DELETE FROM usecase WHERE usecase_name = '/submit/WorkBench/SffToFasta';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/SffToFasta';
DELETE FROM usecase WHERE usecase_name = '/WorkBench/Results/GenomeFeatureQuery';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Moved JobType subclasses
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE jobtype SET jobtype_class = 'ISGA::JobType::BLAST' WHERE jobtype_name = 'Blast';
UPDATE jobtype SET jobtype_class = 'ISGA::JobType::Consed' WHERE jobtype_name = 'Consed';
UPDATE jobtype SET jobtype_class = 'ISGA::JobType::SffToFasta' WHERE jobtype_name = 'SffToFasta';
UPDATE jobtype SET jobtype_class = 'ISGA::JobType::CeleraToHawkeye' WHERE jobtype_name = 'CeleraToHawkeye';
UPDATE jobtype SET jobtype_class = 'ISGA::JobType::NewblerToHawkeye' WHERE jobtype_name = 'NewblerToHawkeye';
UPDATE jobtype SET jobtype_class = 'ISGA::JobType::MiraToHawkeye' WHERE jobtype_name = 'MiraToHawkeye';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add PhylloEGGS
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO jobtype (jobtype_name, jobtype_class) VALUES ('PhyloEGGS', 'ISGA::JobType::PhyloEGGS');

INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary ) VALUES ('PhyloEGGS', 'xxx', 'A Directory of files produced by PhyloEGGS', TRUE);

INSERT INTO filetype ( filetype_name, filetype_help )
  VALUES ( 'VizPhyloEGGS', 'Files intended to be used for VizPhyloEGGS' );

INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary ) VALUES ('Newick', 'newick', 'A file to represent graph-theoretical trees with edge lengths using parentheses and commas.', TRUE);

INSERT INTO filetype ( filetype_name, filetype_help )
  VALUES ( 'Phylogenetic Tree', 'A branching diagram or "tree" showing the inferred evolutionary relationships among various biological species or other entities based upon similarities and differences in their physical and/or genetic characteristics.' );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add GridBlast
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO jobtype (jobtype_name, jobtype_class) VALUES ('GridBlast', 'ISGA::JobType::GridBlast');

-------------------------------------------------------------------
-------------------------------------------------------------------
--  fix file formats
-------------------------------------------------------------------
-------------------------------------------------------------------

UPDATE fileformat SET fileformat_help = 'A text-based format for representing either nucleic acid sequences or peptide sequences, in which base pairs or amino acids are represented using single-letter codes. The format also allows for sequence names and comments to precede the sequences. http://www.ncbi.nlm.nih.gov/blast/fasta.shtml' WHERE fileformat_name = 'FASTA';
UPDATE fileformat SET fileformat_help = 'BLAST tabulated file' WHERE fileformat_name = 'BTAB';
UPDATE fileformat SET fileformat_help = 'This is a script that can be run in gnuplot to reproduce the output image.  Modification of this script will allow you to reformat your image to your liking or perhaps output it to a different image type.' WHERE fileformat_name = 'GNUPlot Commands Script';
UPDATE fileformat SET fileformat_help = 'Bioinformatic Sequence Markup Language (BSML)is a public domain XML application for bioinformatic data.  BSML provides a management tool, visualization interface and container for sequences and other bioinformatic data. BSML may be used in combination with LabBook''s Genomic XML Viewer (free to the scientific community) or Genomic Browser to provide a single document interface to all project data.  http://bsml.sourceforge.net/' WHERE fileformat_name = 'BSML';
UPDATE fileformat SET fileformat_help = 'The raw results produced by HMMPFAM.  This report consists of three sections: a ranked list of the best scoring HMMs, a list of the best scoring domains in order of their occurrence in the sequence, and alignments for all the best scoring domains. A sequence score may be higher than a domain score for the same sequence if there is more than one domain in the sequence; the sequence score takes into account all the domains. All sequences scoring above the -E and -T cutoffs are shown in the first list, then every domain found in this list is shown in the second list of domain hits.  For detailed information, please see this pdf document (pages 26 - 27): ftp://selab.janelia.org/pub/software/hmmer/CURRENT/Userguide.pdf' WHERE fileformat_name = 'HMMPFAM Raw Results';
UPDATE fileformat SET fileformat_help = 'This file has the final gene predictions from glimmer3. Its format is the fasta-header line of the sequence followed by one line per gene.  The columns are:<br>Column 1 The identifier of the predicted gene. The numeric portion matches the number in the ID column of the .detail file.<br>Column 2 The start position of the gene.<br>Column 3 The end position of the gene. This is the last base of the stop codon, i.e., it includes the stop codon.<br>Column 4 The reading frame.<br>Column 5 The per-base raw score of the gene. This is slightly different from the value in the .detail file, because it includes adjustments for the PWM and start-codon frequency.<br>For detailed information, please see this pdf document (pages 13 - 14): http://www.cbcb.umd.edu/software/glimmer/glim302notes.pdf' WHERE fileformat_name = 'Glimmer3 Prediction Results';
UPDATE fileformat SET fileformat_help = 'The .detail file begins with the command that invoked the program and a list of the parameters used by the program.  Following that, for each sequence in the input file the fasta-header line is echoed and followed by a list of orfs that were long enough for glimmer3 to score.  For detailed information, please see this pdf document (pages 11 - 13): http://www.cbcb.umd.edu/software/glimmer/glim302notes.pdf' WHERE fileformat_name = 'Glimmer3 Detailed Results';
UPDATE fileformat SET fileformat_help = 'This is the data produced by Asgard.  It includes the database match identifies as well as associated EC and GO terms.' WHERE fileformat_name = 'Asgard Raw Result';
UPDATE fileformat SET fileformat_help = 'The flat file format used by Genbank to described an annototated genome.  A sampel file can be viewed here: http://www.ncbi.nlm.nih.gov/Sitemap/samplerecord.html.' WHERE fileformat_name = 'Genbank';
UPDATE fileformat SET fileformat_help = '. The report consists of three major sections: (1) the header, which contains information about the query sequence, the database searched. On the Web, there is also a graphical overview; (2) the one-line descriptions of each database sequence found to match the query sequence; these provide a quick overview for browsing; (3) the alignments for each database sequence matched (there may be more than one alignment for a database sequence it matches).  http://www.ncbi.nlm.nih.gov/books/bv.fcgi?rid=handbook.section.615' WHERE fileformat_name = 'BLAST Raw Results';
UPDATE fileformat SET fileformat_help = 'This program first does a BLAST search (Altschul, et al., 1990) (http://blast.wustl.edu) of each protein against niaa and stores all significant matches in a mini-database. Then a modified Smith-Waterman alignment (Smith and Waterman, 1981) is performed on the protein against the mini-database of BLAST hits. In order to identify potential frameshifts or point mutations in the sequence, the gene is extended 300 nucleotides upstream and downstream of the predicted coding region. If significant homology to a match protein exists and extends into a different frame from that predicted, or extends through a stop codon, the program will continue the alignment past the boundaries of the predicted coding region. The results can be viewed both as pairwise and as multiple alignments of the top scoring matches.  The raw results are presented in btab (BLAST tabulated format).' WHERE fileformat_name = 'BER Raw Results';
UPDATE fileformat SET fileformat_help = 'NCBI tbl format.  The feature table format allows different kinds of features (e.g., gene, mRNA, coding region, tRNA) and qualifiers (e.g., /product, /note) to be annotated. The valid features and qualifiers are restricted to those approved by the International Nucleotide Sequence Database Collaboration.  http://www.ncbi.nlm.nih.gov/Sequin/table.html#Table%20Layout' WHERE fileformat_name = 'Table';
UPDATE fileformat SET fileformat_help = 'GFF is a format for describing genes and other features associated with DNA, RNA and Protein sequences. The current specification can be found at http://www.sanger.ac.uk/Software/formats/GFF/GFF_Spec.shtml.' WHERE fileformat_name = 'GFF';
UPDATE fileformat SET fileformat_help = 'The raw results produced by RNAmmer.  This report consists of three sections: a ranked list of the best scoring HMMs, a list of the best scoring domains in order of their occurrence in the sequence, and alignments for all the best scoring domains. A sequence score may be higher than a domain score for the same sequence if there is more than one domain in the sequence; the sequence score takes into account all the domains. All sequences scoring above the -E and -T cutoffs are shown in the first list, then every domain found in this list is shown in the second list of domain hits.' WHERE fileformat_name = 'RNAmmer HMM report';
UPDATE fileformat SET fileformat_help = 'The default output for tRNAscan-SE includes overall statistics for the various component programs (trnascan(14), eufindtrna(15) and cove(16)) as well as summary data for the entire search. The summary data includes counts of the total number of tRNAs found, the number of tRNA pseudogenes found, number of tRNAs with introns and which anticodons were detected. Finally, the output shows the predicted secondary structure for each identified sequence.  The output also displays the overall length of the sequence, the location of the anticodon and the overall tRNAscan-SE score. tRNAscan-SE scores for known tRNA sequences for various species are included on the website to facilitate evaluation of the significance of the score.' WHERE fileformat_name = 'tRNAscan Raw Result';
UPDATE fileformat SET fileformat_help = 'The Graphics Interchange Format (GIF) is a bitmap image format that was introduced by CompuServe in 1987 and has since come into widespread usage on the World Wide Web due to its wide support and portability.' WHERE fileformat_name = 'GIF';
UPDATE fileformat SET fileformat_help = 'This is the Encapsulated PostScript format. A PostScript document with additional restrictions intended to make EPS files usable as a graphics file format. In other words, EPS files are more-or-less self-contained, reasonably predictable PostScript documents that describe an image or drawing, that can be placed within another PostScript document.' WHERE fileformat_name = 'EPS';
UPDATE fileformat SET fileformat_help = 'The graphical output from SignalP (neural network) comprises three different scores, C, S and Y. Two additional scores are reported in the SignalP3-NN output, namely the S-mean and the D-score, but these are only reported as numerical values. For each organism class in SignalP; Eukaryote, Gram-negative and Gram-positive, two different neural networks are used, one for predicting the actual signal peptide and one for predicting the position of the signal peptidase I (SPase I) cleavage site. The S-score for the signal peptide prediction is reported for every single amino acid position in the submitted sequence, with high scores indicating that the corresponding amino acid is part of a signal peptide, and low scores indicating that the amino acid is part of a mature protein. The C-score is the ``cleavage site'' score. For each position in the submitted sequence, a C-score is reported, which should only be significantly high at the cleavage site. Confusion is often seen with the position numbering of the cleavage site. When a cleavage site position is referred to by a single number, the number indicates the first residue in the mature protein, meaning that a reported cleavage site between amino acid 26-27 corresponds to that the mature protein starts at (and include) position 27. Y-max is a derivative of the C-score combined with the S-score resulting in a better cleavage site prediction than the raw C-score alone. This is due to the fact that multiple high-peaking C-scores can be found in one sequence, where only one is the true cleavage site. The cleavage site is assigned from the Y-score where the slope of the S-score is steep and a significant C-score is found. The S-mean is the average of the S-score, ranging from the N-terminal amino acid to the amino acid assigned with the highest Y-max score, thus the S-mean score is calculated for the length of the predicted signal peptide. The S-mean score was in SignalP version 2.0 used as the criteria for discrimination of secretory and non-secretory proteins. The D-score is introduced in SignalP version 3.0 and is a simple average of the S-mean and Y-max score. The score shows superior discrimination performance of secretory and non-secretory proteins to that of the S-mean score which was used in SignalP version 1 and 2. For non-secretory proteins all the scores represented in the SignalP3-NN output should ideally be very low. The hidden Markov model calculates the probability of whether the submitted sequence contains a signal peptide or not. The eukaryotic HMM model also reports the probability of a signal anchor, previously named uncleaved signal peptides. Furthermore, the cleavage site is assigned by a probability score together with scores for the n-region, h-region, and c-region of the signal peptide, if such one is found.' WHERE fileformat_name = 'SignalP Raw Result';
UPDATE fileformat SET fileformat_help = 'The output is a table in plain text (see the example below). For each input sequence one table row is output. The columns are as follows:<br>Name - Sequence name truncated to 20 characters<br>Len - Sequence length<br>cTP, mTP, SP, other - Final NN scores on which the final prediction is based (Loc, see below). Note that the scores are not really probabilities, and they do not necessarily add to one. However, the location with the highest score is the most likely according to TargetP, and the relationship between the scores (the reliability class, see below) may be an indication of how certain the prediction is.<br>Loc - Prediction of localization, based on the scores above; the possible values are:<br>     C       Chloroplast, i.e. the sequence contains cTP, a chloroplast transit peptide;<br>     M       Mitochondrion, i.e. the sequence contains mTP, a mitochondrial targeting peptide<br>     S       Secretory pathway, i.e. the sequence contains SP, a signal peptide;<br>     _       Any other location;<br>	*       "do not know"; indicates that cutoff restrictions were set and the winning network output score was below the requested cutoff for that category.<br>RC - Reliability class, from 1 to 5, where 1 indicates the strongest prediction. RC is a measure of the size of the difference between the highest (winning) and the second highest output scores. There are 5 reliability classes, defined as follows:<br>     1 : diff > 0.800<br>     2 : 0.800 > diff > 0.600<br>    3 : 0.600 > diff > 0.400<br>    4 : 0.400 > diff > 0.200<br>    5 : 0.200 > diff<br>Thus, the lower the value of RC the safer the prediction.<br>TPlen - Predicted presequence length; it appears only when TargetP was asked to perform cleavage site predictions' WHERE fileformat_name = 'TargetP Raw Result';
UPDATE fileformat SET fileformat_help = 'For the raw output, tmhmm gives some statistics and a list of the location of the predicted transmembrane helices and the predicted location of the intervening loop regions.  If the whole sequence is labeled as inside or outside, the prediction  is that it contains no membrane helices.  It is probably not wise to interpret it as a prediction of location. The prediction gives the most probable location and orientation of transmembrane helices in the sequence. It is found by an algorithm called N-best (or 1-best in this case) that sums over all paths through the model with the same location and direction of the helices.<br>The first few lines gives some statistics:<br><br>  * Length: the length of the protein sequence.<br>  * Number of predicted TMHs: The number of predicted transmembrane helices.<br>  * Exp number of AAs in TMHs: The expected number of amino acids intransmembrane helices. If this number is larger than 18 it is very likely to be a transmembrane protein (OR have a signal peptide).<br>  * Exp number, first 60 AAs: The expected number of amino acids in transmembrane helices in the first 60 amino acids of the protein. If this number more than a few, you should be warned that a predicted transmembrane helix in the N-term could be a signal peptide.<br>  * Total prob of N-in: The total probability that the N-term is on the cytoplasmic side of the membrane.<br>  * POSSIBLE N-term signal sequence: a warning that is produced when "Exp number, first 60 AAs" is larger than 10.' WHERE fileformat_name = 'TMhmm Raw Result';
UPDATE fileformat SET fileformat_help = 'The default output for Prosite Scan.  The header contains the sequenced header for the protein scanned against prosite as well as the matching Prosite information (ID, etc.)  Below the header will be the start position, end position, and matching pattern from the scan.' WHERE fileformat_name = 'Prosite Scan Raw Result';
UPDATE fileformat SET fileformat_help = 'The organisms genes are listed sorted by their end coordinate and terminators are output between them. A terminator entry looks like this:<br><br>    TERM 19  15310 - 15327  -      F     99      -12.7 -4.0 |bidir<br>    (name)   (start - end)  (sense)(loc) (conf) (hp) (tail) (notes)<br><br>where "conf" is the overall confidence score, "hp" is the hairpin score, and "tail" is the tail score. "Conf" (which ranges from 0 to 100) is what you probably want to use to assess the quality of a terminator. Higher is better. The confidence, hp score, and tail scores are described in the paper cited above.  "Loc" gives type of region the terminator is in:<br><br>    "G" = in the interior of a gene (at least 50bp from an end),<br>    "F" = between two +strand genes,<br>    "R" = between two -strand genes,<br>    "T" = between the ends of a +strand gene and a -strand gene,<br>    "H" = between the starts of a +strand gene and a -strand gene,<br>    "N" = none of the above (for the start and end of the DNA)<br><br>Because of how overlapping genes are handled, these designations are not exclusive. "G", "F", or "R" can also be given in lowercase, indicating that the terminator is on the opposite strand as the region.  Unless the all-context option is given, only candidate terminators that appear to be in an appropriate genome context (e.g. T, F, R) are output.  Following the TERM line is the sequence of the hairpin and the 5` and 3` tails, always written 5` to 3`.' WHERE fileformat_name = 'TransTerm Raw Result';
UPDATE fileformat SET fileformat_help = 'This reposrt is similar to the standard BLAST output.  The report consists of three major sections: (1) the header, which contains information about the query sequence, the database searched. On the Web, there is also a graphical overview; (2) the one-line descriptions of each database sequence found to match the query sequence; these provide a quick overview for browsing; (3) the alignments for each database sequence matched (there may be more than one alignment for a database sequence it matches).' WHERE fileformat_name = 'RPSBLAST Raw Result';
UPDATE fileformat SET fileformat_help = 'The OligoPicker output file contains the following information:<br><br>   1. The sequence definitions from the input FASTA file.<br>   2. Total sequence lengths.<br>   3. The probe sequences.<br>   4. The probe Tm values in 1M NaCl.<br>   5. The probe positions in the DNA sequences.<br>   6. Probe Blast scores (no entry means the score is too low to be recorded).<br>   7. Cross-reactivity screening stringencies. For example, "16-32.5" means the threshold values are 16-mer for contiguous match filter and 32.5 for Blast filter.' WHERE fileformat_name = 'OligoPicker Raw Result';
UPDATE fileformat SET fileformat_help = 'YAML is a human friendly data serialization standard for all programming languages.' WHERE fileformat_name = 'YAML';
UPDATE fileformat SET fileformat_help = ' MAST outputs a file containing: the version of MAST and the date it was built, the reference to cite if you use MAST in your research, a description of the database and motifs used in the search, an explanation of the result, high-scoring sequences--sequences matching the group of motifs above a stated level of statistical significance,  motif diagrams showing the order and spacing of occurrences of the motifs in the high-scoring sequences and,  annotated sequences showing the positions and p-values of all motif occurrences in each of the high-scoring sequences.
' WHERE fileformat_name = 'Mast Raw Result';
UPDATE fileformat SET fileformat_help = 'The Celera Assembler native format.  FRG files consist of sequencer reads and relationships between the reads. Two types of relationships are defined: libraries and mates.' WHERE fileformat_name = 'FRG';
UPDATE fileformat SET fileformat_help = 'The ASM file is Celera Assemblers most critical output. The ASM file is complete. The ASM was designed to be the sole deliverable of the assembly pipeline.  The ASM file provides a precise description of the assembly as a hierarchical data structure. The ASM defines all elements of the generated assembly, including the scaffolds and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it. For every contig, the ASM file includes the sequence and quality scores of the consensus. The ASM file identifies the fate of every read and mate pair used in the assembly. It even identifies the fate of most reads and mate pairs that were not used. (An exception is the ignored reads that had no high-quality bases.)' WHERE fileformat_name = 'ASM';
UPDATE fileformat SET fileformat_help = 'This text file contains a human-readable summary report. The report lists over 100 statistical measures of the assembly. (Presently, some statistics derive from the input FRG file.) ' WHERE fileformat_name = 'QC';
UPDATE fileformat SET fileformat_help = 'A bank is a special directory of binary encoded files containing all information on an assembly. A bank is created by the AMOS assemblers directly, or by converting the results of others assemblers into AMOS format.' WHERE fileformat_name = 'Amos Bank';
UPDATE fileformat SET fileformat_help = 'An output produced by several assemblers.' WHERE fileformat_name = 'ACE';
UPDATE fileformat SET fileformat_help = 'The AGP file describes the positions of the contigs in the genome. It takes the standard NCBI format: <a href="http://www.ncbi.nlm.nih.gov/projects/genome/assembly/agp/AGP_Specification.shtml">NCBI AGP Specification</a>.' WHERE fileformat_name = 'AGP';
UPDATE fileformat SET fileformat_help = 'Statistics of the assembly, eg: number of reads and bases aligned, overlaps found, mean contig sizes, etc.' WHERE fileformat_name = 'Newbler Metric File';
UPDATE fileformat SET fileformat_help = 'The .mates file provides two types of information: library data, and mate-pair relationships between reads.' WHERE fileformat_name = 'Bambus Mates';
UPDATE fileformat SET fileformat_help = 'File format used to relate a read prefix to a library.  Each line in read file specifies <read prefix> <library name>' WHERE fileformat_name = 'Read File';
UPDATE fileformat SET fileformat_help = 'XML (Extensible Markup Language) is a set of rules for encoding documents electronically. It is defined in the XML 1.0 Specification produced by the W3C and several other related specifications; all are fee-free open standards.' WHERE fileformat_name = 'XML';
UPDATE fileformat SET fileformat_help = 'SFF is the native 454 format.  It is the file format generated by software on 454 sequencing platforms such as 454 FLX and 454 XLR.  You can read more about the format <a href="http://www.ncbi.nlm.nih.gov/Traces/trace.cgi?cmd=show&f=formats&m=doc&s=format#sff">here</a>.' WHERE fileformat_name = 'SFF';
