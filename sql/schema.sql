SET SESSION client_min_messages TO 'warning';

-- drop map tables
DROP TABLE componentinputmap;
DROP TABLE grouppermission;
DROP TABLE groupmembership;
DROP TABLE usergroupmembership;
DROP TABLE pipelineaccess;
DROP TABLE runaccess;
DROP TABLE runinput;
DROP TABLE fileaccess;

DROP TABLE contig;
DROP TABLE gene;
DROP TABLE mrna;
DROP TABLE cds;
DROP TABLE rrna;
DROP TABLE exref;
DROP TABLE exdb;
DROP TABLE mrna_exref;

DROP TABLE accountrequest;
DROP TABLE passwordchangerequest;

DROP TABLE filecollectioncontent;

DROP TABLE runbuilderinput;
DROP TABLE runbuilder;

DROP TABLE runcluster;

DROP TABLE runoutput;
DROP TABLE clusteroutput;

DROP TABLE pipelineinput;
DROP TABLE clusterinput;

DROP TABLE workflow;

DROP TABLE component;
DROP TABLE componenttemplate;
DROP TABLE cluster;

DROP TABLE pipelinebuilder;
DROP TABLE runcancelation;
DROP TABLE genomefeature;
DROP TABLE job;
DROP TABLE run;

DROP TABLE userpipeline;
DROP TABLE globalpipeline;
DROP TABLE pipeline;

DROP TABLE file;
DROP TABLE filecollection;
DROP TABLE filetype;

DROP TABLE fileresource;

DROP TABLE usergroupemailinvitation;
DROP TABLE usergroupinvitation;

-- drop data tables
DROP TABLE news;
DROP TABLE usergroup;
DROP TABLE account;
DROP TABLE accountgroup;
DROP TABLE party;

-- drop dictionary tables
DROP TABLE accountrequeststatus;
DROP TABLE ergatisformat;
DROP TABLE filecollectiontype;
DROP TABLE filecontent;
DROP TABLE fileformat;
DROP TABLE fileresourcepartition;
DROP TABLE inputdependency;
DROP TABLE newstype;
DROP TABLE partystatus;
DROP TABLE partypartition;
DROP TABLE pipelinepartition;
DROP TABLE pipelinestatus;
DROP TABLE runstatus;
DROP TABLE usecase;

-- drop enum tables
DROP TABLE outputvisibility;
DROP TABLE stylesheet;

-- create dictionary tables

CREATE TABLE accountrequeststatus (
  accountrequeststatus_name TEXT PRIMARY KEY
);

CREATE TABLE ergatisformat (
  ergatisformat_name TEXT PRIMARY KEY
);

CREATE TABLE filecollectiontype (
  filecollectiontype_id SERIAL PRIMARY KEY,
  filecollectiontype_name TEXT NOT NULL UNIQUE,
  filecollectiontype_description TEXT NOT NULL,
  filecollectiontype_isuniform BOOLEAN NOT NULL
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

CREATE TABLE fileresourcepartition (
  fileresourcepartition_id SERIAL PRIMARY KEY,
  fileresourcepartition_name TEXT NOT NULL UNIQUE,
  fileresourcepartition_class TEXT NOT NULL UNIQUE
);

CREATE TABLE inputdependency (
  inputdependency_id SERIAL PRIMARY KEY,
  inputdependency_name TEXT NOT NULL UNIQUE
);

-- light dictionary table
CREATE TABLE newstype (
  newstype_id SERIAL PRIMARY KEY,
  newstype_name TEXT UNIQUE
);

-- light dictionary table
CREATE TABLE outputvisibility (
  outputvisibility_name TEXT PRIMARY KEY
);


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
  usecase_stylesheet TEXT REFERENCES stylesheet(stylesheet_name) NOT NULL DEFAULT 'none',
  usecase_hasdocumentation BOOLEAN NOT NULL DEFAULT FALSE
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
  party_isprivate BOOLEAN NOT NULL,
  party_iswalkthroughdisabled BOOLEAN NOT NULL,
  party_iswalkthroughhidden BOOLEAN NOT NULL
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
  pipeline_workflowmask TEXT,
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
  pipelinebuilder_workflowmask TEXT,
  pipelinebuilder_parametermask TEXT,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  pipelinebuilder_startedon DATE NOT NULL
);


CREATE TABLE filetype (
  filetype_id SERIAL PRIMARY KEY,
  filetype_name TEXT NOT NULL UNIQUE,
  filetype_help TEXT NOT NULL,
  filecontent_id INTEGER REFERENCES filecontent(filecontent_id) NOT NULL
);

CREATE TABLE fileresource (
  fileresource_id SERIAL PRIMARY KEY,
  fileresourcepartition_id INTEGER REFERENCES fileresourcepartition(fileresourcepartition_id) NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  fileresource_createdat TIMESTAMP NOT NULL DEFAULT 'now',
  fileresource_username TEXT NOT NULL,
  fileresource_description TEXT NOT NULL,
  fileresource_ishidden BOOLEAN NOT NULL,
  fileresource_existsoutsidecollection BOOLEAN NOT NULL
);

CREATE TABLE file (
  fileresource_id INTEGER REFERENCES fileresource(fileresource_id) NOT NULL UNIQUE,
  file_name CHAR(43) NOT NULL,
  file_size INTEGER NOT NULL,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL
);

CREATE TABLE filecollection (
  fileresource_id INTEGER REFERENCES fileresource(fileresource_id) NOT NULL UNIQUE,
  filecollectiontype_id INTEGER REFERENCES filecollectiontype(filecollectiontype_id) NOT NULL
);


CREATE TABLE run (
  run_id SERIAL PRIMARY KEY,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  runstatus_id INTEGER REFERENCES runstatus(runstatus_id) NOT NULL,
  run_createdat TIMESTAMP NOT NULL,
  run_finishedat TIMESTAMP,
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL,
  run_name TEXT NOT NULL,
  run_description TEXT NOT NULL DEFAULT '',
  run_ergatiskey INTEGER NOT NULL UNIQUE,
  fileresource_id INTEGER REFERENCES filecollection(fileresource_id) NOT NULL
);


CREATE TABLE cluster (
  cluster_id SERIAL PRIMARY KEY,
  cluster_name TEXT NOT NULL UNIQUE,
  cluster_formpath TEXT NOT NULL,
  cluster_description TEXT NOT NULL,
  cluster_layoutxml TEXT NOT NULL
);

CREATE TABLE componenttemplate (
  componenttemplate_id SERIAL PRIMARY KEY,
  componenttemplate_name TEXT NOT NULL UNIQUE,
  componenttemplate_formpath TEXT
);

CREATE TABLE component (
  component_id SERIAL PRIMARY KEY,
  component_name TEXT NOT NULL,
  component_ergatisname TEXT NOT NULL UNIQUE,
  cluster_id INTEGER REFERENCES cluster(cluster_id) NOT NULL,
  componenttemplate_id INTEGER REFERENCES componenttemplate(componenttemplate_id) NOT NULL,
  component_isoptional BOOLEAN NOT NULL,
  component_ishidden BOOLEAN NOT NULL,
  component_index INTEGER NOT NULL,
  component_dependson INTEGER REFERENCES component(component_id),
  CONSTRAINT component_cluster_index_key UNIQUE (cluster_id, component_index)
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
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  inputdependency_id INTEGER REFERENCES inputdependency(inputdependency_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL,
  clusterinput_ergatisformat TEXT REFERENCES ergatisformat(ergatisformat_name) NOT NULL
);

CREATE TABLE clusteroutput (
  clusteroutput_id SERIAL PRIMARY KEY,
  component_id INTEGER REFERENCES component(component_id) NOT NULL,
  filetype_id INTEGER REFERENCES filetype(filetype_id) NOT NULL,
  fileformat_id INTEGER REFERENCES fileformat(fileformat_id) NOT NULL,
  clusteroutput_ergatisformat TEXT REFERENCES ergatisformat(ergatisformat_name) NOT NULL,
  outputvisibility_name TEXT REFERENCES outputvisibility(outputvisibility_name) NOT NULL,
  clusteroutput_fileloc TEXT NOT NULL
);

CREATE TABLE runoutput (
  runoutput_id SERIAL PRIMARY KEY,
  fileresource_id INTEGER REFERENCES fileresource(fileresource_id),
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
  workflow_coordinates TEXT NOT NULL,
  workflow_isrequired BOOLEAN NOT NULL
);

CREATE TABLE runbuilder (
  runbuilder_id SERIAL PRIMARY KEY,
  runbuilder_name TEXT NOT NULL,
  pipeline_id INTEGER REFERENCES pipeline(pipeline_id) NOT NULL,
  runbuilder_startedat TIMESTAMP NOT NULL,
  runbuilder_description TEXT NOT NULL DEFAULT '',
  runbuilder_ergatisdirectory TEXT NOT NULL UNIQUE,
  runbuilder_parametermask TEXT NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL
);

CREATE TABLE runbuilderinput (
  runbuilderinput_id SERIAL PRIMARY KEY,
  fileresource_id INTEGER REFERENCES fileresource(fileresource_id) NOT NULL,
  runbuilder_id INTEGER REFERENCES runbuilder(runbuilder_id) NOT NULL,
  pipelineinput_id INTEGER REFERENCES pipelineinput(pipelineinput_id) NOT NULL
);


CREATE TABLE filecollectioncontent (
  filecollectioncontent_id SERIAL PRIMARY KEY,
  fileresource_id INTEGER REFERENCES filecollection(fileresource_id) NOT NULL,
  filecollectioncontent_child INTEGER REFERENCES fileresource(fileresource_id) NOT NULL,
  filecollectioncontent_index INTEGER NOT NULL,
  CONSTRAINT filecollectioncontent_indexkey UNIQUE (fileresource_id, filecollectioncontent_index)
);

CREATE TABLE news (
  news_id SERIAL PRIMARY KEY,
  newstype_id INTEGER REFERENCES newstype(newstype_id) NOT NULL,
  news_title TEXT NOT NULL,
  news_body TEXT NOT NULL,
  party_id INTEGER REFERENCES account(party_id) NOT NULL,
  news_createdat TIMESTAMP NOT NULL,
  news_expireson DATE,
  news_isarchived BOOLEAN NOT NULL
);


-- create map tables
CREATE TABLE componentinputmap (
  component_id INTEGER REFERENCES component(component_id) NOT NULL,
  clusterinput_id INTEGER REFERENCES clusterinput(clusterinput_id) NOT NULL,
  CONSTRAINT componentinputmap_pk UNIQUE (component_id,clusterinput_id)
);

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

CREATE TABLE pipelineaccess (
 party_id INTEGER REFERENCES party(party_id) NOT NULL,
 pipeline_id INTEGER REFERENCES userpipeline(pipeline_id) NOT NULL
);

CREATE TABLE runaccess (
 party_id INTEGER REFERENCES party(party_id) NOT NULL,
 run_id INTEGER REFERENCES run(run_id) NOT NULL
);

CREATE TABLE runinput (
  fileresource_id INTEGER REFERENCES fileresource(fileresource_id) NOT NULL,
  run_id INTEGER REFERENCES run(run_id) NOT NULL
);

CREATE TABLE fileaccess (
 party_id INTEGER REFERENCES party(party_id) NOT NULL,
 fileresource_id INTEGER REFERENCES fileresource(fileresource_id) NOT NULL
);
