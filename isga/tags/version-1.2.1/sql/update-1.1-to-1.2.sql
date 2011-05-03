SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Fix Duplicate componentinput error
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM componentinputmap WHERE clusterinput_id = 
 (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'SFF_Preperation_Input');

DELETE FROM clusterinput WHERE clusterinput_name = 'SFF_Preperation_Input';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Site Configuration settings
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO datatype VALUES ( 'email' );

-- allow_sge_requests
INSERT INTO configurationvariable
 (configurationvariable_type, configurationvariable_datatype, configurationvariable_name, configurationvariable_form, configurationvariable_description) 
 VALUES ( 'SiteConfiguration', 'email', 'support_email',
          '---
NAME: support_email
TITLE: support_email
REQUIRED: 1
ERROR: ''email''
', 
	  'The email address provided as a support contact for the website.'
);

INSERT INTO siteconfiguration ( configurationvariable_id, siteconfiguration_value ) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'support_email'),
 'nobody@nowhere.org');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Fix permission error on ShowHideWalkthrough usecase
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE usecase SET usecase_requireslogin = TRUE WHERE usecase_name = '/submit/Account/ShowHideWalkthrough';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add use case for viewing run builder input errors
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) VALUES ('/RunBuilder/ViewInputError', 'Input Error', TRUE, '2columnright');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add use case for administrative list of run builders
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) VALUES ('/RunBuilder/AdminList', 'Administrator Run Builder list', TRUE, '2columnright');
INSERT INTO grouppermission ( accountgroup_id, usecase_id ) 
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators'), (SELECT usecase_id FROM usecase WHERE usecase_name = '/RunBuilder/AdminList') );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add use cases for uploading input files
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) VALUES ('/RunBuilder/UploadInput', 'Input Upload', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) VALUES ('/submit/RunBuilder/UploadInput', 'RunBuilder::UploadInput', TRUE, 'none');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Usecase for SffToFasta
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) VALUES ('/WorkBench/SffToFasta', 'Sff To Fasta', TRUE, '2columnright');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin) VALUES ('/submit/WorkBench/SffToFasta', 'WorkBench::SffToFasta', TRUE);
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin, usecase_stylesheet) VALUES ('/WorkBench/Results/SffToFasta', 'Results for SffToFasta', TRUE, '2columnright');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add New JobTypes
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO jobtype ( jobtype_name, jobtype_class ) VALUES ( 'SffToFasta', 'ISGA::Job::SffToFasta' );
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add asn2all to Output cluster of Prok. Annot. Pipeline
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE cluster SET cluster_layoutxml='   <commandSet type="parallel">
     <state>incomplete</state>
     ___parse_evidence.hmmpfam_pre___
     ___parse_evidence.ber_pre___
    </commandSet>
    ___p_func.default___
    ___pipeline_summary.default___
    <commandSet type="parallel">
     <state>incomplete</state>
      <commandSet type="serial">
       <state>incomplete</state>
       ___cgb_bsml2tbl.default___
       ___tbl2asn.default___
       ___asn2all.default___
      </commandSet>
      ___bsml2gff3.default___
      <commandSet type="serial">
       <state>incomplete</state>
      ___bsml2fasta.workbench___
      ___cgb_format.workbench_nuc___
      </commandSet>
      <commandSet type="serial">
       <state>incomplete</state>
       ___translate_sequence.workbench___
       ___join_multifasta.workbench___
       ___cgb_format.workbench_prot___
      </commandSet>
    </commandSet>'
WHERE cluster_name = 'Output';

INSERT INTO componenttemplate (componenttemplate_name) VALUES ('asn2all');
INSERT INTO component (component_name, component_ergatisname, cluster_id, componenttemplate_id, component_index) VALUES 
  ('', 'asn2all.default', (SELECT cluster_id FROM cluster WHERE cluster_name = 'Output'), 
  (SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'asn2all'), 15);

INSERT INTO filetype (filetype_name, filetype_help) VALUES ('CDS', 'Region of nucleotides that corresponds to the sequence of amino acids in the predicted protein.');
INSERT INTO filetype (filetype_name, filetype_help) VALUES ('Translated CDS', 'Translated region of nucleotides that corresponds to the sequence of the predicted protein.');

INSERT INTO clusteroutput (component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc) 
  VALUES ((SELECT component_id FROM component WHERE component_ergatisname = 'asn2all.default'), (SELECT filetype_id FROM filetype WHERE filetype_name = 'CDS'),
  (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'), 'File List', 'Pipeline', 'asn2all/___id____default/asn2all.fna.list');

INSERT INTO clusteroutput (component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES ((SELECT component_id FROM component WHERE component_ergatisname = 'asn2all.default'), (SELECT filetype_id FROM filetype WHERE filetype_name = 'Translated CDS'),
  (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'), 'File List', 'Pipeline', 'asn2all/___id____default/asn2all.fsa.list');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Remove old use cases
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/EditWorkflow';
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/ListMy';
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/Status';
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/ViewClusters';
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/ViewInputs';
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/ViewOutputs';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Update ASM description
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE fileformat SET fileformat_help = 'The ASM file is Celera Assembler\'s most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.';
