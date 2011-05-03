--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: 
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- Name: get_exref_id(text, text); Type: FUNCTION; Schema: public; Owner: chemmeri
--

CREATE FUNCTION get_exref_id(arg_exdb_name text, arg_exref_value text) RETURNS integer
    AS $$
DECLARE
	var_exref_id INTEGER;
BEGIN
	IF arg_exref_value IS NOT NULL THEN
		SELECT INTO var_exref_id exref.exref_id
		FROM exref, exdb
		WHERE exref.exdb_id = exdb.exdb_id 
			AND exdb_name = arg_exdb_name 
			AND exref_value = arg_exref_value;
	
		IF var_exref_id IS NULL THEN
			INSERT INTO exref (exref_value, exdb_id)
			VALUES (arg_exref_value, 
				(SELECT exdb_id 
				FROM exdb
				WHERE exdb_name = arg_exdb_name));
			var_exref_id := currval(pg_get_serial_sequence('exref', 'exref_id'));
		END IF;
	END IF;
	RETURN var_exref_id;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: get_sequence_id(text, character, integer); Type: FUNCTION; Schema: public; Owner: chemmeri
--

CREATE FUNCTION get_sequence_id(arg_sequence_residues text, arg_sequence_md5checksum character, arg_sequence_length integer) RETURNS integer
    AS $$
DECLARE 
	var_sequence_id INTEGER;
BEGIN
	SELECT INTO var_sequence_id sequence_id 
	FROM sequence
	WHERE sequence_md5checksum = arg_sequence_md5checksum 
		AND sequence_length = arg_sequence_length;

	IF var_sequence_id IS NULL THEN
		INSERT INTO sequence (sequence_residues, sequence_md5checksum, sequence_length) 
		VALUES (arg_sequence_residues, arg_sequence_md5checksum, arg_sequence_length);
		var_sequence_id := currval(pg_get_serial_sequence('sequence', 'sequence_id'));
	END IF;
	RETURN var_sequence_id;
END;
$$
    LANGUAGE plpgsql;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE account (
    party_id integer NOT NULL,
    account_email text NOT NULL,
    account_password character(32) NOT NULL,
    userclass_id integer NOT NULL
);


--
-- Name: accountgroup_accountgroup_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE accountgroup_accountgroup_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: accountgroup_accountgroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('accountgroup_accountgroup_id_seq', 4, true);


--
-- Name: accountgroup; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE accountgroup (
    accountgroup_id integer DEFAULT nextval('accountgroup_accountgroup_id_seq'::regclass) NOT NULL,
    accountgroup_name text NOT NULL,
    accountgroup_description text NOT NULL
);


--
-- Name: accountnotification; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE accountnotification (
    notification_id integer NOT NULL,
    party_id integer NOT NULL
);


--
-- Name: accountrequest_accountrequest_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE accountrequest_accountrequest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: accountrequest_accountrequest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('accountrequest_accountrequest_id_seq', 1, false);


--
-- Name: accountrequest; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE accountrequest (
    accountrequest_id integer DEFAULT nextval('accountrequest_accountrequest_id_seq'::regclass) NOT NULL,
    accountrequest_hash character(22) NOT NULL,
    accountrequest_email text NOT NULL,
    accountrequest_password character(32) NOT NULL,
    accountrequest_name text NOT NULL,
    accountrequeststatus_name text NOT NULL,
    accountrequest_createdat timestamp without time zone NOT NULL,
    accountrequest_institution character varying(100),
    accountrequest_isprivate boolean NOT NULL
);


--
-- Name: accountrequeststatus; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE accountrequeststatus (
    accountrequeststatus_name text NOT NULL
);


--
-- Name: cds; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE cds (
    genomefeature_id integer NOT NULL,
    cds_topcoghit text,
    cds_mrna integer NOT NULL
);


--
-- Name: cluster_cluster_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE cluster_cluster_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: cluster_cluster_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('cluster_cluster_id_seq', 14, true);


--
-- Name: cluster; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE "cluster" (
    cluster_id integer DEFAULT nextval('cluster_cluster_id_seq'::regclass) NOT NULL,
    cluster_name text NOT NULL,
    cluster_description text NOT NULL,
    cluster_layoutxml text NOT NULL,
    cluster_subclass text,
    clusterinput_id integer
);


--
-- Name: clusterinput_clusterinput_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE clusterinput_clusterinput_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clusterinput_clusterinput_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('clusterinput_clusterinput_id_seq', 19, true);


--
-- Name: clusterinput; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE clusterinput (
    clusterinput_id integer DEFAULT nextval('clusterinput_clusterinput_id_seq'::regclass) NOT NULL,
    clusterinput_name text NOT NULL,
    clusterinput_defaultvalue text NOT NULL,
    filetype_id integer NOT NULL,
    fileformat_id integer NOT NULL,
    clusterinput_ergatisformat text NOT NULL,
    clusterinput_dependency text NOT NULL,
    clusterinput_hasparameters boolean NOT NULL,
    clusterinput_isiterator boolean NOT NULL
);


--
-- Name: clusteroutput_clusteroutput_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE clusteroutput_clusteroutput_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clusteroutput_clusteroutput_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('clusteroutput_clusteroutput_id_seq', 66, true);


--
-- Name: clusteroutput; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE clusteroutput (
    clusteroutput_id integer DEFAULT nextval('clusteroutput_clusteroutput_id_seq'::regclass) NOT NULL,
    component_id integer NOT NULL,
    filetype_id integer NOT NULL,
    fileformat_id integer NOT NULL,
    clusteroutput_ergatisformat text NOT NULL,
    outputvisibility_name text NOT NULL,
    clusteroutput_fileloc text NOT NULL
);


--
-- Name: component_component_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE component_component_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: component_component_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('component_component_id_seq', 73, true);


--
-- Name: component; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE component (
    component_id integer DEFAULT nextval('component_component_id_seq'::regclass) NOT NULL,
    component_name text NOT NULL,
    component_ergatisname text NOT NULL,
    cluster_id integer NOT NULL,
    componenttemplate_id integer NOT NULL,
    component_index integer NOT NULL,
    component_dependson integer,
    component_copyparametermask integer
);


--
-- Name: componentinputmap; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE componentinputmap (
    component_id integer NOT NULL,
    clusterinput_id integer NOT NULL
);


--
-- Name: componenttemplate_componenttemplate_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE componenttemplate_componenttemplate_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: componenttemplate_componenttemplate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('componenttemplate_componenttemplate_id_seq', 46, true);


--
-- Name: componenttemplate; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE componenttemplate (
    componenttemplate_id integer DEFAULT nextval('componenttemplate_componenttemplate_id_seq'::regclass) NOT NULL,
    componenttemplate_name text NOT NULL,
    componenttemplate_formpath text
);


--
-- Name: configurationtype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE configurationtype (
    configurationtype_name text NOT NULL
);


--
-- Name: configurationvariable; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE configurationvariable (
    configurationvariable_id serial NOT NULL,
    configurationvariable_name text NOT NULL,
    configurationvariable_type text NOT NULL,
    configurationvariable_form text NOT NULL,
    configurationvariable_description text NOT NULL,
    configurationvariable_datatype text NOT NULL
);


--
-- Name: configurationvariable_configurationvariable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('configurationvariable', 'configurationvariable_id'), 7, true);


--
-- Name: contig; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE contig (
    genomefeature_id integer NOT NULL,
    sequence_id integer NOT NULL,
    run_id integer NOT NULL
);


--
-- Name: datatype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE datatype (
    datatype_name text NOT NULL
);


--
-- Name: emailnotification; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE emailnotification (
    notification_id integer NOT NULL,
    notification_email text NOT NULL
);


--
-- Name: ergatisformat; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE ergatisformat (
    ergatisformat_name text NOT NULL
);


--
-- Name: exdb_exdb_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE exdb_exdb_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: exdb_exdb_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('exdb_exdb_id_seq', 4, true);


--
-- Name: exdb; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE exdb (
    exdb_id integer DEFAULT nextval('exdb_exdb_id_seq'::regclass) NOT NULL,
    exdb_name text NOT NULL,
    exdb_baseuri text NOT NULL
);


--
-- Name: exref; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE exref (
    exref_id SERIAL PRIMARY KEY,
    exref_value text NOT NULL,
    exdb_id integer NOT NULL
);


--
-- Name: file; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE file (
    fileresource_id integer NOT NULL,
    file_name character(43) NOT NULL,
    file_size integer NOT NULL,
    filetype_id integer NOT NULL,
    fileformat_id integer NOT NULL
);


--
-- Name: fileaccess; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE fileaccess (
    party_id integer NOT NULL,
    fileresource_id integer NOT NULL
);


--
-- Name: filecollection; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE filecollection (
    fileresource_id integer NOT NULL,
    filecollectiontype_id integer NOT NULL
);


--
-- Name: filecollectioncontent_filecollectioncontent_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE filecollectioncontent_filecollectioncontent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: filecollectioncontent_filecollectioncontent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('filecollectioncontent_filecollectioncontent_id_seq', 1, false);


--
-- Name: filecollectioncontent; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE filecollectioncontent (
    filecollectioncontent_id integer DEFAULT nextval('filecollectioncontent_filecollectioncontent_id_seq'::regclass) NOT NULL,
    fileresource_id integer NOT NULL,
    filecollectioncontent_child integer NOT NULL,
    filecollectioncontent_index integer NOT NULL
);


--
-- Name: filecollectiontype_filecollectiontype_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE filecollectiontype_filecollectiontype_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: filecollectiontype_filecollectiontype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('filecollectiontype_filecollectiontype_id_seq', 3, true);


--
-- Name: filecollectiontype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE filecollectiontype (
    filecollectiontype_id integer DEFAULT nextval('filecollectiontype_filecollectiontype_id_seq'::regclass) NOT NULL,
    filecollectiontype_name text NOT NULL,
    filecollectiontype_description text NOT NULL,
    filecollectiontype_isuniform boolean NOT NULL
);


--
-- Name: filecontent_filecontent_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE filecontent_filecontent_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: filecontent_filecontent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('filecontent_filecontent_id_seq', 8, true);


--
-- Name: fileformat_fileformat_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE fileformat_fileformat_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: fileformat_fileformat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('fileformat_fileformat_id_seq', 37, true);


--
-- Name: fileformat; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE fileformat (
    fileformat_id integer DEFAULT nextval('fileformat_fileformat_id_seq'::regclass) NOT NULL,
    fileformat_name text NOT NULL,
    fileformat_extension text NOT NULL,
    fileformat_help text NOT NULL,
    fileformat_isbinary boolean NOT NULL
);


--
-- Name: fileresource_fileresource_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE fileresource_fileresource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: fileresource_fileresource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('fileresource_fileresource_id_seq', 1, false);


--
-- Name: fileresource; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE fileresource (
    fileresource_id integer DEFAULT nextval('fileresource_fileresource_id_seq'::regclass) NOT NULL,
    fileresourcepartition_id integer NOT NULL,
    party_id integer NOT NULL,
    fileresource_createdat timestamp without time zone DEFAULT '2009-11-16 16:17:14.193691'::timestamp without time zone NOT NULL,
    fileresource_username text NOT NULL,
    fileresource_description text NOT NULL,
    fileresource_ishidden boolean NOT NULL,
    fileresource_existsoutsidecollection boolean NOT NULL
);


--
-- Name: fileresourcepartition_fileresourcepartition_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE fileresourcepartition_fileresourcepartition_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: fileresourcepartition_fileresourcepartition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('fileresourcepartition_fileresourcepartition_id_seq', 2, true);


--
-- Name: fileresourcepartition; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE fileresourcepartition (
    fileresourcepartition_id integer DEFAULT nextval('fileresourcepartition_fileresourcepartition_id_seq'::regclass) NOT NULL,
    fileresourcepartition_name text NOT NULL,
    fileresourcepartition_class text NOT NULL
);


--
-- Name: filetype_filetype_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE filetype_filetype_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: filetype_filetype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('filetype_filetype_id_seq', 42, true);


--
-- Name: filetype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE filetype (
    filetype_id integer DEFAULT nextval('filetype_filetype_id_seq'::regclass) NOT NULL,
    filetype_name text NOT NULL,
    filetype_help text NOT NULL
);


--
-- Name: gene; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE gene (
    genomefeature_id integer NOT NULL,
    gene_locus text NOT NULL,
    gene_contig integer NOT NULL,
    gene_note text NOT NULL,
    gene_type text
);


--
-- Name: genetype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE genetype (
    genetype_name text NOT NULL
);


--
-- Name: genomefeature_genomefeature_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE genomefeature_genomefeature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: genomefeature_genomefeature_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('genomefeature_genomefeature_id_seq', 1, false);


--
-- Name: genomefeature; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE genomefeature (
    genomefeature_id integer DEFAULT nextval('genomefeature_genomefeature_id_seq'::regclass) NOT NULL,
    genomefeaturepartition_id integer NOT NULL,
    genomefeature_uniquename text NOT NULL,
    genomefeature_start integer NOT NULL,
    genomefeature_end integer NOT NULL,
    genomefeature_strand character(1)
);


--
-- Name: genomefeaturepartition_genomefeaturepartition_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE genomefeaturepartition_genomefeaturepartition_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: genomefeaturepartition_genomefeaturepartition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('genomefeaturepartition_genomefeaturepartition_id_seq', 6, true);


--
-- Name: genomefeaturepartition; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE genomefeaturepartition (
    genomefeaturepartition_id integer DEFAULT nextval('genomefeaturepartition_genomefeaturepartition_id_seq'::regclass) NOT NULL,
    genomefeaturepartition_name text NOT NULL,
    genomefeaturepartition_class text NOT NULL
);


--
-- Name: globalpipeline; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE globalpipeline (
    pipeline_id integer NOT NULL,
    globalpipeline_image text NOT NULL,
    globalpipeline_layout text NOT NULL,
    globalpipeline_subclass text
);


--
-- Name: groupmembership; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE groupmembership (
    accountgroup_id integer NOT NULL,
    party_id integer NOT NULL
);


--
-- Name: grouppermission; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE grouppermission (
    accountgroup_id integer NOT NULL,
    usecase_id integer NOT NULL
);


--
-- Name: inputdependency; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE inputdependency (
    inputdependency_name text NOT NULL
);


--
-- Name: inputdependency_inputdependency_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE inputdependency_inputdependency_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: inputdependency_inputdependency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('inputdependency_inputdependency_id_seq', 3, true);


--
-- Name: job_job_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE job_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: job_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('job_job_id_seq', 1, false);


--
-- Name: job; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE job (
    job_id integer DEFAULT nextval('job_job_id_seq'::regclass) NOT NULL,
    job_pid text NOT NULL,
    jobtype_id integer NOT NULL,
    job_status text NOT NULL,
    job_createdat timestamp without time zone NOT NULL,
    job_finishedat timestamp without time zone,
    party_id integer NOT NULL,
    job_notifyuser boolean DEFAULT false NOT NULL,
    fileresource_id integer
);


--
-- Name: jobnotification; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE jobnotification (
    notification_id integer NOT NULL,
    job_id integer NOT NULL,
    party_id integer NOT NULL
);


--
-- Name: jobstatus; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE jobstatus (
    jobstatus_name text NOT NULL
);


--
-- Name: jobtype_jobtype_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE jobtype_jobtype_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: jobtype_jobtype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('jobtype_jobtype_id_seq', 6, true);


--
-- Name: jobtype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE jobtype (
    jobtype_id integer DEFAULT nextval('jobtype_jobtype_id_seq'::regclass) NOT NULL,
    jobtype_name text NOT NULL,
    jobtype_class text NOT NULL
);


--
-- Name: mrna; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE mrna (
    genomefeature_id integer NOT NULL,
    mrna_genesymbol text,
    mrna_geneproductnamesource text NOT NULL,
    mrna_gene integer NOT NULL,
    mrna_genesymbolsource integer,
    mrna_tigrrole integer,
    mrna_ec integer
);


--
-- Name: mrnaexref; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE mrnaexref (
    genomefeature_id integer NOT NULL,
    exref_id integer NOT NULL
);


--
-- Name: news_news_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE news_news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: news_news_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('news_news_id_seq', 1, false);


--
-- Name: news; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE news (
    news_id integer DEFAULT nextval('news_news_id_seq'::regclass) NOT NULL,
    newstype_id integer NOT NULL,
    news_title text NOT NULL,
    news_body text NOT NULL,
    party_id integer NOT NULL,
    news_createdat timestamp without time zone NOT NULL,
    news_expireson date,
    news_isarchived boolean NOT NULL
);


--
-- Name: newstype_newstype_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE newstype_newstype_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: newstype_newstype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('newstype_newstype_id_seq', 3, true);


--
-- Name: newstype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE newstype (
    newstype_id integer DEFAULT nextval('newstype_newstype_id_seq'::regclass) NOT NULL,
    newstype_name text
);


--
-- Name: notification_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE notification_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: notification_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('notification_notification_id_seq', 1, false);


--
-- Name: notification; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE notification (
    notification_id integer DEFAULT nextval('notification_notification_id_seq'::regclass) NOT NULL,
    notificationpartition_id integer NOT NULL,
    notificationtype_id integer NOT NULL,
    notification_var1 text,
    notification_var2 text,
    notification_var3 text
);


--
-- Name: notificationpartition_notificationpartition_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE notificationpartition_notificationpartition_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: notificationpartition_notificationpartition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('notificationpartition_notificationpartition_id_seq', 4, true);


--
-- Name: notificationpartition; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE notificationpartition (
    notificationpartition_id integer DEFAULT nextval('notificationpartition_notificationpartition_id_seq'::regclass) NOT NULL,
    notificationpartition_name text NOT NULL,
    notificationpartition_class text NOT NULL
);


--
-- Name: notificationtype_notificationtype_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE notificationtype_notificationtype_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: notificationtype_notificationtype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('notificationtype_notificationtype_id_seq', 4, true);


--
-- Name: notificationtype; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE notificationtype (
    notificationtype_id integer DEFAULT nextval('notificationtype_notificationtype_id_seq'::regclass) NOT NULL,
    notificationtype_name text NOT NULL,
    notificationpartition_id integer NOT NULL,
    notificationtype_subject text NOT NULL,
    notificationtype_template text NOT NULL
);


--
-- Name: outputvisibility; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE outputvisibility (
    outputvisibility_name text NOT NULL
);


--
-- Name: party_party_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE party_party_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: party_party_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('party_party_id_seq', 1, false);


--
-- Name: party; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE party (
    party_id integer DEFAULT nextval('party_party_id_seq'::regclass) NOT NULL,
    partypartition_id integer NOT NULL,
    party_name text NOT NULL,
    partystatus_id integer NOT NULL,
    party_createdat timestamp without time zone DEFAULT now() NOT NULL,
    party_institution character varying(100),
    party_isprivate boolean NOT NULL,
    party_iswalkthroughdisabled boolean NOT NULL,
    party_iswalkthroughhidden boolean NOT NULL
);


--
-- Name: partypartition_partypartition_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE partypartition_partypartition_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: partypartition_partypartition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('partypartition_partypartition_id_seq', 2, true);


--
-- Name: partypartition; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE partypartition (
    partypartition_id integer DEFAULT nextval('partypartition_partypartition_id_seq'::regclass) NOT NULL,
    partypartition_name text NOT NULL,
    partypartition_class text NOT NULL
);


--
-- Name: partystatus_partystatus_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE partystatus_partystatus_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: partystatus_partystatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('partystatus_partystatus_id_seq', 4, true);


--
-- Name: partystatus; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE partystatus (
    partystatus_id integer DEFAULT nextval('partystatus_partystatus_id_seq'::regclass) NOT NULL,
    partystatus_name text NOT NULL
);


--
-- Name: passwordchangerequest_passwordchangerequest_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE passwordchangerequest_passwordchangerequest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: passwordchangerequest_passwordchangerequest_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('passwordchangerequest_passwordchangerequest_id_seq', 1, false);


--
-- Name: passwordchangerequest; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE passwordchangerequest (
    passwordchangerequest_id integer DEFAULT nextval('passwordchangerequest_passwordchangerequest_id_seq'::regclass) NOT NULL,
    passwordchangerequest_hash character(22) NOT NULL,
    party_id integer NOT NULL,
    passwordchangerequest_createdat timestamp without time zone DEFAULT '2009-11-16 16:17:14.114314'::timestamp without time zone NOT NULL
);


--
-- Name: pipeline_pipeline_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE pipeline_pipeline_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pipeline_pipeline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('pipeline_pipeline_id_seq', 2, true);


--
-- Name: pipeline; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE pipeline (
    pipeline_id integer DEFAULT nextval('pipeline_pipeline_id_seq'::regclass) NOT NULL,
    pipelinepartition_id integer NOT NULL,
    pipeline_name text NOT NULL,
    pipeline_workflowmask text,
    pipeline_description text NOT NULL,
    pipelinestatus_id integer NOT NULL
);


--
-- Name: pipelineaccess; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE pipelineaccess (
    party_id integer NOT NULL,
    pipeline_id integer NOT NULL
);


--
-- Name: pipelinebuilder_pipelinebuilder_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE pipelinebuilder_pipelinebuilder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pipelinebuilder_pipelinebuilder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('pipelinebuilder_pipelinebuilder_id_seq', 1, false);


--
-- Name: pipelinebuilder; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE pipelinebuilder (
    pipelinebuilder_id integer DEFAULT nextval('pipelinebuilder_pipelinebuilder_id_seq'::regclass) NOT NULL,
    pipelinebuilder_name text NOT NULL,
    pipeline_id integer NOT NULL,
    pipelinebuilder_description text,
    pipelinebuilder_workflowmask text,
    pipelinebuilder_parametermask text,
    party_id integer NOT NULL,
    pipelinebuilder_startedon date NOT NULL
);


--
-- Name: pipelineconfiguration; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE pipelineconfiguration (
    pipelineconfiguration_id serial NOT NULL,
    configurationvariable_id integer NOT NULL,
    pipeline_id integer NOT NULL,
    userclass_id integer,
    pipelineconfiguration_type text DEFAULT 'PipelineConfiguration'::text NOT NULL,
    pipelineconfiguration_value text NOT NULL
);


--
-- Name: pipelineconfiguration_pipelineconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('pipelineconfiguration', 'pipelineconfiguration_id'), 2, true);


--
-- Name: pipelineinput_pipelineinput_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE pipelineinput_pipelineinput_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pipelineinput_pipelineinput_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('pipelineinput_pipelineinput_id_seq', 2, true);


--
-- Name: pipelineinput; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE pipelineinput (
    pipelineinput_id integer DEFAULT nextval('pipelineinput_pipelineinput_id_seq'::regclass) NOT NULL,
    pipeline_id integer NOT NULL,
    clusterinput_id integer NOT NULL
);


--
-- Name: pipelinepartition_pipelinepartition_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE pipelinepartition_pipelinepartition_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pipelinepartition_pipelinepartition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('pipelinepartition_pipelinepartition_id_seq', 2, true);


--
-- Name: pipelinepartition; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE pipelinepartition (
    pipelinepartition_id integer DEFAULT nextval('pipelinepartition_pipelinepartition_id_seq'::regclass) NOT NULL,
    pipelinepartition_name text NOT NULL,
    pipelinepartition_class text NOT NULL
);


--
-- Name: pipelinestatus_pipelinestatus_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE pipelinestatus_pipelinestatus_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: pipelinestatus_pipelinestatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('pipelinestatus_pipelinestatus_id_seq', 3, true);


--
-- Name: pipelinestatus; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE pipelinestatus (
    pipelinestatus_id integer DEFAULT nextval('pipelinestatus_pipelinestatus_id_seq'::regclass) NOT NULL,
    pipelinestatus_name text NOT NULL
);


--
-- Name: rawdatastatus; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE rawdatastatus (
    rawdatastatus_name text NOT NULL
);


--
-- Name: requeststatus; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE requeststatus (
    requeststatus_name text NOT NULL
);


--
-- Name: rrna; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE rrna (
    genomefeature_id integer NOT NULL,
    rrna_score numeric(8,2) NOT NULL,
    rrna_gene integer NOT NULL
);


--
-- Name: run_run_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE run_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: run_run_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('run_run_id_seq', 1, false);


--
-- Name: run; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE run (
    run_id integer DEFAULT nextval('run_run_id_seq'::regclass) NOT NULL,
    party_id integer NOT NULL,
    runstatus_id integer NOT NULL,
    run_createdat timestamp without time zone NOT NULL,
    run_finishedat timestamp without time zone,
    pipeline_id integer NOT NULL,
    run_name text NOT NULL,
    run_description text DEFAULT ''::text NOT NULL,
    run_ergatiskey integer NOT NULL,
    fileresource_id integer NOT NULL,
    run_rawdatastatus text NOT NULL,
    run_ishidden boolean DEFAULT false NOT NULL
);


--
-- Name: runaccess; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runaccess (
    party_id integer NOT NULL,
    run_id integer NOT NULL
);


--
-- Name: runbuilder_runbuilder_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE runbuilder_runbuilder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: runbuilder_runbuilder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('runbuilder_runbuilder_id_seq', 1, false);


--
-- Name: runbuilder; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runbuilder (
    runbuilder_id integer DEFAULT nextval('runbuilder_runbuilder_id_seq'::regclass) NOT NULL,
    runbuilder_name text NOT NULL,
    pipeline_id integer NOT NULL,
    runbuilder_startedat timestamp without time zone NOT NULL,
    runbuilder_description text DEFAULT ''::text NOT NULL,
    runbuilder_ergatisdirectory text NOT NULL,
    runbuilder_parametermask text NOT NULL,
    party_id integer NOT NULL
);


--
-- Name: runbuilderinput_runbuilderinput_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE runbuilderinput_runbuilderinput_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: runbuilderinput_runbuilderinput_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('runbuilderinput_runbuilderinput_id_seq', 1, false);


--
-- Name: runbuilderinput; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runbuilderinput (
    runbuilderinput_id integer DEFAULT nextval('runbuilderinput_runbuilderinput_id_seq'::regclass) NOT NULL,
    fileresource_id integer NOT NULL,
    runbuilder_id integer NOT NULL,
    pipelineinput_id integer NOT NULL,
    runbuilderinput_parametermask text
);


--
-- Name: runcancelation_runcancelation_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE runcancelation_runcancelation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: runcancelation_runcancelation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('runcancelation_runcancelation_id_seq', 1, false);


--
-- Name: runcancelation; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runcancelation (
    runcancelation_id integer DEFAULT nextval('runcancelation_runcancelation_id_seq'::regclass) NOT NULL,
    run_id integer NOT NULL,
    party_id integer NOT NULL,
    runcancelation_canceledat timestamp without time zone DEFAULT '2009-11-16 16:17:14.97743'::timestamp without time zone NOT NULL,
    runcancelation_comment text NOT NULL
);


--
-- Name: runcluster_runcluster_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE runcluster_runcluster_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: runcluster_runcluster_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('runcluster_runcluster_id_seq', 1, false);


--
-- Name: runcluster; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runcluster (
    runcluster_id integer DEFAULT nextval('runcluster_runcluster_id_seq'::regclass) NOT NULL,
    run_id integer NOT NULL,
    cluster_id integer NOT NULL,
    runstatus_id integer NOT NULL,
    runcluster_startedat timestamp without time zone,
    runcluster_finishedat timestamp without time zone,
    runcluster_finishedactions integer,
    runcluster_totalactions integer,
    runcluster_iterations integer
);


--
-- Name: runinput; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runinput (
    fileresource_id integer NOT NULL,
    run_id integer NOT NULL,
    runinput_id serial NOT NULL,
    pipelineinput_id integer NOT NULL,
    runinput_parametermask text
);


--
-- Name: runinput_runinput_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('runinput', 'runinput_id'), 1, false);


--
-- Name: runnotification; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runnotification (
    notification_id integer NOT NULL,
    run_id integer NOT NULL,
    party_id integer NOT NULL
);


--
-- Name: runoutput_runoutput_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE runoutput_runoutput_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: runoutput_runoutput_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('runoutput_runoutput_id_seq', 1, false);


--
-- Name: runoutput; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runoutput (
    runoutput_id integer DEFAULT nextval('runoutput_runoutput_id_seq'::regclass) NOT NULL,
    fileresource_id integer,
    run_id integer NOT NULL,
    clusteroutput_id integer NOT NULL
);


--
-- Name: runstatus_runstatus_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE runstatus_runstatus_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: runstatus_runstatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('runstatus_runstatus_id_seq', 9, true);


--
-- Name: runstatus; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE runstatus (
    runstatus_id integer DEFAULT nextval('runstatus_runstatus_id_seq'::regclass) NOT NULL,
    runstatus_name text NOT NULL
);


CREATE TABLE "sequence" (
    sequence_id SERIAL PRIMARY KEY,
    sequence_residues text NOT NULL,
    sequence_md5checksum character(32) NOT NULL,
    sequence_length integer NOT NULL
);

--
-- Name: siteconfiguration; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE siteconfiguration (
    siteconfiguration_id serial NOT NULL,
    configurationvariable_id integer NOT NULL,
    siteconfiguration_type text DEFAULT 'SiteConfiguration'::text NOT NULL,
    siteconfiguration_value text NOT NULL,
    CONSTRAINT siteconfiguration_siteconfiguration_type_check CHECK ((siteconfiguration_type = 'SiteConfiguration'::text))
);


--
-- Name: siteconfiguration_siteconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('siteconfiguration', 'siteconfiguration_id'), 3, true);


--
-- Name: stylesheet; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE stylesheet (
    stylesheet_name text NOT NULL
);


--
-- Name: toolconfiguration; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE toolconfiguration (
    toolconfiguration_id serial NOT NULL,
    configurationvariable_id integer NOT NULL,
    jobtype_id integer NOT NULL,
    userclass_id integer,
    toolconfiguration_type text DEFAULT 'ToolConfiguration'::text NOT NULL,
    toolconfiguration_value text NOT NULL
);


--
-- Name: toolconfiguration_toolconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('toolconfiguration', 'toolconfiguration_id'), 3, true);


--
-- Name: trna; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE trna (
    genomefeature_id integer NOT NULL,
    trna_score numeric(8,2) NOT NULL,
    trna_trnaanticodon character(3) NOT NULL,
    trna_gene integer NOT NULL
);


--
-- Name: usecase_usecase_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE usecase_usecase_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: usecase_usecase_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('usecase_usecase_id_seq', 219, true);


--
-- Name: usecase; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE usecase (
    usecase_id integer DEFAULT nextval('usecase_usecase_id_seq'::regclass) NOT NULL,
    usecase_name text NOT NULL,
    usecase_action text,
    usecase_requireslogin boolean NOT NULL,
    usecase_menu text,
    usecase_title text,
    usecase_stylesheet text DEFAULT 'none'::text NOT NULL,
    usecase_hasdocumentation boolean DEFAULT false NOT NULL
);


--
-- Name: userclass; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE userclass (
    userclass_id serial NOT NULL,
    userclass_name text NOT NULL,
    userclass_description text NOT NULL
);


--
-- Name: userclass_userclass_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('userclass', 'userclass_id'), 1, true);


--
-- Name: userclassconfiguration; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE userclassconfiguration (
    userclassconfiguration_id serial NOT NULL,
    configurationvariable_id integer NOT NULL,
    userclass_id integer NOT NULL,
    userclassconfiguration_type text DEFAULT 'UserClassConfiguration'::text NOT NULL,
    userclassconfiguration_value text NOT NULL
);


--
-- Name: userclassconfiguration_userclassconfiguration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('userclassconfiguration', 'userclassconfiguration_id'), 2, true);


--
-- Name: usergroup; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE usergroup (
    party_id integer NOT NULL,
    account_id integer NOT NULL
);


--
-- Name: usergroupemailinvitation_usergroupemailinvitation_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE usergroupemailinvitation_usergroupemailinvitation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: usergroupemailinvitation_usergroupemailinvitation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('usergroupemailinvitation_usergroupemailinvitation_id_seq', 1, false);


--
-- Name: usergroupemailinvitation; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE usergroupemailinvitation (
    usergroupemailinvitation_id integer DEFAULT nextval('usergroupemailinvitation_usergroupemailinvitation_id_seq'::regclass) NOT NULL,
    usergroup_id integer NOT NULL,
    usergroupemailinvitation_email character varying(100) NOT NULL,
    usergroupemailinvitation_createdat timestamp without time zone DEFAULT '2009-11-16 16:17:14.1352'::timestamp without time zone NOT NULL
);


--
-- Name: usergroupinvitation_usergroupinvitation_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE usergroupinvitation_usergroupinvitation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: usergroupinvitation_usergroupinvitation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('usergroupinvitation_usergroupinvitation_id_seq', 1, false);


--
-- Name: usergroupinvitation; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE usergroupinvitation (
    usergroupinvitation_id integer DEFAULT nextval('usergroupinvitation_usergroupinvitation_id_seq'::regclass) NOT NULL,
    usergroup_id integer NOT NULL,
    party_id integer NOT NULL,
    usergroupinvitation_createdat timestamp without time zone DEFAULT '2009-11-16 16:17:14.129604'::timestamp without time zone NOT NULL
);


--
-- Name: usergroupmembership; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE usergroupmembership (
    usergroup_id integer NOT NULL,
    account_id integer NOT NULL
);


--
-- Name: userpipeline; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE userpipeline (
    pipeline_id integer NOT NULL,
    userpipeline_template integer NOT NULL,
    party_id integer NOT NULL,
    userpipeline_createdat timestamp without time zone DEFAULT '2009-11-16 16:17:14.165639'::timestamp without time zone NOT NULL,
    userpipeline_parametermask text
);


--
-- Name: variable_variable_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE variable_variable_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: variable_variable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('variable_variable_id_seq', 3, true);


--
-- Name: workflow_workflow_id_seq; Type: SEQUENCE; Schema: public; Owner: chemmeri
--

CREATE SEQUENCE workflow_workflow_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: workflow_workflow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chemmeri
--

SELECT pg_catalog.setval('workflow_workflow_id_seq', 13, true);


--
-- Name: workflow; Type: TABLE; Schema: public; Owner: chemmeri; Tablespace: 
--

CREATE TABLE workflow (
    workflow_id integer DEFAULT nextval('workflow_workflow_id_seq'::regclass) NOT NULL,
    pipeline_id integer NOT NULL,
    cluster_id integer NOT NULL,
    workflow_coordinates text,
    workflow_isrequired boolean NOT NULL,
    workflow_altcluster_id integer
);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY account (party_id, account_email, account_password, userclass_id) FROM stdin;
\.


--
-- Data for Name: accountgroup; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY accountgroup (accountgroup_id, accountgroup_name, accountgroup_description) FROM stdin;
1	News Administrators	Staff members that can post and edit news
2	Run Administrators	Staff members that can administer runs
3	Account Administrators	Administrator of ISGA Accounts
4	Policy Administrators	Administrator of Site Policies
\.


--
-- Data for Name: accountnotification; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY accountnotification (notification_id, party_id) FROM stdin;
\.


--
-- Data for Name: accountrequest; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY accountrequest (accountrequest_id, accountrequest_hash, accountrequest_email, accountrequest_password, accountrequest_name, accountrequeststatus_name, accountrequest_createdat, accountrequest_institution, accountrequest_isprivate) FROM stdin;
\.


--
-- Data for Name: accountrequeststatus; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY accountrequeststatus (accountrequeststatus_name) FROM stdin;
Open
Created
Expired
\.


--
-- Data for Name: cds; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY cds (genomefeature_id, cds_topcoghit, cds_mrna) FROM stdin;
\.


--
-- Data for Name: configurationtype; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY configurationtype (configurationtype_name) FROM stdin;
SiteConfiguration
PipelineConfiguration
ToolConfiguration
UserClassConfiguration
\.


--
-- Data for Name: configurationvariable; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY configurationvariable (configurationvariable_id, configurationvariable_name, configurationvariable_type, configurationvariable_form, configurationvariable_description, configurationvariable_datatype) FROM stdin;
1	allow_sge_requests	SiteConfiguration	---\ntempl: select\nNAME: allow_sge_requests\nTITLE: allow_sge_requests\nREQUIRED: 1\nOPTION: [ TRUE, FALSE ]\nERROR: [ ['Number::matches', 0, 1] ]\nOPT_VAL: [ 1,0]\n	Determines if users can submit new pipelines and tool box jobs requiring Sun Grid Engine.	boolean
2	default_user_class	SiteConfiguration	---\nNAME: default_user_class\nREQUIRED: 1\nERROR: [ ['Object::existsByName', 'ISGA::UserClass'] ]\n	Determines what user class accounts will have when first requested.	string
3	pipeline_is_installed	PipelineConfiguration	---\ntempl: select\nNAME: pipeline_is_installed\nTITLE: pipeline_is_installed\nREQUIRED: 1\nOPTION: [ TRUE, FALSE ]\nERROR: [ ['Number::matches', 0, 1] ]\nOPT_VAL: [1,0]\n	Determines if this pipeline is installed as part of ISGA and available for use.	boolean
4	raw_data_retention	UserClassConfiguration	---\nNAME: raw_data_retention\nTITLE: raw_data_retention\nREQUIRED: 1\nERROR: [ 'digitonly', 'Number::isPositive' ]\n	The number of days that pipeline raw output will be retained for this user class before automated cleanup scripts are able to delete it.	boolean
5	pipeline_quota	UserClassConfiguration	---\nNAME: pipeline_quota\nTITLE: pipeline_quota\nREQUIRED: 1\nERROR: [ 'digitonly', 'Number::isPositive' ]\n	The maximum number of running pipelines that a user of this user class may have at one time	boolean
6	tool_is_installed	ToolConfiguration	---\ntempl: select\nNAME: tool_is_installed\nTITLE: tool_is_installed\nREQUIRED: 1\nOPTION: [ TRUE, FALSE ]\nERROR: [ ['Number::matches', 0, 1] ]\nOPT_VAL: [1,0]\n	Determines if this tool is installed as part of ISGA and available for use.	boolean
7	support_email	SiteConfiguration	---\nNAME: support_email\nTITLE: support_email\nREQUIRED: 1\nERROR: 'email'\n	The email address provided as a support contact for the website.	email
\.


--
-- Data for Name: datatype; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY datatype (datatype_name) FROM stdin;
boolean
string
url
path
integer
number
date
timestamp
duration
IndexedObject
email
\.


--
-- Data for Name: emailnotification; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY emailnotification (notification_id, notification_email) FROM stdin;
\.


--
-- Data for Name: ergatisformat; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY ergatisformat (ergatisformat_name) FROM stdin;
File
File List
Directory
\.


--
-- Data for Name: exdb; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY exdb (exdb_id, exdb_name, exdb_baseuri) FROM stdin;
1	gene_symbol_source	http://cmr.jcvi.org/cgi-bin/CMR/HmmReport.cgi?hmm_acc=
2	TIGR_role	http://cmr.jcvi.org/cgi-bin/CMR/RoleNotes.cgi?role_id=
3	EC	http://www.genome.jp/dbget-bin/www_bget?ec:
4	GO	http://amigo.geneontology.org/cgi-bin/amigo/term-details.cgi?term=
\.


--
-- Data for Name: file; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY file (fileresource_id, file_name, file_size, filetype_id, fileformat_id) FROM stdin;
\.


--
-- Data for Name: fileaccess; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY fileaccess (party_id, fileresource_id) FROM stdin;
\.


--
-- Data for Name: filecollection; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY filecollection (fileresource_id, filecollectiontype_id) FROM stdin;
\.


--
-- Data for Name: filecollectioncontent; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY filecollectioncontent (filecollectioncontent_id, fileresource_id, filecollectioncontent_child, filecollectioncontent_index) FROM stdin;
\.


--
-- Data for Name: filecollectiontype; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY filecollectiontype (filecollectiontype_id, filecollectiontype_name, filecollectiontype_description, filecollectiontype_isuniform) FROM stdin;
1	File List	List of files, all of the same type that should be processed together.	t
2	Run Results	Results for a pipeline run.	f
3	Job Files	Input, config, and output of a job	f
\.


COPY fileformat (fileformat_id, fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary) FROM stdin;
1	FASTA	fsa	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
6	BLAST Raw Results	xxx	The report consists of three major sections: (1) the header, which contains information about the query sequence, the database searched. On the Web, there is also a graphical overview; (2) the one-line descriptions of each database sequence found to match the query sequence; these provide a quick overview for browsing; (3) the alignments for each database sequence matched (there may be more than one alignment for a database sequence it matches).  http://www.ncbi.nlm.nih.gov/books/bv.fcgi?rid=handbook.section.615	f
25	YAML	yaml	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
28	FRG	frg	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
29	ASM	asm	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
30	QC	qc	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
31	Amos Bank	xxx	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
32	ACE	ace	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
33	AGP	agp	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
34	Newbler Metric File	xxx	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
35	Bambus Mates	xxx	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
36	Read File	xxx	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
37	XML	xml	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	f
27	SFF	sff	The ASM file is Celera Assembler's most critical output; designed to be the sole deliverable of the assembly pipeline. It provides a precise description of the assembly as a hierarchical data structure. All elements of the generated assembly are defined, including scaffold and contigs. For every contig, the ASM file includes the multiple sequence alignment that produced it, the sequence and quality scores of the consensus.	t
\.


--
-- Data for Name: fileresource; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY fileresource (fileresource_id, fileresourcepartition_id, party_id, fileresource_createdat, fileresource_username, fileresource_description, fileresource_ishidden, fileresource_existsoutsidecollection) FROM stdin;
\.


--
-- Data for Name: fileresourcepartition; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY fileresourcepartition (fileresourcepartition_id, fileresourcepartition_name, fileresourcepartition_class) FROM stdin;
1	File	ISGA::File
2	FileCollection	ISGA::FileCollection
\.


--
COPY filetype (filetype_id, filetype_name, filetype_help) FROM stdin;
3	Genome Sequence	The whole sequence of a genome, contig, plasmid, chromosome, etc
4	Nucleotide Sequence	Generic nucleotide sequence. When possible, use a more specific file type.
8	Amino Acid Sequence	Generic amino acid sequence. When possible, use a more specific file type.
10	BLAST Search Result	This is the raw data produced by BLAST.  This data is both the full output and the btab format as well.  When supplying as an input, both the full and the btab formats are acceptable.
30	Toolbox Job Configuration	Contains the settings used to perform a Toolbox job.
31	TFBS Evidence	Collected evidence of TFBS
32	User ORF Prediction Raw Evidence	ORF prediction results produced by gene prediction algorithms such as Glimmer3.  The raw data is ORF coordinate, reading frame, strand, and score information used to extract a nucleotide sequence from a sequence data file.  However, the extracted genes in FASTA format are included in this file type as well.  When supplying as input, this can simply be a set of genes in FASTA format.  When retrieving as output from a pipeline you are receiving the raw coordinate data.  We also provide the extracted ORFs in FASTA format as another file type
33	Native 454 format	The proposed SFF file format is a container file for storing one or many 454 reads. 454 reads differ from standard sequencing reads in that the 454 data does not provide individual base measurements from which basecalls can be derived. Instead, it provides measurements that estimate the length of the next homopolymer stretch in the sequence (i.e., in "AAATGG", "AAA" is a 3-mer stretch of As, "T" is a 1-mer stretch of Ts and "GG" is a 2-mer stretch of Gs). A basecalled sequence is then derived by converting each estimate into a homopolymer stretch of that length and concatenating the homopolymers.
34	Celera Assembler native format	These FRG files consist of sequencer reads and relationships between the reads. Two types of relationships are defined: libraries and mates. A library indicates that all reads in this collection come from the same insert library and thus share numerous properties: end orientation, clone size, randomness, approximate read size, etc. A mate indicates that exactly two reads are from opposite ends of a single clone in a library.
35	Celera Assembler Output	An output produced by the celera assembler program.
36	Mira Assembler Output	An output produced by the mira assembler program.
37	Newbler Assembler Output	An output produced by the newbler assembler program.
38	Hawkeye Input	Hawkeye reads the assembly data from an AMOS bank. A bank is a special directory of binary encoded files containing all information on an assembly. A bank is created by the AMOS assemblers directly, or by converting the results of others assemblers into AMOS format.
39	BLAST HTML Result	An output produced from the raw blast output formatted in an HTML table.
40	Consed Input	A modified ace file for use in Consed.
\.


--
-- Data for Name: gene; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY gene (genomefeature_id, gene_locus, gene_contig, gene_note, gene_type) FROM stdin;
\.


--
-- Data for Name: genetype; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY genetype (genetype_name) FROM stdin;
mRNA
tRNA
rRNA
\.


--
-- Data for Name: genomefeature; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY genomefeature (genomefeature_id, genomefeaturepartition_id, genomefeature_uniquename, genomefeature_start, genomefeature_end, genomefeature_strand) FROM stdin;
\.


--
-- Data for Name: genomefeaturepartition; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY genomefeaturepartition (genomefeaturepartition_id, genomefeaturepartition_name, genomefeaturepartition_class) FROM stdin;
1	mRNA	ISGA::mRNA
2	rRNA	ISGA::rRNA
3	CDS	ISGA::CDS
4	Gene	ISGA::Gene
5	tRNA	ISGA::tRNA
6	Contig	ISGA::Contig
\.



--
-- Data for Name: groupmembership; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY groupmembership (accountgroup_id, party_id) FROM stdin;
\.


--
-- Data for Name: grouppermission; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY grouppermission (accountgroup_id, usecase_id) FROM stdin;
2	138
2	139
2	140
2	178
2	177
3	194
4	198
4	199
4	200
4	201
4	202
4	203
4	204
4	205
4	206
4	207
4	208
4	209
4	210
4	211
4	212
2	214
\.


--
-- Data for Name: inputdependency; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY inputdependency (inputdependency_name) FROM stdin;
Required
Optional
Internal Only
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY job (job_id, job_pid, jobtype_id, job_status, job_createdat, job_finishedat, party_id, job_notifyuser, fileresource_id) FROM stdin;
\.


--
-- Data for Name: jobnotification; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY jobnotification (notification_id, job_id, party_id) FROM stdin;
\.


--
-- Data for Name: jobstatus; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY jobstatus (jobstatus_name) FROM stdin;
Pending
Running
Finished
Error
Failed
\.


--
-- Data for Name: jobtype; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY jobtype (jobtype_id, jobtype_name, jobtype_class) FROM stdin;
1	Blast	ISGA::Job::BLAST
2	MEME	ISGA::Job::MEME
3	MSA	ISGA::Job::MSA
4	Hawkeye	ISGA::Job::Hawkeye
5	Consed	ISGA::Job::Consed
6	SffToFasta	ISGA::Job::SffToFasta
\.


--
-- Data for Name: newstype; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY newstype (newstype_id, newstype_name) FROM stdin;
1	Pipeline Service News
2	Release Announcement
3	Service Outage Report
\.

--
-- Data for Name: notificationpartition; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY notificationpartition (notificationpartition_id, notificationpartition_name, notificationpartition_class) FROM stdin;
1	AccountNotification	ISGA::AccountNotification
2	EmailNotification	ISGA::EmailNotification
3	RunNotification	ISGA::RunNotification
4	JobNotification	ISGA::JobNotification
\.


--
-- Data for Name: notificationtype; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY notificationtype (notificationtype_id, notificationtype_name, notificationpartition_id, notificationtype_subject, notificationtype_template) FROM stdin;
1	Service Outage Restored	1	ISGA Service Available	service_restored.mas
2	Account Request Confirmation	2	Confirm your ISGA account request	account_request.mas
3	Run Canceled	3	Your ISGA pipeline was canceled	run_canceled.mas
4	Gbrowse Instance Ready	3	Your pipelines results have been loaded into Gbrowse.	gbrowse_ready.mas
\.


--
-- Data for Name: outputvisibility; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY outputvisibility (outputvisibility_name) FROM stdin;
Pipeline
Evidence
Internal
\.


--
-- Data for Name: party; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY party (party_id, partypartition_id, party_name, partystatus_id, party_createdat, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden) FROM stdin;
\.


--
-- Data for Name: partypartition; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY partypartition (partypartition_id, partypartition_name, partypartition_class) FROM stdin;
1	Account	ISGA::Account
2	UserGroup	ISGA::UserGroup
\.


--
-- Data for Name: partystatus; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY partystatus (partystatus_id, partystatus_name) FROM stdin;
1	Active
2	ReadOnly
3	Disabled
4	Closed
\.


--
-- Data for Name: passwordchangerequest; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY passwordchangerequest (passwordchangerequest_id, passwordchangerequest_hash, party_id, passwordchangerequest_createdat) FROM stdin;
\.


--
-- Data for Name: pipelineaccess; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY pipelineaccess (party_id, pipeline_id) FROM stdin;
\.


--
-- Data for Name: pipelinebuilder; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY pipelinebuilder (pipelinebuilder_id, pipelinebuilder_name, pipeline_id, pipelinebuilder_description, pipelinebuilder_workflowmask, pipelinebuilder_parametermask, party_id, pipelinebuilder_startedon) FROM stdin;
\.


--
-- Data for Name: pipelinepartition; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY pipelinepartition (pipelinepartition_id, pipelinepartition_name, pipelinepartition_class) FROM stdin;
1	GlobalPipeline	ISGA::GlobalPipeline
2	UserPipeline	ISGA::UserPipeline
\.


--
-- Data for Name: pipelinestatus; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY pipelinestatus (pipelinestatus_id, pipelinestatus_name) FROM stdin;
1	Available
2	Hidden
3	Retired
\.


--
-- Data for Name: rawdatastatus; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY rawdatastatus (rawdatastatus_name) FROM stdin;
Available
Tagged for Deletion
Deleted
\.


--
-- Data for Name: requeststatus; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY requeststatus (requeststatus_name) FROM stdin;
Not Requested
Requested
Processing
Complete
\.


--
-- Data for Name: rrna; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY rrna (genomefeature_id, rrna_score, rrna_gene) FROM stdin;
\.


--
-- Data for Name: run; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY run (run_id, party_id, runstatus_id, run_createdat, run_finishedat, pipeline_id, run_name, run_description, run_ergatiskey, fileresource_id, run_rawdatastatus, run_ishidden) FROM stdin;
\.


--
-- Data for Name: runaccess; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runaccess (party_id, run_id) FROM stdin;
\.


--
-- Data for Name: runbuilder; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runbuilder (runbuilder_id, runbuilder_name, pipeline_id, runbuilder_startedat, runbuilder_description, runbuilder_ergatisdirectory, runbuilder_parametermask, party_id) FROM stdin;
\.


--
-- Data for Name: runbuilderinput; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runbuilderinput (runbuilderinput_id, fileresource_id, runbuilder_id, pipelineinput_id, runbuilderinput_parametermask) FROM stdin;
\.


--
-- Data for Name: runcancelation; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runcancelation (runcancelation_id, run_id, party_id, runcancelation_canceledat, runcancelation_comment) FROM stdin;
\.


--
-- Data for Name: runcluster; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runcluster (runcluster_id, run_id, cluster_id, runstatus_id, runcluster_startedat, runcluster_finishedat, runcluster_finishedactions, runcluster_totalactions, runcluster_iterations) FROM stdin;
\.


--
-- Data for Name: runinput; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runinput (fileresource_id, run_id, runinput_id, pipelineinput_id, runinput_parametermask) FROM stdin;
\.


--
-- Data for Name: runnotification; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runnotification (notification_id, run_id, party_id) FROM stdin;
\.


--
-- Data for Name: runoutput; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runoutput (runoutput_id, fileresource_id, run_id, clusteroutput_id) FROM stdin;
\.


--
-- Data for Name: runstatus; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY runstatus (runstatus_id, runstatus_name) FROM stdin;
1	Running
2	Canceled
3	Complete
4	Held
5	Error
6	Submitting
7	Incomplete
8	Failed
9	Interrupted
\.


--
-- Data for Name: siteconfiguration; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY siteconfiguration (siteconfiguration_id, configurationvariable_id, siteconfiguration_type, siteconfiguration_value) FROM stdin;
1	1	SiteConfiguration	1
2	2	SiteConfiguration	Default User
3	7	SiteConfiguration	nobody@nowhere.org
\.


--
-- Data for Name: stylesheet; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY stylesheet (stylesheet_name) FROM stdin;
1column
2column
2columnright
3column
none
\.


--
-- Data for Name: toolconfiguration; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY toolconfiguration (toolconfiguration_id, configurationvariable_id, jobtype_id, userclass_id, toolconfiguration_type, toolconfiguration_value) FROM stdin;
1	6	1	\N	ToolConfiguration	1
2	6	4	\N	ToolConfiguration	1
3	6	5	\N	ToolConfiguration	1
\.


--
-- Data for Name: trna; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY trna (genomefeature_id, trna_score, trna_trnaanticodon, trna_gene) FROM stdin;
\.


--
-- Data for Name: usecase; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY usecase (usecase_id, usecase_name, usecase_action, usecase_requireslogin, usecase_menu, usecase_title, usecase_stylesheet, usecase_hasdocumentation) FROM stdin;
1	/index.html	\N	f	\N	Home	2columnright	t
2	/Home	\N	f	\N	Home	1column	t
3	/Error	\N	f	\N	Error	2columnright	f
4	/LoginSuccess	\N	f	\N	\N	none	f
5	/LoginError	\N	f	\N	\N	none	f
6	/Success	\N	f	\N	\N	none	f
7	/submit/Login	Login	f	\N	\N	none	f
8	/submit/Logout	Logout	t	\N	\N	none	f
9	/Account/Overview	\N	f	\N	Accounts Overview	2columnright	f
10	/Account/Request	\N	f	\N	Request Account	2columnright	f
11	/Account/Requested	\N	f	\N	Requested Account	2columnright	f
12	/Account/Confirmed	\N	f	\N	Confirm Account Request	2columnright	f
13	/Account/MyAccount	\N	t	\N	My Account	2columnright	f
14	/Account/LostPassword	\N	f	\N	Lost Password Help	2columnright	f
15	/Account/PasswordChangeSent	\N	f	\N	Password Change Sent	2columnright	f
16	/Account/ResetPassword	\N	f	\N	Password Reset Form	2columnright	f
17	/Account/PasswordResetCompleted	\N	f	\N	Password Successfully Reset	2columnright	f
18	/Account/EditMyDetails	\N	t	\N	Edit My Account	2columnright	f
19	/Account/ChangeMyPassword	\N	t	\N	Change My Password	2columnright	f
20	/submit/Account/Request	Account::Request	f	\N	\N	none	f
21	/submit/Account/Confirm	Account::Confirm	f	\N	\N	none	f
22	/submit/Account/LostPassword	Account::LostPassword	f	\N	\N	none	f
23	/submit/Account/ResetPassword	Account::ResetPassword	f	\N	\N	none	f
24	/submit/Account/ChangeMyPassword	Account::ChangeMyPassword	f	\N	\N	none	f
25	/submit/Account/EditMyDetails	Account::EditMyDetails	f	\N	\N	none	f
27	/Cluster/GetClusterDescription	\N	f	\N	\N	none	f
28	/submit/Cluster/Configure	Cluster::Configure	t	\N	\N	none	f
29	/Component/GetParameterDescription	\N	f	\N	\N	none	f
30	/FileCollection/View	\N	t	\N	File Collection Details	2columnright	f
31	/File/Overview	\N	f	\N	File Overview	2columnright	f
32	/File/BrowseMy	\N	t	\N	List My Files	2columnright	f
33	/File/View	\N	t	\N	File Details	2columnright	f
34	/File/EditDescription	\N	t	\N	Edit File Description	2columnright	f
35	/File/Upload	\N	t	\N	File Upload	2columnright	f
36	/File/BrowseMySort	\N	t	\N	\N	none	f
37	/submit/File/Upload	File::Upload	t	\N	\N	none	f
38	/submit/File/Hide	File::Hide	t	\N	\N	none	f
39	/submit/File/Restore	File::Restore	t	\N	\N	none	f
40	/submit/File/EditDescription	File::EditDescription	t	\N	\N	none	f
41	/FileContent/ViewHelp	\N	f	\N	\N	none	f
42	/FileFormat/ViewHelp	\N	f	\N	\N	none	f
43	/FileType/ViewHelp	\N	f	\N	\N	none	f
44	/Help/ContactUs	\N	f	\N	Send Feedback	2columnright	f
45	/Help/FAQ	\N	f	\N	FAQs	2columnright	f
46	/Help/FeedbackSent	\N	f	\N	Feedback Sent	2columnright	f
47	/Help/Introduction	\N	f	\N	Site Introduction	2columnright	f
48	/Help/Tutorial	\N	f	\N	Tutorials	2columnright	f
49	/Help/KnownIssues	\N	f	\N	Known Issues	2columnright	f
50	/Help/Overview	\N	f	\N	Help Overview	2columnright	f
51	/submit/Help/ContactUs	Help::ContactUs	f	\N	\N	none	f
52	/News/Recent	\N	f	\N	Recent News	2columnright	f
56	/News/Create	\N	t	\N	Create News Entry	2columnright	f
57	/News/Edit	\N	t	\N	Create News Entry	2columnright	f
58	/submit/News/Create	News::Create	t	\N	\N	none	f
59	/submit/News/Edit	News::Edit	t	\N	\N	none	f
60	/Pipeline/List	\N	f	\N	Pipeline List	2columnright	t
61	/Pipeline/View	\N	f	\N	Pipeline	2columnright	t
62	/Pipeline/ViewInputs	\N	f	\N	Pipeline Inputs	2columnright	f
63	/Pipeline/ViewOutputs	\N	f	\N	Pipeline Outputs	2columnright	f
64	/Pipeline/ViewClusters	\N	t	\N	Select A Cluster	2columnright	f
65	/Pipeline/ViewParameters	\N	t	\N	View Program Parameters	2columnright	f
66	/Pipeline/ViewComponents	\N	t	\N	View Cluster Components	2columnright	f
67	/Pipeline/GetDescription	\N	f	\N	\N	none	f
68	/Pipeline/DrawWorkflow	\N	f	\N	\N	none	f
70	/PipelineBuilder/EditDetails	\N	t	\N	Pipeline Builder Details	2columnright	f
71	/PipelineBuilder/Overview	\N	t	\N	Pipeline Builder Overview	2columnright	t
74	/PipelineBuilder/EditCluster	\N	t	\N	Pipeline Builder Edit Cluster	2columnright	t
75	/PipelineBuilder/EditComponent	\N	t	\N	Pipeline Builder Edit Component	2columnright	t
76	/PipelineBuilder/AnnotateCluster	\N	t	\N	Pipeline Builder Annotate Cluster	2columnright	t
80	/PipelineBuilder/Success	\N	t	\N	Pipeline Created	2columnright	t
82	/PipelineBuilder/DrawWorkflow	\N	t	\N	\N	none	f
83	/PipelineBuilder/DrawClusters	\N	t	\N	\N	none	f
84	/PipelineBuilder/ChooseComponent	\N	t	\N	\N	none	f
85	/PipelineBuilder/Cancel	\N	t	\N	\N	none	f
86	/PipelineBuilder/ConfirmFinalize	\N	t	\N	\N	none	f
87	/submit/PipelineBuilder/Create	PipelineBuilder::Create	t	\N	\N	none	f
88	/submit/PipelineBuilder/AnnotateCluster	PipelineBuilder::AnnotateCluster	t	\N	\N	none	f
89	/submit/PipelineBuilder/EditCluster	PipelineBuilder::EditCluster	t	\N	\N	none	f
90	/submit/PipelineBuilder/EditWorkflow	PipelineBuilder::EditWorkflow	t	\N	\N	none	f
91	/submit/PipelineBuilder/Finalize	PipelineBuilder::Finalize	t	\N	\N	none	f
92	/submit/PipelineBuilder/EditDetails	PipelineBuilder::EditDetails	t	\N	\N	none	f
93	/submit/PipelineBuilder/Remove	PipelineBuilder::Remove	t	\N	\N	none	f
94	/submit/PipelineBuilder/EditComponent	PipelineBuilder::EditComponent	t	\N	\N	none	f
95	/submit/PipelineBuilder/ChooseComponent	PipelineBuilder::ChooseComponent	t	\N	\N	none	f
97	/Run/Overview	\N	f	\N	Run Overview	2columnright	f
99	/Run/MyResults	\N	t	\N	Summarize Results	1column	f
100	/Run/Status	\N	t	\N	Runs	2columnright	f
102	/Run/GetDescription	\N	t	\N	\N	none	f
103	/submit/Run/Submit	Run::Submit	t	\N	\N	none	f
104	/RunBuilder/View	\N	t	\N	View RunBuilder Status	2columnright	t
106	/RunBuilder/EditDetails	\N	t	\N	Edit Run Details	2columnright	f
107	/RunBuilder/EditParameters	\N	t	\N	Edit Run Parameters	2columnright	t
108	/RunBuilder/ListMy	\N	t	\N	View Runs Being Built	2columnright	f
109	/RunBuilder/SelectInput	\N	t	\N	Select Run Inputs	2columnright	f
110	/RunBuilder/SelectInputList	\N	t	\N	Select Run Inputs	2columnright	t
112	/submit/RunBuilder/SelectInput	RunBuilder::SelectInput	t	\N	\N	none	f
113	/submit/RunBuilder/SelectInputList	RunBuilder::SelectInputList	t	\N	\N	none	f
114	/submit/RunBuilder/EditDetails	RunBuilder::EditDetails	t	\N	\N	none	f
115	/submit/RunBuilder/EditParameters	RunBuilder::EditParameters	t	\N	\N	none	f
116	/submit/RunBuilder/Create	RunBuilder::Create	t	\N	\N	none	f
117	/submit/RunBuilder/Cancel	RunBuilder::Cancel	t	\N	\N	none	f
119	/RunBuilder/Cancel	\N	t	\N	\N	none	f
120	/RunBuilder/ViewInputs	\N	t	\N	\N	none	f
121	/RunBuilder/Submit	\N	t	\N	\N	none	f
122	/UserGroup/Create	\N	t	\N	Create new Group	2columnright	f
123	/UserGroup/Edit	\N	t	\N	Edit a Group	2columnright	f
124	/UserGroup/View	\N	t	\N	View a Group	2columnright	f
125	/UserGroup/Overview	\N	f	\N	Group Details	2columnright	f
126	/submit/UserGroup/Create	UserGroup::Create	t	\N	\N	none	f
127	/submit/UserGroup/Edit	UserGroup::Edit	t	\N	\N	none	f
128	/submit/UserGroup/Leave	UserGroup::Leave	t	\N	\N	none	f
129	/Browser	\N	t	\N	Genome Browser	1column	f
98	/Run/ListMy	\N	t	\N	List My Runs	2columnright	f
131	/WorkBench/Blast	\N	t	\N	Blast Interface	2columnright	f
132	/WorkBench/Results/Blast	\N	t	\N	View Blast Results	2columnright	f
133	/WorkBench/File/View	\N	t	\N	Workbench view of file	2columnright	f
134	/WorkBench/MSA	\N	t	\N	Workbench MSA	2columnright	f
135	/WorkBench/ConfirmMSA	\N	t	\N	Workbench MSA Confirmation	2columnright	f
136	/submit/WorkBench/Blast	WorkBench::Blast	t	\N	\N	none	f
137	/submit/WorkBench/MSA	WorkBench::MSA	t	\N	\N	none	f
139	/Run/Cancel	\N	t	\N	Cancel Run	2columnright	f
140	/submit/Run/Cancel	Run::Cancel	t	\N	\N	none	f
141	/GenomeFeature/View	\N	t	\N	View Genome Feature Details	2columnright	f
138	/Run/AdminList	\N	t	\N	Admin Run List	2columnright	f
142	/submit/Run/InstallGbrowseData	Run::InstallGbrowseData	t	\N	\N	none	f
96	/Run/View	\N	t	\N	View Run	2columnright	f
143	/WorkBench/Results/MSA	\N	t	\N	View MSA Results	2columnright	f
144	/WorkBench/ProtDist	\N	t	\N	Phylogenetic Analysis	2columnright	f
145	/WorkBench/ProtPars	\N	t	\N	Phylogenetic Analysis	2columnright	f
146	/WorkBench/ProtML	\N	t	\N	Phylogenetic Analysis	2columnright	f
147	/WorkBench/DnaPars	\N	t	\N	Phylogenetic Analysis	2columnright	f
148	/WorkBench/DnaDist	\N	t	\N	Phylogenetic Analysis	2columnright	f
149	/WorkBench/DnaML	\N	t	\N	Phylogenetic Analysis	2columnright	f
150	/WorkBench/Results/ProtDist	\N	t	\N	Phylogenetic Analysis Results	2columnright	f
130	/WorkBench/Overview	\N	f	\N	Toolbox Overview	2columnright	f
151	/WorkBench/Results/ProtPars	\N	t	\N	Phylogenetic Analysis Results	2columnright	f
152	/WorkBench/Results/ProtML	\N	t	\N	Phylogenetic Analysis Results	2columnright	f
153	/WorkBench/Results/DnaPars	\N	t	\N	Phylogenetic Analysis Results	2columnright	f
154	/WorkBench/Results/DnaDist	\N	t	\N	Phylogenetic Analysis Results	2columnright	f
155	/WorkBench/Results/DnaML	\N	t	\N	Phylogenetic Analysis Results	2columnright	f
156	/submit/WorkBench/ProtDist	WorkBench::ProtDist	t	\N	\N	none	f
157	/submit/WorkBench/ProtPars	WorkBench::ProtPars	t	\N	\N	none	f
158	/submit/WorkBench/ProtML	WorkBench::ProtML	t	\N	\N	none	f
159	/submit/WorkBench/DnaDist	WorkBench::DnaDist	t	\N	\N	none	f
160	/submit/WorkBench/DnaPars	WorkBench::DnaPars	t	\N	\N	none	f
161	/submit/WorkBench/DnaML	WorkBench::DnaML	t	\N	\N	none	f
162	/Pipeline/ViewInputsOutputs	\N	f	\N	View Pipeline Inputs and Outputs	2columnright	f
163	/PipelineBuilder/ViewInputsOutputs	\N	f	\N	View Pipeline Inputs and Outputs	2columnright	f
166	/Help/Policies	\N	t	\N	View ISGA Policies	2columnright	f
167	/Help/Acknowledgement	\N	f	\N	View ISGA Acknowledgement	2columnright	f
168	/WorkBench/GenomeFeatureQuery	\N	t	\N	Search your Genome Features	2columnright	f
169	/WorkBench/Results/GenomeFeatureQuery	\N	t	\N	Genome Feature Search Results	2columnright	f
170	/WorkBench/GBrowse	\N	t	\N	View in GBrowse	2columnright	f
172	/submit/Run/Hide	Run::Hide	t	\N	\N	none	f
173	/submit/Workbench/Notify	WorkBench::Notify	t	\N	\N	none	f
176	/Pipeline/ClusterOptions	\N	t	\N	\N	none	f
177	/submit/Run/Clone	Run::Clone	t	\N	\N	none	f
178	/Run/Clone	\N	t	\N	Clone Run	2columnright	f
179	/submit/Run/Show	Run::Show	t	\N	\N	none	f
180	/Help/DownloadISGA	\N	f	\N	Download ISGA	2columnright	f
181	/submit/Account/OutageNotification	Account::OutageNotification	t	\N	\N	none	f
182	/WorkBench/NewblerToHawkeye	\N	t	\N	Newbler To Hawkeye	2columnright	f
183	/submit/WorkBench/NewblerToHawkeye	WorkBench::NewblerToHawkeye	t	\N	\N	none	f
184	/WorkBench/CeleraToHawkeye	\N	t	\N	Celera To Hawkeye	2columnright	f
185	/submit/WorkBench/CeleraToHawkeye	WorkBench::CeleraToHawkeye	t	\N	\N	none	f
186	/WorkBench/MiraToHawkeye	\N	t	\N	Mira To Hawkeye	2columnright	f
187	/submit/WorkBench/MiraToHawkeye	WorkBench::MiraToHawkeye	t	\N	\N	none	f
188	/submit/WorkBench/HawkeyeInputUpload	WorkBench::HawkeyeInputUpload	t	\N	\N	none	f
189	/UploadSuccess	\N	t	\N	\N	none	f
190	/WorkBench/Results/Hawkeye	\N	t	\N	Results for Hawkeye	2columnright	f
191	/submit/RunBuilder/RemoveInput	RunBuilder::RemoveInput	t	\N	\N	none	f
192	/submit/RunBuilder/RemoveInputList	RunBuilder::RemoveInputList	t	\N	\N	none	f
193	/WorkBench/BrowseMy	\N	t	\N	Browse Jobs	2columnright	f
194	/Account/View	\N	t	\N	Account View	2columnright	f
195	/WorkBench/NewblerForConsed	\N	t	\N	Newbler Scaffold For Consed	2columnright	f
196	/submit/WorkBench/NewblerScaffold4Consed	WorkBench::NewblerScaffold4Consed	t	\N	\N	none	f
197	/WorkBench/Results/NewblerForConsed	\N	t	\N	Results for Consed	2columnright	f
198	/UserClass/View	\N	t	\N	UserClass View	2columnright	f
199	/UserClass/List	\N	t	\N	UserClass List	2columnright	f
200	/UserClass/Add	\N	t	\N	UserClass Add	2columnright	f
201	/UserClass/Edit	\N	t	\N	UserClass Edit	2columnright	f
202	/submit/UserClass/Add	UserClass::Add	t	\N	\N	none	f
203	/submit/UserClass/Edit	UserClass::Edit	t	\N	\N	none	f
204	/SiteConfiguration/View	\N	t	\N	Site Configuration	2columnright	f
205	/SiteConfiguration/Edit	\N	t	\N	Site Configuration Edit	2columnright	f
206	/submit/SiteConfiguration/Edit	SiteConfiguration::Edit	t	\N	\N	none	f
207	/PipelineConfiguration/View	\N	t	\N	Site Configuration	2columnright	f
208	/PipelineConfiguration/Edit	\N	t	\N	Site Configuration Edit	2columnright	f
209	/submit/PipelineConfiguration/Edit	PipelineConfiguration::Edit	t	\N	\N	none	f
210	/UserClassConfiguration/View	\N	t	\N	Site Configuration	2columnright	f
211	/UserClassConfiguration/Edit	\N	t	\N	Site Configuration Edit	2columnright	f
212	/submit/UserClassConfiguration/Edit	UserClassConfiguration::Edit	t	\N	\N	none	f
26	/submit/Account/ShowHideWalkthrough	Account::ShowHideWalkthrough	t	\N	\N	none	f
213	/RunBuilder/ViewInputError	\N	t	\N	Input Error	2columnright	f
214	/RunBuilder/AdminList	\N	t	\N	Administrator Run Builder list	2columnright	f
215	/RunBuilder/UploadInput	\N	t	\N	Input Upload	none	f
216	/submit/RunBuilder/UploadInput	RunBuilder::UploadInput	t	\N	\N	none	f
217	/WorkBench/SffToFasta	\N	t	\N	Sff To Fasta	2columnright	f
218	/submit/WorkBench/SffToFasta	WorkBench::SffToFasta	t	\N	\N	none	f
219	/WorkBench/Results/SffToFasta	\N	t	\N	Results for SffToFasta	2columnright	f
\.


--
-- Data for Name: userclass; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY userclass (userclass_id, userclass_name, userclass_description) FROM stdin;
1	Default User	A default class for simple ISGA installations.
\.


--
-- Data for Name: userclassconfiguration; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY userclassconfiguration (userclassconfiguration_id, configurationvariable_id, userclass_id, userclassconfiguration_type, userclassconfiguration_value) FROM stdin;
1	4	1	UserClassConfiguration	30
2	5	1	UserClassConfiguration	1
\.


--
-- Data for Name: usergroup; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY usergroup (party_id, account_id) FROM stdin;
\.


--
-- Data for Name: usergroupemailinvitation; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY usergroupemailinvitation (usergroupemailinvitation_id, usergroup_id, usergroupemailinvitation_email, usergroupemailinvitation_createdat) FROM stdin;
\.


--
-- Data for Name: usergroupinvitation; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY usergroupinvitation (usergroupinvitation_id, usergroup_id, party_id, usergroupinvitation_createdat) FROM stdin;
\.


--
-- Data for Name: usergroupmembership; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY usergroupmembership (usergroup_id, account_id) FROM stdin;
\.


--
-- Data for Name: userpipeline; Type: TABLE DATA; Schema: public; Owner: chemmeri
--

COPY userpipeline (pipeline_id, userpipeline_template, party_id, userpipeline_createdat, userpipeline_parametermask) FROM stdin;
\.


--
-- Name: account_account_email_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_account_email_key UNIQUE (account_email);


--
-- Name: account_party_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_party_id_key UNIQUE (party_id);


--
-- Name: accountgroup_accountgroup_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY accountgroup
    ADD CONSTRAINT accountgroup_accountgroup_name_key UNIQUE (accountgroup_name);


--
-- Name: accountgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY accountgroup
    ADD CONSTRAINT accountgroup_pkey PRIMARY KEY (accountgroup_id);


--
-- Name: accountnotification_notification_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY accountnotification
    ADD CONSTRAINT accountnotification_notification_id_key UNIQUE (notification_id);


--
-- Name: accountrequest_accountrequest_email_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY accountrequest
    ADD CONSTRAINT accountrequest_accountrequest_email_key UNIQUE (accountrequest_email);


--
-- Name: accountrequest_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY accountrequest
    ADD CONSTRAINT accountrequest_pkey PRIMARY KEY (accountrequest_id);


--
-- Name: accountrequeststatus_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY accountrequeststatus
    ADD CONSTRAINT accountrequeststatus_pkey PRIMARY KEY (accountrequeststatus_name);


--
-- Name: cds_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY cds
    ADD CONSTRAINT cds_pkey PRIMARY KEY (genomefeature_id);


--
-- Name: cluster_cluster_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY "cluster"
    ADD CONSTRAINT cluster_cluster_name_key UNIQUE (cluster_name);


--
-- Name: cluster_cluster_subclass_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY "cluster"
    ADD CONSTRAINT cluster_cluster_subclass_key UNIQUE (cluster_subclass);


--
-- Name: cluster_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY "cluster"
    ADD CONSTRAINT cluster_pkey PRIMARY KEY (cluster_id);


--
-- Name: clusterinput_clusterinput_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY clusterinput
    ADD CONSTRAINT clusterinput_clusterinput_name_key UNIQUE (clusterinput_name);


--
-- Name: clusterinput_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY clusterinput
    ADD CONSTRAINT clusterinput_pkey PRIMARY KEY (clusterinput_id);


--
-- Name: clusteroutput_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY clusteroutput
    ADD CONSTRAINT clusteroutput_pkey PRIMARY KEY (clusteroutput_id);


--
-- Name: component_cluster_index_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_cluster_index_key UNIQUE (cluster_id, component_index);


--
-- Name: component_component_ergatisname_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_component_ergatisname_key UNIQUE (component_ergatisname);


--
-- Name: component_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_pkey PRIMARY KEY (component_id);


--
-- Name: componentinputmap_pk; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY componentinputmap
    ADD CONSTRAINT componentinputmap_pk UNIQUE (component_id, clusterinput_id);


--
-- Name: componenttemplate_componenttemplate_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY componenttemplate
    ADD CONSTRAINT componenttemplate_componenttemplate_name_key UNIQUE (componenttemplate_name);


--
-- Name: componenttemplate_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY componenttemplate
    ADD CONSTRAINT componenttemplate_pkey PRIMARY KEY (componenttemplate_id);


--
-- Name: configurationtype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY configurationtype
    ADD CONSTRAINT configurationtype_pkey PRIMARY KEY (configurationtype_name);


--
-- Name: configurationvariable_k; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY configurationvariable
    ADD CONSTRAINT configurationvariable_k UNIQUE (configurationvariable_id, configurationvariable_type);


--
-- Name: configurationvariable_k2; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY configurationvariable
    ADD CONSTRAINT configurationvariable_k2 UNIQUE (configurationvariable_type, configurationvariable_name);


--
-- Name: configurationvariable_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY configurationvariable
    ADD CONSTRAINT configurationvariable_pkey PRIMARY KEY (configurationvariable_id);


--
-- Name: contig_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY contig
    ADD CONSTRAINT contig_pkey PRIMARY KEY (genomefeature_id);


--
-- Name: datatype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY datatype
    ADD CONSTRAINT datatype_pkey PRIMARY KEY (datatype_name);


--
-- Name: emailnotification_notification_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY emailnotification
    ADD CONSTRAINT emailnotification_notification_id_key UNIQUE (notification_id);


--
-- Name: ergatisformat_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY ergatisformat
    ADD CONSTRAINT ergatisformat_pkey PRIMARY KEY (ergatisformat_name);


--
-- Name: exdb_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY exdb
    ADD CONSTRAINT exdb_pkey PRIMARY KEY (exdb_id);


--
-- Name: file_fileresource_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_fileresource_id_key UNIQUE (fileresource_id);


--
-- Name: filecollection_fileresource_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY filecollection
    ADD CONSTRAINT filecollection_fileresource_id_key UNIQUE (fileresource_id);


--
-- Name: filecollectioncontent_indexkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY filecollectioncontent
    ADD CONSTRAINT filecollectioncontent_indexkey UNIQUE (fileresource_id, filecollectioncontent_index);


--
-- Name: filecollectioncontent_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY filecollectioncontent
    ADD CONSTRAINT filecollectioncontent_pkey PRIMARY KEY (filecollectioncontent_id);


--
-- Name: filecollectiontype_filecollectiontype_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY filecollectiontype
    ADD CONSTRAINT filecollectiontype_filecollectiontype_name_key UNIQUE (filecollectiontype_name);


--
-- Name: filecollectiontype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY filecollectiontype
    ADD CONSTRAINT filecollectiontype_pkey PRIMARY KEY (filecollectiontype_id);


--
-- Name: fileformat_fileformat_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY fileformat
    ADD CONSTRAINT fileformat_fileformat_name_key UNIQUE (fileformat_name);


--
-- Name: fileformat_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY fileformat
    ADD CONSTRAINT fileformat_pkey PRIMARY KEY (fileformat_id);


--
-- Name: fileresource_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY fileresource
    ADD CONSTRAINT fileresource_pkey PRIMARY KEY (fileresource_id);


--
-- Name: fileresourcepartition_fileresourcepartition_class_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY fileresourcepartition
    ADD CONSTRAINT fileresourcepartition_fileresourcepartition_class_key UNIQUE (fileresourcepartition_class);


--
-- Name: fileresourcepartition_fileresourcepartition_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY fileresourcepartition
    ADD CONSTRAINT fileresourcepartition_fileresourcepartition_name_key UNIQUE (fileresourcepartition_name);


--
-- Name: fileresourcepartition_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY fileresourcepartition
    ADD CONSTRAINT fileresourcepartition_pkey PRIMARY KEY (fileresourcepartition_id);


--
-- Name: filetype_filetype_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY filetype
    ADD CONSTRAINT filetype_filetype_name_key UNIQUE (filetype_name);


--
-- Name: filetype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY filetype
    ADD CONSTRAINT filetype_pkey PRIMARY KEY (filetype_id);


--
-- Name: gene_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY gene
    ADD CONSTRAINT gene_pkey PRIMARY KEY (genomefeature_id);


--
-- Name: genetype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY genetype
    ADD CONSTRAINT genetype_pkey PRIMARY KEY (genetype_name);


--
-- Name: genomefeature_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY genomefeature
    ADD CONSTRAINT genomefeature_pkey PRIMARY KEY (genomefeature_id);


--
-- Name: genomefeaturepartition_genomefeaturepartition_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY genomefeaturepartition
    ADD CONSTRAINT genomefeaturepartition_genomefeaturepartition_name_key UNIQUE (genomefeaturepartition_name);


--
-- Name: genomefeaturepartition_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY genomefeaturepartition
    ADD CONSTRAINT genomefeaturepartition_pkey PRIMARY KEY (genomefeaturepartition_id);


--
-- Name: globalpipeline_pipeline_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY globalpipeline
    ADD CONSTRAINT globalpipeline_pipeline_id_key UNIQUE (pipeline_id);


--
-- Name: grouppermission_pk; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY grouppermission
    ADD CONSTRAINT grouppermission_pk UNIQUE (accountgroup_id, usecase_id);


--
-- Name: inputdependency_pkey1; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY inputdependency
    ADD CONSTRAINT inputdependency_pkey1 PRIMARY KEY (inputdependency_name);


--
-- Name: job_job_pid_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_job_pid_key UNIQUE (job_pid);


--
-- Name: job_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_pkey PRIMARY KEY (job_id);


--
-- Name: jobnotification_notification_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY jobnotification
    ADD CONSTRAINT jobnotification_notification_id_key UNIQUE (notification_id);


--
-- Name: jobstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY jobstatus
    ADD CONSTRAINT jobstatus_pkey PRIMARY KEY (jobstatus_name);


--
-- Name: jobtype_jobtype_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY jobtype
    ADD CONSTRAINT jobtype_jobtype_name_key UNIQUE (jobtype_name);


--
-- Name: jobtype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY jobtype
    ADD CONSTRAINT jobtype_pkey PRIMARY KEY (jobtype_id);


--
-- Name: mrna_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY mrna
    ADD CONSTRAINT mrna_pkey PRIMARY KEY (genomefeature_id);


--
-- Name: news_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_pkey PRIMARY KEY (news_id);


--
-- Name: newstype_newstype_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY newstype
    ADD CONSTRAINT newstype_newstype_name_key UNIQUE (newstype_name);


--
-- Name: newstype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY newstype
    ADD CONSTRAINT newstype_pkey PRIMARY KEY (newstype_id);


--
-- Name: notification_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (notification_id);


--
-- Name: notification_type_name_partition_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY notificationtype
    ADD CONSTRAINT notification_type_name_partition_key UNIQUE (notificationtype_id, notificationpartition_id);


--
-- Name: notificationpartition_notificationpartition_class_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY notificationpartition
    ADD CONSTRAINT notificationpartition_notificationpartition_class_key UNIQUE (notificationpartition_class);


--
-- Name: notificationpartition_notificationpartition_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY notificationpartition
    ADD CONSTRAINT notificationpartition_notificationpartition_name_key UNIQUE (notificationpartition_name);


--
-- Name: notificationpartition_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY notificationpartition
    ADD CONSTRAINT notificationpartition_pkey PRIMARY KEY (notificationpartition_id);


--
-- Name: notificationtype_notificationtype_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY notificationtype
    ADD CONSTRAINT notificationtype_notificationtype_name_key UNIQUE (notificationtype_name);


--
-- Name: notificationtype_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY notificationtype
    ADD CONSTRAINT notificationtype_pkey PRIMARY KEY (notificationtype_id);


--
-- Name: outputvisibility_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY outputvisibility
    ADD CONSTRAINT outputvisibility_pkey PRIMARY KEY (outputvisibility_name);


--
-- Name: party_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_pkey PRIMARY KEY (party_id);


--
-- Name: partypartition_partypartition_class_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY partypartition
    ADD CONSTRAINT partypartition_partypartition_class_key UNIQUE (partypartition_class);


--
-- Name: partypartition_partypartition_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY partypartition
    ADD CONSTRAINT partypartition_partypartition_name_key UNIQUE (partypartition_name);


--
-- Name: partypartition_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY partypartition
    ADD CONSTRAINT partypartition_pkey PRIMARY KEY (partypartition_id);


--
-- Name: partystatus_partystatus_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY partystatus
    ADD CONSTRAINT partystatus_partystatus_name_key UNIQUE (partystatus_name);


--
-- Name: partystatus_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY partystatus
    ADD CONSTRAINT partystatus_pkey PRIMARY KEY (partystatus_id);


--
-- Name: passwordchangerequest_party_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY passwordchangerequest
    ADD CONSTRAINT passwordchangerequest_party_id_key UNIQUE (party_id);


--
-- Name: passwordchangerequest_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY passwordchangerequest
    ADD CONSTRAINT passwordchangerequest_pkey PRIMARY KEY (passwordchangerequest_id);


--
-- Name: pipeline_pipeline_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipeline
    ADD CONSTRAINT pipeline_pipeline_name_key UNIQUE (pipeline_name);


--
-- Name: pipeline_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipeline
    ADD CONSTRAINT pipeline_pkey PRIMARY KEY (pipeline_id);


--
-- Name: pipelinebuilder_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelinebuilder
    ADD CONSTRAINT pipelinebuilder_pkey PRIMARY KEY (pipelinebuilder_id);


--
-- Name: pipelineconfiguration_k; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelineconfiguration
    ADD CONSTRAINT pipelineconfiguration_k UNIQUE (configurationvariable_id, pipeline_id, userclass_id);


--
-- Name: pipelineconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelineconfiguration
    ADD CONSTRAINT pipelineconfiguration_pkey PRIMARY KEY (pipelineconfiguration_id);


--
-- Name: pipelineinput_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelineinput
    ADD CONSTRAINT pipelineinput_pkey PRIMARY KEY (pipelineinput_id);


--
-- Name: pipelinepartition_pipelinepartition_class_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelinepartition
    ADD CONSTRAINT pipelinepartition_pipelinepartition_class_key UNIQUE (pipelinepartition_class);


--
-- Name: pipelinepartition_pipelinepartition_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelinepartition
    ADD CONSTRAINT pipelinepartition_pipelinepartition_name_key UNIQUE (pipelinepartition_name);


--
-- Name: pipelinepartition_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelinepartition
    ADD CONSTRAINT pipelinepartition_pkey PRIMARY KEY (pipelinepartition_id);


--
-- Name: pipelinestatus_pipelinestatus_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelinestatus
    ADD CONSTRAINT pipelinestatus_pipelinestatus_name_key UNIQUE (pipelinestatus_name);


--
-- Name: pipelinestatus_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY pipelinestatus
    ADD CONSTRAINT pipelinestatus_pkey PRIMARY KEY (pipelinestatus_id);


--
-- Name: rawdatastatus_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY rawdatastatus
    ADD CONSTRAINT rawdatastatus_pkey PRIMARY KEY (rawdatastatus_name);


--
-- Name: requeststatus_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY requeststatus
    ADD CONSTRAINT requeststatus_pkey PRIMARY KEY (requeststatus_name);


--
-- Name: rrna_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY rrna
    ADD CONSTRAINT rrna_pkey PRIMARY KEY (genomefeature_id);


--
-- Name: run_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_pkey PRIMARY KEY (run_id);


--
-- Name: run_run_ergatiskey_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_run_ergatiskey_key UNIQUE (run_ergatiskey);


--
-- Name: runbuilder_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runbuilder
    ADD CONSTRAINT runbuilder_pkey PRIMARY KEY (runbuilder_id);


--
-- Name: runbuilder_runbuilder_ergatisdirectory_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runbuilder
    ADD CONSTRAINT runbuilder_runbuilder_ergatisdirectory_key UNIQUE (runbuilder_ergatisdirectory);


--
-- Name: runbuilderinput_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runbuilderinput
    ADD CONSTRAINT runbuilderinput_pkey PRIMARY KEY (runbuilderinput_id);


--
-- Name: runcancelation_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runcancelation
    ADD CONSTRAINT runcancelation_pkey PRIMARY KEY (runcancelation_id);


--
-- Name: runcancelation_run_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runcancelation
    ADD CONSTRAINT runcancelation_run_id_key UNIQUE (run_id);


--
-- Name: runcluster_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runcluster
    ADD CONSTRAINT runcluster_pkey PRIMARY KEY (runcluster_id);


--
-- Name: runnotification_notification_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runnotification
    ADD CONSTRAINT runnotification_notification_id_key UNIQUE (notification_id);


--
-- Name: runoutput_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runoutput
    ADD CONSTRAINT runoutput_pkey PRIMARY KEY (runoutput_id);


--
-- Name: runstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runstatus
    ADD CONSTRAINT runstatus_pkey PRIMARY KEY (runstatus_id);


--
-- Name: runstatus_runstatus_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY runstatus
    ADD CONSTRAINT runstatus_runstatus_name_key UNIQUE (runstatus_name);

--
-- Name: siteconfiguration_configurationvariable_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY siteconfiguration
    ADD CONSTRAINT siteconfiguration_configurationvariable_id_key UNIQUE (configurationvariable_id);


--
-- Name: siteconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY siteconfiguration
    ADD CONSTRAINT siteconfiguration_pkey PRIMARY KEY (siteconfiguration_id);


--
-- Name: stylesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY stylesheet
    ADD CONSTRAINT stylesheet_pkey PRIMARY KEY (stylesheet_name);


--
-- Name: toolconfiguration_k; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY toolconfiguration
    ADD CONSTRAINT toolconfiguration_k UNIQUE (configurationvariable_id, jobtype_id, userclass_id);


--
-- Name: toolconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY toolconfiguration
    ADD CONSTRAINT toolconfiguration_pkey PRIMARY KEY (toolconfiguration_id);


--
-- Name: trna_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY trna
    ADD CONSTRAINT trna_pkey PRIMARY KEY (genomefeature_id);


--
-- Name: usecase_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY usecase
    ADD CONSTRAINT usecase_pkey PRIMARY KEY (usecase_id);


--
-- Name: usecase_usecase_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY usecase
    ADD CONSTRAINT usecase_usecase_name_key UNIQUE (usecase_name);


--
-- Name: userclass_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY userclass
    ADD CONSTRAINT userclass_pkey PRIMARY KEY (userclass_id);


--
-- Name: userclass_userclass_name_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY userclass
    ADD CONSTRAINT userclass_userclass_name_key UNIQUE (userclass_name);


--
-- Name: userclassconfiguration_k; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY userclassconfiguration
    ADD CONSTRAINT userclassconfiguration_k UNIQUE (configurationvariable_id, userclass_id);


--
-- Name: userclassconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY userclassconfiguration
    ADD CONSTRAINT userclassconfiguration_pkey PRIMARY KEY (userclassconfiguration_id);


--
-- Name: usergroup_party_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY usergroup
    ADD CONSTRAINT usergroup_party_id_key UNIQUE (party_id);


--
-- Name: usergroupemailinvitation_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY usergroupemailinvitation
    ADD CONSTRAINT usergroupemailinvitation_pkey PRIMARY KEY (usergroupemailinvitation_id);


--
-- Name: usergroupinvitation_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY usergroupinvitation
    ADD CONSTRAINT usergroupinvitation_pkey PRIMARY KEY (usergroupinvitation_id);


--
-- Name: userpipeline_pipeline_id_key; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY userpipeline
    ADD CONSTRAINT userpipeline_pipeline_id_key UNIQUE (pipeline_id);


--
-- Name: workflow_pkey; Type: CONSTRAINT; Schema: public; Owner: chemmeri; Tablespace: 
--

ALTER TABLE ONLY workflow
    ADD CONSTRAINT workflow_pkey PRIMARY KEY (workflow_id);


--
-- Name: account_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_party_id_fkey FOREIGN KEY (party_id) REFERENCES party(party_id);


--
-- Name: account_userclass_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY account
    ADD CONSTRAINT account_userclass_id_fkey FOREIGN KEY (userclass_id) REFERENCES userclass(userclass_id);


--
-- Name: accountnotification_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY accountnotification
    ADD CONSTRAINT accountnotification_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES notification(notification_id);


--
-- Name: accountnotification_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY accountnotification
    ADD CONSTRAINT accountnotification_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: accountrequest_accountrequeststatus_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY accountrequest
    ADD CONSTRAINT accountrequest_accountrequeststatus_name_fkey FOREIGN KEY (accountrequeststatus_name) REFERENCES accountrequeststatus(accountrequeststatus_name);


--
-- Name: cds_genomefeature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY cds
    ADD CONSTRAINT cds_genomefeature_id_fkey FOREIGN KEY (genomefeature_id) REFERENCES genomefeature(genomefeature_id);


--
-- Name: cds_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY cds
    ADD CONSTRAINT cds_parent_id_fkey FOREIGN KEY (cds_mrna) REFERENCES mrna(genomefeature_id);


--
-- Name: cluster_clusterinput_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY "cluster"
    ADD CONSTRAINT cluster_clusterinput_id_fkey FOREIGN KEY (clusterinput_id) REFERENCES clusterinput(clusterinput_id);


--
-- Name: clusterinput_clusterinput_dependency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusterinput
    ADD CONSTRAINT clusterinput_clusterinput_dependency_fkey FOREIGN KEY (clusterinput_dependency) REFERENCES inputdependency(inputdependency_name);


--
-- Name: clusterinput_clusterinput_ergatisformat_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusterinput
    ADD CONSTRAINT clusterinput_clusterinput_ergatisformat_fkey FOREIGN KEY (clusterinput_ergatisformat) REFERENCES ergatisformat(ergatisformat_name);


--
-- Name: clusterinput_fileformat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusterinput
    ADD CONSTRAINT clusterinput_fileformat_id_fkey FOREIGN KEY (fileformat_id) REFERENCES fileformat(fileformat_id);


--
-- Name: clusterinput_filetype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusterinput
    ADD CONSTRAINT clusterinput_filetype_id_fkey FOREIGN KEY (filetype_id) REFERENCES filetype(filetype_id);


--
-- Name: clusteroutput_clusteroutput_ergatisformat_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusteroutput
    ADD CONSTRAINT clusteroutput_clusteroutput_ergatisformat_fkey FOREIGN KEY (clusteroutput_ergatisformat) REFERENCES ergatisformat(ergatisformat_name);


--
-- Name: clusteroutput_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusteroutput
    ADD CONSTRAINT clusteroutput_component_id_fkey FOREIGN KEY (component_id) REFERENCES component(component_id);


--
-- Name: clusteroutput_fileformat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusteroutput
    ADD CONSTRAINT clusteroutput_fileformat_id_fkey FOREIGN KEY (fileformat_id) REFERENCES fileformat(fileformat_id);


--
-- Name: clusteroutput_filetype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusteroutput
    ADD CONSTRAINT clusteroutput_filetype_id_fkey FOREIGN KEY (filetype_id) REFERENCES filetype(filetype_id);


--
-- Name: clusteroutput_outputvisibility_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY clusteroutput
    ADD CONSTRAINT clusteroutput_outputvisibility_name_fkey FOREIGN KEY (outputvisibility_name) REFERENCES outputvisibility(outputvisibility_name);


--
-- Name: component_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES "cluster"(cluster_id);


--
-- Name: component_component_copyparametermask_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_component_copyparametermask_fkey FOREIGN KEY (component_copyparametermask) REFERENCES component(component_id);


--
-- Name: component_component_dependson_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_component_dependson_fkey FOREIGN KEY (component_dependson) REFERENCES component(component_id);


--
-- Name: component_componenttemplate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY component
    ADD CONSTRAINT component_componenttemplate_id_fkey FOREIGN KEY (componenttemplate_id) REFERENCES componenttemplate(componenttemplate_id);


--
-- Name: componentinputmap_clusterinput_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY componentinputmap
    ADD CONSTRAINT componentinputmap_clusterinput_id_fkey FOREIGN KEY (clusterinput_id) REFERENCES clusterinput(clusterinput_id);


--
-- Name: componentinputmap_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY componentinputmap
    ADD CONSTRAINT componentinputmap_component_id_fkey FOREIGN KEY (component_id) REFERENCES component(component_id);


--
-- Name: configurationvariable_configurationvariable_datatype_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY configurationvariable
    ADD CONSTRAINT configurationvariable_configurationvariable_datatype_fkey FOREIGN KEY (configurationvariable_datatype) REFERENCES datatype(datatype_name);


--
-- Name: configurationvariable_configurationvariable_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY configurationvariable
    ADD CONSTRAINT configurationvariable_configurationvariable_type_fkey FOREIGN KEY (configurationvariable_type) REFERENCES configurationtype(configurationtype_name);


--
-- Name: contig_genomefeature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY contig
    ADD CONSTRAINT contig_genomefeature_id_fkey FOREIGN KEY (genomefeature_id) REFERENCES genomefeature(genomefeature_id);


--
-- Name: contig_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY contig
    ADD CONSTRAINT contig_run_id_fkey FOREIGN KEY (run_id) REFERENCES run(run_id);


--
-- Name: contig_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY contig
    ADD CONSTRAINT contig_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES "sequence"(sequence_id);


--
-- Name: emailnotification_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY emailnotification
    ADD CONSTRAINT emailnotification_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES notification(notification_id);


--
-- Name: exref_exdb_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY exref
    ADD CONSTRAINT exref_exdb_id_fkey FOREIGN KEY (exdb_id) REFERENCES exdb(exdb_id);


--
-- Name: file_fileformat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_fileformat_id_fkey FOREIGN KEY (fileformat_id) REFERENCES fileformat(fileformat_id);


--
-- Name: file_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES fileresource(fileresource_id);


--
-- Name: file_filetype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_filetype_id_fkey FOREIGN KEY (filetype_id) REFERENCES filetype(filetype_id);


--
-- Name: fileaccess_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY fileaccess
    ADD CONSTRAINT fileaccess_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES fileresource(fileresource_id);


--
-- Name: fileaccess_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY fileaccess
    ADD CONSTRAINT fileaccess_party_id_fkey FOREIGN KEY (party_id) REFERENCES party(party_id);


--
-- Name: filecollection_filecollectiontype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY filecollection
    ADD CONSTRAINT filecollection_filecollectiontype_id_fkey FOREIGN KEY (filecollectiontype_id) REFERENCES filecollectiontype(filecollectiontype_id);


--
-- Name: filecollection_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY filecollection
    ADD CONSTRAINT filecollection_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES fileresource(fileresource_id);


--
-- Name: filecollectioncontent_filecollectioncontent_child_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY filecollectioncontent
    ADD CONSTRAINT filecollectioncontent_filecollectioncontent_child_fkey FOREIGN KEY (filecollectioncontent_child) REFERENCES fileresource(fileresource_id);


--
-- Name: filecollectioncontent_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY filecollectioncontent
    ADD CONSTRAINT filecollectioncontent_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES filecollection(fileresource_id);


--
-- Name: fileresource_fileresourcepartition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY fileresource
    ADD CONSTRAINT fileresource_fileresourcepartition_id_fkey FOREIGN KEY (fileresourcepartition_id) REFERENCES fileresourcepartition(fileresourcepartition_id);


--
-- Name: fileresource_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY fileresource
    ADD CONSTRAINT fileresource_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: gene_gene_contig_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY gene
    ADD CONSTRAINT gene_gene_contig_fkey FOREIGN KEY (gene_contig) REFERENCES contig(genomefeature_id);


--
-- Name: gene_gene_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY gene
    ADD CONSTRAINT gene_gene_type_fkey FOREIGN KEY (gene_type) REFERENCES genetype(genetype_name);


--
-- Name: gene_genomefeature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY gene
    ADD CONSTRAINT gene_genomefeature_id_fkey FOREIGN KEY (genomefeature_id) REFERENCES genomefeature(genomefeature_id);


--
-- Name: genomefeature_genomefeaturepartition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY genomefeature
    ADD CONSTRAINT genomefeature_genomefeaturepartition_id_fkey FOREIGN KEY (genomefeaturepartition_id) REFERENCES genomefeaturepartition(genomefeaturepartition_id);


--
-- Name: globalpipeline_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY globalpipeline
    ADD CONSTRAINT globalpipeline_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES pipeline(pipeline_id);


--
-- Name: groupmembership_accountgroup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY groupmembership
    ADD CONSTRAINT groupmembership_accountgroup_id_fkey FOREIGN KEY (accountgroup_id) REFERENCES accountgroup(accountgroup_id);


--
-- Name: groupmembership_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY groupmembership
    ADD CONSTRAINT groupmembership_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: grouppermission_accountgroup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY grouppermission
    ADD CONSTRAINT grouppermission_accountgroup_id_fkey FOREIGN KEY (accountgroup_id) REFERENCES accountgroup(accountgroup_id);


--
-- Name: grouppermission_usecase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY grouppermission
    ADD CONSTRAINT grouppermission_usecase_id_fkey FOREIGN KEY (usecase_id) REFERENCES usecase(usecase_id);


--
-- Name: job_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES filecollection(fileresource_id);


--
-- Name: job_job_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_job_status_fkey FOREIGN KEY (job_status) REFERENCES jobstatus(jobstatus_name);


--
-- Name: job_jobtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_jobtype_id_fkey FOREIGN KEY (jobtype_id) REFERENCES jobtype(jobtype_id);


--
-- Name: job_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY job
    ADD CONSTRAINT job_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: jobnotification_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY jobnotification
    ADD CONSTRAINT jobnotification_job_id_fkey FOREIGN KEY (job_id) REFERENCES job(job_id);


--
-- Name: jobnotification_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY jobnotification
    ADD CONSTRAINT jobnotification_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES notification(notification_id);


--
-- Name: jobnotification_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY jobnotification
    ADD CONSTRAINT jobnotification_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: mrna_genomefeature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY mrna
    ADD CONSTRAINT mrna_genomefeature_id_fkey FOREIGN KEY (genomefeature_id) REFERENCES genomefeature(genomefeature_id);


--
-- Name: mrna_mrna_ec_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY mrna
    ADD CONSTRAINT mrna_mrna_ec_fkey FOREIGN KEY (mrna_ec) REFERENCES exref(exref_id);


--
-- Name: mrna_mrna_genesymbolsource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY mrna
    ADD CONSTRAINT mrna_mrna_genesymbolsource_fkey FOREIGN KEY (mrna_genesymbolsource) REFERENCES exref(exref_id);


--
-- Name: mrna_mrna_tigrrole_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY mrna
    ADD CONSTRAINT mrna_mrna_tigrrole_fkey FOREIGN KEY (mrna_tigrrole) REFERENCES exref(exref_id);


--
-- Name: mrna_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY mrna
    ADD CONSTRAINT mrna_parent_id_fkey FOREIGN KEY (mrna_gene) REFERENCES gene(genomefeature_id);


--
-- Name: mrnaexref_exref_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY mrnaexref
    ADD CONSTRAINT mrnaexref_exref_id_fkey FOREIGN KEY (exref_id) REFERENCES exref(exref_id);


--
-- Name: mrnaexref_genomefeature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY mrnaexref
    ADD CONSTRAINT mrnaexref_genomefeature_id_fkey FOREIGN KEY (genomefeature_id) REFERENCES mrna(genomefeature_id);


--
-- Name: news_newstype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_newstype_id_fkey FOREIGN KEY (newstype_id) REFERENCES newstype(newstype_id);


--
-- Name: news_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: notification_notificationpartition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY notification
    ADD CONSTRAINT notification_notificationpartition_id_fkey FOREIGN KEY (notificationpartition_id, notificationtype_id) REFERENCES notificationtype(notificationpartition_id, notificationtype_id);


--
-- Name: notificationtype_notificationpartition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY notificationtype
    ADD CONSTRAINT notificationtype_notificationpartition_id_fkey FOREIGN KEY (notificationpartition_id) REFERENCES notificationpartition(notificationpartition_id);


--
-- Name: party_partypartition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_partypartition_id_fkey FOREIGN KEY (partypartition_id) REFERENCES partypartition(partypartition_id);


--
-- Name: party_partystatus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_partystatus_id_fkey FOREIGN KEY (partystatus_id) REFERENCES partystatus(partystatus_id);


--
-- Name: passwordchangerequest_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY passwordchangerequest
    ADD CONSTRAINT passwordchangerequest_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: pipeline_pipelinepartition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipeline
    ADD CONSTRAINT pipeline_pipelinepartition_id_fkey FOREIGN KEY (pipelinepartition_id) REFERENCES pipelinepartition(pipelinepartition_id);


--
-- Name: pipeline_pipelinestatus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipeline
    ADD CONSTRAINT pipeline_pipelinestatus_id_fkey FOREIGN KEY (pipelinestatus_id) REFERENCES pipelinestatus(pipelinestatus_id);


--
-- Name: pipelineaccess_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineaccess
    ADD CONSTRAINT pipelineaccess_party_id_fkey FOREIGN KEY (party_id) REFERENCES party(party_id);


--
-- Name: pipelineaccess_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineaccess
    ADD CONSTRAINT pipelineaccess_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES userpipeline(pipeline_id);


--
-- Name: pipelinebuilder_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelinebuilder
    ADD CONSTRAINT pipelinebuilder_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: pipelinebuilder_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelinebuilder
    ADD CONSTRAINT pipelinebuilder_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES pipeline(pipeline_id);


--
-- Name: pipelineconfiguration_configurationvariable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineconfiguration
    ADD CONSTRAINT pipelineconfiguration_configurationvariable_id_fkey FOREIGN KEY (configurationvariable_id) REFERENCES configurationvariable(configurationvariable_id);


--
-- Name: pipelineconfiguration_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineconfiguration
    ADD CONSTRAINT pipelineconfiguration_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES globalpipeline(pipeline_id);


--
-- Name: pipelineconfiguration_pipelineconfiguration_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineconfiguration
    ADD CONSTRAINT pipelineconfiguration_pipelineconfiguration_type_fkey FOREIGN KEY (pipelineconfiguration_type) REFERENCES configurationtype(configurationtype_name);


--
-- Name: pipelineconfiguration_userclass_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineconfiguration
    ADD CONSTRAINT pipelineconfiguration_userclass_id_fkey FOREIGN KEY (userclass_id) REFERENCES userclass(userclass_id);


--
-- Name: pipelineinput_clusterinput_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineinput
    ADD CONSTRAINT pipelineinput_clusterinput_id_fkey FOREIGN KEY (clusterinput_id) REFERENCES clusterinput(clusterinput_id);


--
-- Name: pipelineinput_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY pipelineinput
    ADD CONSTRAINT pipelineinput_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES pipeline(pipeline_id);


--
-- Name: rrna_genomefeature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY rrna
    ADD CONSTRAINT rrna_genomefeature_id_fkey FOREIGN KEY (genomefeature_id) REFERENCES genomefeature(genomefeature_id);


--
-- Name: rrna_rrna_gene_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY rrna
    ADD CONSTRAINT rrna_rrna_gene_fkey FOREIGN KEY (rrna_gene) REFERENCES gene(genomefeature_id);


--
-- Name: run_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES filecollection(fileresource_id);


--
-- Name: run_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: run_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES pipeline(pipeline_id);


--
-- Name: run_run_rawdatastatus_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_run_rawdatastatus_fkey FOREIGN KEY (run_rawdatastatus) REFERENCES rawdatastatus(rawdatastatus_name);


--
-- Name: run_runstatus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY run
    ADD CONSTRAINT run_runstatus_id_fkey FOREIGN KEY (runstatus_id) REFERENCES runstatus(runstatus_id);


--
-- Name: runaccess_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runaccess
    ADD CONSTRAINT runaccess_party_id_fkey FOREIGN KEY (party_id) REFERENCES party(party_id);


--
-- Name: runaccess_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runaccess
    ADD CONSTRAINT runaccess_run_id_fkey FOREIGN KEY (run_id) REFERENCES run(run_id);


--
-- Name: runbuilder_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runbuilder
    ADD CONSTRAINT runbuilder_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: runbuilder_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runbuilder
    ADD CONSTRAINT runbuilder_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES pipeline(pipeline_id);


--
-- Name: runbuilderinput_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runbuilderinput
    ADD CONSTRAINT runbuilderinput_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES fileresource(fileresource_id);


--
-- Name: runbuilderinput_pipelineinput_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runbuilderinput
    ADD CONSTRAINT runbuilderinput_pipelineinput_id_fkey FOREIGN KEY (pipelineinput_id) REFERENCES pipelineinput(pipelineinput_id);


--
-- Name: runbuilderinput_runbuilder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runbuilderinput
    ADD CONSTRAINT runbuilderinput_runbuilder_id_fkey FOREIGN KEY (runbuilder_id) REFERENCES runbuilder(runbuilder_id);


--
-- Name: runcancelation_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runcancelation
    ADD CONSTRAINT runcancelation_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: runcancelation_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runcancelation
    ADD CONSTRAINT runcancelation_run_id_fkey FOREIGN KEY (run_id) REFERENCES run(run_id);


--
-- Name: runcluster_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runcluster
    ADD CONSTRAINT runcluster_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES "cluster"(cluster_id);


--
-- Name: runcluster_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runcluster
    ADD CONSTRAINT runcluster_run_id_fkey FOREIGN KEY (run_id) REFERENCES run(run_id);


--
-- Name: runcluster_runstatus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runcluster
    ADD CONSTRAINT runcluster_runstatus_id_fkey FOREIGN KEY (runstatus_id) REFERENCES runstatus(runstatus_id);


--
-- Name: runinput_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runinput
    ADD CONSTRAINT runinput_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES fileresource(fileresource_id);


--
-- Name: runinput_pipelineinput_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runinput
    ADD CONSTRAINT runinput_pipelineinput_id_fkey FOREIGN KEY (pipelineinput_id) REFERENCES pipelineinput(pipelineinput_id);


--
-- Name: runinput_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runinput
    ADD CONSTRAINT runinput_run_id_fkey FOREIGN KEY (run_id) REFERENCES run(run_id);


--
-- Name: runnotification_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runnotification
    ADD CONSTRAINT runnotification_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES notification(notification_id);


--
-- Name: runnotification_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runnotification
    ADD CONSTRAINT runnotification_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: runnotification_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runnotification
    ADD CONSTRAINT runnotification_run_id_fkey FOREIGN KEY (run_id) REFERENCES run(run_id);


--
-- Name: runoutput_clusteroutput_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runoutput
    ADD CONSTRAINT runoutput_clusteroutput_id_fkey FOREIGN KEY (clusteroutput_id) REFERENCES clusteroutput(clusteroutput_id);


--
-- Name: runoutput_fileresource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runoutput
    ADD CONSTRAINT runoutput_fileresource_id_fkey FOREIGN KEY (fileresource_id) REFERENCES fileresource(fileresource_id);


--
-- Name: runoutput_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY runoutput
    ADD CONSTRAINT runoutput_run_id_fkey FOREIGN KEY (run_id) REFERENCES run(run_id);


--
-- Name: siteconfiguration_configurationvariable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY siteconfiguration
    ADD CONSTRAINT siteconfiguration_configurationvariable_id_fkey FOREIGN KEY (configurationvariable_id) REFERENCES configurationvariable(configurationvariable_id);


--
-- Name: siteconfiguration_configurationvariable_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY siteconfiguration
    ADD CONSTRAINT siteconfiguration_configurationvariable_id_fkey1 FOREIGN KEY (configurationvariable_id, siteconfiguration_type) REFERENCES configurationvariable(configurationvariable_id, configurationvariable_type);


--
-- Name: siteconfiguration_siteconfiguration_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY siteconfiguration
    ADD CONSTRAINT siteconfiguration_siteconfiguration_type_fkey FOREIGN KEY (siteconfiguration_type) REFERENCES configurationtype(configurationtype_name);


--
-- Name: toolconfiguration_configurationvariable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY toolconfiguration
    ADD CONSTRAINT toolconfiguration_configurationvariable_id_fkey FOREIGN KEY (configurationvariable_id) REFERENCES configurationvariable(configurationvariable_id);


--
-- Name: toolconfiguration_jobtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY toolconfiguration
    ADD CONSTRAINT toolconfiguration_jobtype_id_fkey FOREIGN KEY (jobtype_id) REFERENCES jobtype(jobtype_id);


--
-- Name: toolconfiguration_toolconfiguration_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY toolconfiguration
    ADD CONSTRAINT toolconfiguration_toolconfiguration_type_fkey FOREIGN KEY (toolconfiguration_type) REFERENCES configurationtype(configurationtype_name);


--
-- Name: toolconfiguration_userclass_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY toolconfiguration
    ADD CONSTRAINT toolconfiguration_userclass_id_fkey FOREIGN KEY (userclass_id) REFERENCES userclass(userclass_id);


--
-- Name: trna_genomefeature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY trna
    ADD CONSTRAINT trna_genomefeature_id_fkey FOREIGN KEY (genomefeature_id) REFERENCES genomefeature(genomefeature_id);


--
-- Name: trna_trna_gene_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY trna
    ADD CONSTRAINT trna_trna_gene_fkey FOREIGN KEY (trna_gene) REFERENCES gene(genomefeature_id);


--
-- Name: usecase_usecase_stylesheet_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usecase
    ADD CONSTRAINT usecase_usecase_stylesheet_fkey FOREIGN KEY (usecase_stylesheet) REFERENCES stylesheet(stylesheet_name);


--
-- Name: userclassconfiguration_configurationvariable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY userclassconfiguration
    ADD CONSTRAINT userclassconfiguration_configurationvariable_id_fkey FOREIGN KEY (configurationvariable_id) REFERENCES configurationvariable(configurationvariable_id);


--
-- Name: userclassconfiguration_userclass_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY userclassconfiguration
    ADD CONSTRAINT userclassconfiguration_userclass_id_fkey FOREIGN KEY (userclass_id) REFERENCES userclass(userclass_id);


--
-- Name: userclassconfiguration_userclassconfiguration_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY userclassconfiguration
    ADD CONSTRAINT userclassconfiguration_userclassconfiguration_type_fkey FOREIGN KEY (userclassconfiguration_type) REFERENCES configurationtype(configurationtype_name);


--
-- Name: usergroup_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usergroup
    ADD CONSTRAINT usergroup_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(party_id);


--
-- Name: usergroup_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usergroup
    ADD CONSTRAINT usergroup_party_id_fkey FOREIGN KEY (party_id) REFERENCES party(party_id);


--
-- Name: usergroupemailinvitation_usergroup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usergroupemailinvitation
    ADD CONSTRAINT usergroupemailinvitation_usergroup_id_fkey FOREIGN KEY (usergroup_id) REFERENCES usergroup(party_id);


--
-- Name: usergroupinvitation_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usergroupinvitation
    ADD CONSTRAINT usergroupinvitation_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: usergroupinvitation_usergroup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usergroupinvitation
    ADD CONSTRAINT usergroupinvitation_usergroup_id_fkey FOREIGN KEY (usergroup_id) REFERENCES usergroup(party_id);


--
-- Name: usergroupmembership_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usergroupmembership
    ADD CONSTRAINT usergroupmembership_account_id_fkey FOREIGN KEY (account_id) REFERENCES account(party_id);


--
-- Name: usergroupmembership_usergroup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY usergroupmembership
    ADD CONSTRAINT usergroupmembership_usergroup_id_fkey FOREIGN KEY (usergroup_id) REFERENCES usergroup(party_id);


--
-- Name: userpipeline_party_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY userpipeline
    ADD CONSTRAINT userpipeline_party_id_fkey FOREIGN KEY (party_id) REFERENCES account(party_id);


--
-- Name: userpipeline_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY userpipeline
    ADD CONSTRAINT userpipeline_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES pipeline(pipeline_id);


--
-- Name: userpipeline_userpipeline_template_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY userpipeline
    ADD CONSTRAINT userpipeline_userpipeline_template_fkey FOREIGN KEY (userpipeline_template) REFERENCES globalpipeline(pipeline_id);


--
-- Name: workflow_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY workflow
    ADD CONSTRAINT workflow_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES "cluster"(cluster_id);


--
-- Name: workflow_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY workflow
    ADD CONSTRAINT workflow_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES globalpipeline(pipeline_id);


--
-- Name: workflow_workflow_altcluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chemmeri
--

ALTER TABLE ONLY workflow
    ADD CONSTRAINT workflow_workflow_altcluster_id_fkey FOREIGN KEY (workflow_altcluster_id) REFERENCES "cluster"(cluster_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

