SET SESSION client_min_messages TO 'warning';

-- drop map tables
DROP TABLE grouppermission;
DROP TABLE groupmembership;
DROP TABLE usergroupmembership;
DROP TABLE workflowparentage;
DROP TABLE pipelineaccess;
DROP TABLE runaccess;
DROP TABLE runinput;
DROP TABLE fileaccess;

DROP TABLE accountrequest;
DROP TABLE passwordchangerequest;

DROP TABLE runbuilderinput;
DROP TABLE runbuilder;

DROP TABLE runcluster;

DROP TABLE runoutput;
DROP TABLE clusteroutput;

DROP TABLE pipelineinput;
DROP TABLE clusterinput;

DROP TABLE workflow;
DROP TABLE cluster;

DROP TABLE pipelinebuilder;

DROP TABLE run;

DROP TABLE userpipeline;
DROP TABLE globalpipeline;
DROP TABLE pipeline;

DROP TABLE file;
DROP TABLE filetype;


DROP TABLE usergroupemailinvitation;
DROP TABLE usergroupinvitation;

-- drop data tables
DROP TABLE usergroup;
DROP TABLE account;
DROP TABLE accountgroup;
DROP TABLE party;

-- drop dictionary tables
DROP TABLE accountrequeststatus;
DROP TABLE ergatisformat;
DROP TABLE filecontent;
DROP TABLE fileformat;
DROP TABLE inputdependency;
DROP TABLE partystatus;
DROP TABLE partypartition;
DROP TABLE pipelinepartition;
DROP TABLE pipelinestatus;
DROP TABLE runstatus;
DROP TABLE usecase;

-- drop enum tables
DROP TABLE stylesheet;

-- create dictionary tables

CREATE TABLE accountrequeststatus (
  accountrequeststatus_name TEXT PRIMARY KEY
);

CREATE TABLE ergatisformat (
  ergatisformat_name TEXT PRIMARY KEY
);

CREATE TABLE filecontent (
  filecontent_id SERIAL PRIMARY KEY,
  filecontent_name TEXT NOT NULL UNIQUE,
  filecontent_help TEXT NOT NULL
);

CREATE TABLE fileformat (
  fileformat_id SERIAL PRIMARY KEY,
  fileformat_name TEXT NOT NULL UNIQUE,
  fileformat_extension TEXT NOT NULL,
  fileformat_help TEXT NOT NULL
);

CREATE TABLE inputdependency (
  inputdependency_id SERIAL PRIMARY KEY,
  inputdependency_name TEXT NOT NULL UNIQUE
);

-- light dictionary table
CREATE TABLE stylesheet (
  stylesheet_name TEXT PRIMARY KEY
);

CREATE TABLE usecase (
  usecase_id SERIAL PRIMARY KEY,
  usecase_name TEXT NOT NULL UNIQUE,
  usecase_action TEXT ,
  usecase_requireslogin BOOLEAN NOT NULL,
  usecase_menu TEXT,
  usecase_title TEXT,
  usecase_stylesheet TEXT REFERENCES stylesheet(stylesheet_name) NOT NULL DEFAULT 'none'
);

CREATE TABLE partystatus (
  partystatus_id SERIAL PRIMARY KEY,
  partystatus_name TEXT NOT NULL UNIQUE
);

CREATE TABLE partypartition (
  partypartition_id SERIAL PRIMARY KEY,
  partypartition_name TEXT NOT NULL UNIQUE,
  partypartition_class TEXT NOT NULL UNIQUE
);

CREATE TABLE pipelinepartition (
  pipelinepartition_id SERIAL PRIMARY KEY,
  pipelinepartition_name TEXT NOT NULL UNIQUE,
  pipelinepartition_class TEXT NOT NULL UNIQUE
);

CREATE TABLE pipelinestatus (
  pipelinestatus_id SERIAL PRIMARY KEY,
  pipelinestatus_name TEXT NOT NULL UNIQUE
);

CREATE TABLE runstatus (
  runstatus_id SERIAL PRIMARY KEY,
  runstatus_name TEXT NOT NULL UNIQUE
);

-- create data tables
CREATE TABLE party (
  party_id SERIAL PRIMARY KEY,
  partypartition_id INTEGER REFERENCES partypartition(partypartition_id) NOT NULL,
  party_name TEXT NOT NULL,
  partystatus_id INTEGER REFERENCES partystatus(partystatus_id) NOT NULL,
  party_createdat TIMESTAMP NOT NULL DEFAULT 'now',
  party_institution VARCHAR(100),
  party_isprivate BOOLEAN NOT NULL
);
  
CREATE TABLE account (
  party_id INTEGER REFERENCES party(party_id) NOT NULL UNIQUE,
  account_email TEXT UNIQUE NOT NULL,
  account_password CHAR(32) NOT NULL
);

CREATE TABLE accountrequest (
  accountrequest_id SERIAL PRIMARY KEY,
  accountrequest_hash CHAR(22) NOT NULL,
  accountrequest_email TEXT UNIQUE NOT NULL,
  accountrequest_password CHAR(32) NOT NULL,
  accountrequest_name TEXT NOT NULL,
  accountrequeststatus_name TEXT REFERENCES accountrequeststatus(accountrequeststatus_name) NOT NULL,
  accountrequest_createdat TIMESTAMP NOT NULL,  			  
  accountrequest_institution VARCHAR(100),
  accountrequest_isprivate BOOLEAN NOT NULL
);

CREATE TABLE passwordchangerequest (
  passwordchangerequest_id SERIAL PRIMARY KEY,
  passwordchangerequest_hash CHAR(22) NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL UNIQUE,
  passwordchangerequest_createdat TIMESTAMP NOT NULL DEFAULT 'now'
);

CREATE TABLE usergroup (
  party_id INTEGER REFERENCES party(party_id) NOT NULL UNIQUE,
  account_id INTEGER REFERENCES account(party_id) NOT NULL
);

CREATE TABLE usergroupinvitation (
  usergroupinvitation_id SERIAL PRIMARY KEY,
  usergroup_id INTEGER REFERENCES usergroup(party_id) NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  usergroupinvitation_createdat TIMESTAMP NOT NULL DEFAULT 'now'
);

CREATE TABLE usergroupemailinvitation (
  usergroupemailinvitation_id SERIAL PRIMARY KEY,
  usergroup_id INTEGER REFERENCES usergroup(party_id) NOT NULL,
  usergroupemailinvitation_email VARCHAR(100) NOT NULL,
  usergroupemailinvitation_createdat TIMESTAMP NOT NULL DEFAULT 'now'
);

CREATE TABLE accountgroup (
  accountgroup_id SERIAL PRIMARY KEY,
  accountgroup_name TEXT NOT NULL UNIQUE,
  accountgroup_description TEXT NOT NULL
);

CREATE TABLE pipeline (
  pipeline_id SERIAL PRIMARY KEY,
  pipelinepartition_id INTEGER 
    REFERENCES pipelinepartition(pipelinepartition_id) NOT NULL,
  pipeline_name TEXT NOT NULL UNIQUE,
  pipeline_workflowmask TEXT NOT NULL,
  pipeline_description TEXT NOT NULL,
  pipelinestatus_id INTEGER REFERENCES pipelinestatus(pipelinestatus_id) NOT NULL
);

CREATE TABLE globalpipeline (
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL UNIQUE,
  globalpipeline_image TEXT NOT NULL,
  globalpipeline_layout TEXT NOT NULL
);
  
CREATE TABLE userpipeline (
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL UNIQUE,
  userpipeline_template INTEGER REFERENCES globalpipeline(pipeline_id) NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  userpipeline_createdat TIMESTAMP NOT NULL DEFAULT 'now',
  userpipeline_parametermask TEXT
);


CREATE TABLE pipelinebuilder (
  pipelinebuilder_id SERIAL PRIMARY KEY,
  pipelinebuilder_name TEXT NOT NULL,
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL,
  pipelinebuilder_description TEXT,
  pipelinebuilder_workflowmask TEXT NOT NULL,
  pipelinebuilder_parametermask TEXT,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  pipelinebuilder_startedon DATE NOT NULL
);

CREATE TABLE run (
  run_id SERIAL PRIMARY KEY,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  runstatus_id INTEGER REFERENCES runstatus(runstatus_id) NOT NULL,
  run_createdat TIMESTAMP NOT NULL,
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL,
  run_name TEXT NOT NULL,
  run_description TEXT NOT NULL DEFAULT '',
  run_ergatiskey TEXT NOT NULL
);

CREATE TABLE filetype (
  filetype_id SERIAL PRIMARY KEY,
  filetype_name TEXT NOT NULL UNIQUE,
  filetype_help TEXT NOT NULL,
  filecontent_id INTEGER REFERENCES filecontent(filecontent_id) NOT NULL
);

CREATE TABLE file (
  file_id SERIAL PRIMARY KEY,
  file_name CHAR(43) NOT NULL,
  file_size INTEGER NOT NULL,
  file_username TEXT,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  file_createdat TIMESTAMP NOT NULL DEFAULT 'now',
  file_description TEXT,
  filecontent_id INTEGER REFERENCES filecontent(filecontent_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL
);

CREATE TABLE cluster (
  cluster_id SERIAL PRIMARY KEY,
  cluster_name TEXT NOT NULL UNIQUE,
  cluster_formpath TEXT NOT NULL,
  cluster_layoutxml TEXT NOT NULL
);

CREATE TABLE runcluster (
  runcluster_id SERIAL PRIMARY KEY,
  run_id INTEGER REFERENCES run(run_id) NOT NULL,
  cluster_id INTEGER REFERENCES cluster(cluster_id) NOT NULL,
  runstatus_id INTEGER REFERENCES runstatus(runstatus_id) NOT NULL,
  runcluster_startedat TIMESTAMP,
  runcluster_finishedat TIMESTAMP,
  runcluster_finishedactions INTEGER,
  runcluster_totalactions INTEGER
);			  

CREATE TABLE clusterinput (
  clusterinput_id SERIAL PRIMARY KEY,
  clusterinput_name TEXT NOT NULL UNIQUE,
  clusterinput_defaultvalue TEXT NOT NULL,
  cluster_id INTEGER REFERENCES cluster(cluster_id) NOT NULL,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  inputdependency_id INTEGER REFERENCES inputdependency(inputdependency_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL,
  clusterinput_ergatisformat TEXT REFERENCES ergatisformat(ergatisformat_name) NOT NULL
);

CREATE TABLE clusteroutput (
  clusteroutput_id SERIAL PRIMARY KEY,
  cluster_id INTEGER REFERENCES cluster(cluster_id) NOT NULL,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL,
  clusteroutput_ergatisformat TEXT REFERENCES ergatisformat(ergatisformat_name) NOT NULL,
  clusteroutput_ispipelineoutput BOOLEAN NOT NULL,
  clusteroutput_fileloc TEXT NOT NULL
);

CREATE TABLE runoutput (
  runoutput_id SERIAL PRIMARY KEY,
  file_id INTEGER REFERENCES file(file_id),
  run_id INTEGER REFERENCES run(run_id) NOT NULL,
  clusteroutput_id INTEGER REFERENCES clusteroutput(clusteroutput_id) NOT NULL
);

CREATE TABLE pipelineinput (
  pipelineinput_id SERIAL PRIMARY KEY,
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL,
  inputdependency_id INTEGER REFERENCES inputdependency(inputdependency_id) NOT NULL,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL,
  clusterinput_id INTEGER REFERENCES clusterinput(clusterinput_id) NOT NULL,
  pipelineinput_ergatisformat TEXT REFERENCES ergatisformat(ergatisformat_name) NOT NULL
);

CREATE TABLE workflow (
  workflow_id SERIAL PRIMARY KEY,
  pipeline_id INTEGER REFERENCES globalpipeline(pipeline_id) NOT NULL,
  cluster_id INTEGER REFERENCES cluster(cluster_id) NOT NULL,
  workflow_coordinates TEXT NOT NULL
);

CREATE TABLE runbuilder (
  runbuilder_id SERIAL PRIMARY KEY,
  runbuilder_name TEXT NOT NULL,
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL,
  runbuilder_startedat TIMESTAMP NOT NULL,
  runbuilder_description TEXT NOT NULL DEFAULT '',
  party_id INTEGER REFERENCES account(party_id) NOT NULL
);

CREATE TABLE runbuilderinput (
  runbuilderinput_id SERIAL PRIMARY KEY,
  file_id INTEGER REFERENCES file(file_id) NOT NULL,
  runbuilder_id INTEGER REFERENCES runbuilder(runbuilder_id) NOT NULL,
  pipelineinput_id INTEGER REFERENCES pipelineinput(pipelineinput_id) NOT NULL
);


-- create map tables
CREATE TABLE groupmembership (
  accountgroup_id INTEGER REFERENCES accountgroup(accountgroup_id) NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL
);

CREATE TABLE grouppermission (
  accountgroup_id INTEGER REFERENCES accountgroup(accountgroup_id) NOT NULL,
  usecase_id INTEGER REFERENCES usecase(usecase_id) NOT NULL
);

CREATE TABLE usergroupmembership (
  usergroup_id INTEGER REFERENCES usergroup(party_id) NOT NULL,
  account_id INTEGER REFERENCES account(party_id) NOT NULL
);

CREATE TABLE workflowparentage (
  workflow_parent INTEGER REFERENCES workflow(workflow_id) NOT NULL,
  workflow_child INTEGER REFERENCES workflow(workflow_id) NOT NULL
);

CREATE TABLE pipelineaccess (
 party_id INTEGER REFERENCES party(party_id) NOT NULL,
 pipeline_id INTEGER REFERENCES userpipeline(pipeline_id) NOT NULL
);

CREATE TABLE runaccess (
 party_id INTEGER REFERENCES party(party_id) NOT NULL,
 run_id INTEGER REFERENCES run(run_id) NOT NULL
);

CREATE TABLE runinput (
  file_id INTEGER REFERENCES file(file_id) NOT NULL,
  run_id INTEGER REFERENCES run(run_id) NOT NULL
);

CREATE TABLE fileaccess (
 party_id INTEGER REFERENCES party(party_id) NOT NULL,
 file_id INTEGER REFERENCES file(file_id) NOT NULL
);