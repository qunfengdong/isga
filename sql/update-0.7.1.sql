--------------------------------------------------------------------
--------------------------------------------------------------------
-- add Gbrowse support
--------------------------------------------------------------------
--------------------------------------------------------------------
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Browser', TRUE, 'Genome Browser', '1column' );

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add right menu to run list
--------------------------------------------------------------------
--------------------------------------------------------------------
UPDATE usecase SET usecase_stylesheet = '2columnright' WHERE usecase_name = '/Run/ListMy';

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add GFF output
--------------------------------------------------------------------
--------------------------------------------------------------------

-- update layoutxml
UPDATE cluster SET cluster_layoutxml =
'  <commandSet type="parallel">
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
     </commandSet>
     ___bsml2gff3.default___
     <commandSet type="serial">
      <state>incomplete</state>
     ___bsml2fasta.workbench___
     ___formatdb.workbench_nuc___
     </commandSet>
     <commandSet type="serial">
      <state>incomplete</state>
      ___translate_sequence.workbench___
      ___join_multifasta.workbench___
      ___formatdb.workbench_prot___
     </commandSet>
   </commandSet>
'
WHERE cluster_name = 'Predict Gene Function';
 
-- add componenttemplate
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'bsml2gff3', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'formatdb', '' );

-- add component
INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'bsml2gff3.default', '', FALSE, FALSE, 7,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2gff3' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2gff3.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Pipeline Summary'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'GFF'),
    'File List', 'Pipeline', 'bsml2gff3/___id____default/bsml2gff3.gff3.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'bsml2fasta.workbench', '', FALSE, FALSE, 8,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2fasta' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'formatdb.workbench_nuc', '', FALSE, FALSE, 9,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'formatdb' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'translate_sequence.workbench', '', FALSE, FALSE, 10,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'translate_sequence' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'join_multifasta.workbench', '', FALSE, FALSE, 11,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'join_multifasta' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'formatdb.workbench_prot', '', FALSE, FALSE, 12,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'formatdb' ));

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Kashi's WorkBench code
--------------------------------------------------------------------
--------------------------------------------------------------------
-------- SGE job tables

-- light dictionary table
CREATE TABLE jobstatus (
  jobstatus_name TEXT PRIMARY KEY
);

CREATE TABLE jobtype (
  jobtype_id SERIAL PRIMARY KEY,
  jobtype_name TEXT NOT NULL UNIQUE
);

-- data tables
CREATE TABLE job (
  job_id SERIAL PRIMARY KEY,
  job_pid TEXT NOT NULL UNIQUE,
  jobtype_id INTEGER REFERENCES jobtype(jobtype_id) NOT NULL,
  job_status TEXT REFERENCES jobstatus(jobstatus_name) NOT NULL,
  job_createdat TIMESTAMP NOT NULL,
  job_finishedat TIMESTAMP,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  job_notifyuser BOOLEAN NOT NULL DEFAULT FALSE
);

-- dictionary
INSERT INTO jobstatus ( jobstatus_name ) VALUES ('Pending');
INSERT INTO jobstatus ( jobstatus_name ) VALUES ('Running');
INSERT INTO jobstatus ( jobstatus_name ) VALUES ('Finished');
INSERT INTO jobstatus ( jobstatus_name ) VALUES ('Error');
INSERT INTO jobstatus ( jobstatus_name ) VALUES ('Failed');

INSERT INTO jobtype (jobtype_name) VALUES ('Blast');
INSERT INTO jobtype (jobtype_name) VALUES ('MEME');
INSERT INTO jobtype (jobtype_name) VALUES ('MSA');


-------- Workbench
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Overview', FALSE, 'WorkBench Overview', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Blast', TRUE, 'Blast Interface', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/Blast', TRUE, 'View Blast Results', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/File/View', TRUE, 'Workbench view of file', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/MSA', TRUE, 'Workbench MSA', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/ConfirmMSA', TRUE, 'Workbench MSA Confirmation', '2columnright' );

-- AJAX & Forms
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/Blast', 'WorkBench::Blast', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/MSA', 'WorkBench::MSA', TRUE );


--------------------------------------------------------------------
--------------------------------------------------------------------
-- Manage Runs
--------------------------------------------------------------------
--------------------------------------------------------------------

INSERT INTO accountgroup ( accountgroup_name, accountgroup_description )
  VALUES ( 'Run Administrators', 'Staff members that can administer runs');

-- account group membership

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu' ) );

-- admin use cases

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/AdminList', True, 'Admin Run List', '1column' );

INSERT INTO grouppermission ( accountgroup_id, usecase_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT usecase_id FROM usecase WHERE usecase_name = '/Run/AdminList' ) );

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Track Deletion of Raw Data
--------------------------------------------------------------------
--------------------------------------------------------------------

CREATE TABLE rawdatastatus ( 
  rawdatastatus_name TEXT PRIMARY KEY
);

INSERT INTO rawdatastatus ( rawdatastatus_name ) VALUES ( 'Available' );
INSERT INTO rawdatastatus ( rawdatastatus_name ) VALUES ( 'Tagged for Deletion' );
INSERT INTO rawdatastatus ( rawdatastatus_name ) VALUES ( 'Deleted' );

ALTER TABLE run ADD COLUMN run_rawdatastatus TEXT REFERENCES rawdatastatus(rawdatastatus_name);
UPDATE run SET run_rawdatastatus = 'Available';
ALTER TABLE run ALTER COLUMN run_rawdatastatus SET NOT NULL;


--------------------------------------------------------------------
--------------------------------------------------------------------
-- Run Cancelations
--------------------------------------------------------------------
--------------------------------------------------------------------

CREATE TABLE runcancelation (
  runcancelation_id SERIAL PRIMARY KEY,
  run_id INTEGER REFERENCES run(run_id) NOT NULL UNIQUE,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  runcancelation_canceledat TIMESTAMP DEFAULT 'now' NOT NULL,
  runcancelation_comment TEXT NOT NULL
);       

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/Cancel', True, 'Cancel Run', '2columnright' );
INSERT INTO grouppermission ( accountgroup_id, usecase_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT usecase_id FROM usecase WHERE usecase_name = '/Run/Cancel' ) );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin ) VALUES ( '/submit/Run/Cancel', 'Run::Cancel', True );
INSERT INTO grouppermission ( accountgroup_id, usecase_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT usecase_id FROM usecase WHERE usecase_name = '/submit/Run/Cancel' ) );
