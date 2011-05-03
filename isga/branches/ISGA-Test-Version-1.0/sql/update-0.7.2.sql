SET SESSION client_min_messages TO 'warning';

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Expand job type table to partition job objects into subclasses
--------------------------------------------------------------------
--------------------------------------------------------------------
ALTER TABLE jobtype ADD COLUMN jobtype_class TEXT;
UPDATE jobtype SET jobtype_class = 'SysMicro::Job::BLAST' WHERE jobtype_name = 'Blast';
UPDATE jobtype SET jobtype_class = 'SysMicro::Job::MEME' WHERE jobtype_name = 'MEME';
UPDATE jobtype SET jobtype_class = 'SysMicro::Job::MSA' WHERE jobtype_name = 'MSA';
ALTER TABLE jobtype ALTER COLUMN jobtype_class SET NOT NULL;
ALTER TABLE job ADD COLUMN fileresource_id integer references filecollection(fileresource_id);


--------------------------------------------------------------------
--------------------------------------------------------------------
-- Collections to hold job files
--------------------------------------------------------------------
--------------------------------------------------------------------
INSERT INTO  filecollectiontype ( filecollectiontype_name, filecollectiontype_description, filecollectiontype_isuniform ) VALUES ( 'Job Files', 'Input, config, and output of a job', FALSE);

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Create new filecontent filetype and fileformats
--------------------------------------------------------------------
--------------------------------------------------------------------
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Toolbox Configuration', 'Setting used to run a Toolbox job.');

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Toolbox Job Configuration', 'Contains the settings used to perform a Toolbox job.',
   (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'RNA Curation Results' ));

INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('YAML', 'yaml', 'YAML is a human friendly data serialization standard for all programming languages.');

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add gene details usecase
--------------------------------------------------------------------
--------------------------------------------------------------------
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/GenomeFeature/View', TRUE, 'View Genome Feature Details', '2columnright' );

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add right menu to admin run list
--------------------------------------------------------------------
--------------------------------------------------------------------
UPDATE usecase SET usecase_stylesheet = '2columnright' WHERE usecase_name = '/Run/AdminList';

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add usecase for installing gbrowse data
--------------------------------------------------------------------
--------------------------------------------------------------------
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Run/InstallGbrowseData', 'Run::InstallGbrowseData', TRUE );

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add table for runtime variables
--------------------------------------------------------------------
--------------------------------------------------------------------
CREATE TABLE variable (
 variable_id SERIAL PRIMARY KEY,
 variable_name TEXT NOT NULL UNIQUE,
 variable_value TEXT NOT NULL
);

INSERT INTO variable ( variable_name, variable_value ) VALUES ( 'raw_data_retention', '30' );

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add tables for gene details
--------------------------------------------------------------------
--------------------------------------------------------------------
CREATE TABLE genomefeaturepartition (
  genomefeaturepartition_id SERIAL PRIMARY KEY,
  genomefeaturepartition_name TEXT NOT NULL UNIQUE,
  genomefeaturepartition_class TEXT NOT NULL
);

INSERT INTO genomefeaturepartition ( genomefeaturepartition_name, genomefeaturepartition_class ) VALUES ( 'mRNA', 'SysMicro::mRNA' );
INSERT INTO genomefeaturepartition ( genomefeaturepartition_name, genomefeaturepartition_class ) VALUES ( 'rRNA', 'SysMicro::rRNA' );
INSERT INTO genomefeaturepartition ( genomefeaturepartition_name, genomefeaturepartition_class ) VALUES ( 'CDS', 'SysMicro::CDS' );
INSERT INTO genomefeaturepartition ( genomefeaturepartition_name, genomefeaturepartition_class ) VALUES ( 'Gene', 'SysMicro::Gene' );
INSERT INTO genomefeaturepartition ( genomefeaturepartition_name, genomefeaturepartition_class ) VALUES ( 'tRNA', 'SysMicro::tRNA' );
INSERT INTO genomefeaturepartition ( genomefeaturepartition_name, genomefeaturepartition_class ) VALUES ( 'Contig', 'SysMicro::Contig' );

CREATE TABLE sequence (
  sequence_id SERIAL PRIMARY KEY,
  sequence_residues TEXT NOT NULL,
  sequence_md5checksum CHAR(32) NOT NULL,
  sequence_length INTEGER NOT NULL
);

CREATE TABLE genomefeature (
  genomefeature_id SERIAL PRIMARY KEY,
  genomefeaturepartition_id INTEGER REFERENCES genomefeaturepartition(genomefeaturepartition_id) NOT NULL,
  genomefeature_uniquename TEXT NOT NULL,
  genomefeature_start INTEGER NOT NULL,
  genomefeature_end INTEGER NOT NULL,
  genomefeature_strand CHAR(1)
);

CREATE TABLE contig (
  genomefeature_id INTEGER REFERENCES genomefeature(genomefeature_id) PRIMARY KEY,
  sequence_id INTEGER REFERENCES sequence(sequence_id) NOT NULL,
  run_id INTEGER REFERENCES run(run_id) NOT NULL
);

CREATE TABLE gene (
  genomefeature_id INTEGER REFERENCES genomefeature(genomefeature_id) PRIMARY KEY,
  gene_locus TEXT NOT NULL,
  gene_contig INTEGER REFERENCES contig(genomefeature_id) NOT NULL
);

CREATE TABLE exdb (
  exdb_id SERIAL PRIMARY KEY,
  exdb_name TEXT NOT NULL,
  exdb_baseuri TEXT NOT NULL
);

INSERT INTO exdb (exdb_name, exdb_baseuri) VALUES ('gene_symbol_source', 'http://cmr.jcvi.org/cgi-bin/CMR/HmmReport.cgi?hmm_acc=');
INSERT INTO exdb (exdb_name, exdb_baseuri) VALUES ('TIGR_role', 'http://cmr.jcvi.org/cgi-bin/CMR/RoleNotes.cgi?role_id=');
INSERT INTO exdb (exdb_name, exdb_baseuri) VALUES ('EC', 'http://www.genome.jp/dbget-bin/www_bget?ec:');
INSERT INTO exdb (exdb_name, exdb_baseuri) VALUES ('GO', 'http://amigo.geneontology.org/cgi-bin/amigo/term-details.cgi?term=');

CREATE TABLE exref (
  exref_id SERIAL PRIMARY KEY,
  exref_value TEXT NOT NULL,
  exdb_id INTEGER REFERENCES exdb(exdb_id) NOT NULL
);

CREATE TABLE mrna (
  genomefeature_id INTEGER REFERENCES genomefeature(genomefeature_id) PRIMARY KEY,
  mrna_genesymbol TEXT,
  mrna_geneproductnamesource TEXT,
  parent_id INTEGER REFERENCES gene(genomefeature_id) NOT NULL,
  mrna_genesymbolsource INTEGER REFERENCES exref(exref_id),
  mrna_note TEXT,
  mrna_tigrrole INTEGER REFERENCES exref(exref_id),
  mrna_ec INTEGER REFERENCES exref(exref_id)
);

CREATE TABLE cds (
  genomefeature_id INTEGER REFERENCES genomefeature(genomefeature_id) PRIMARY KEY,
  cds_topcoghit TEXT,
  parent_id INTEGER REFERENCES mrna(genomefeature_id)
);

CREATE TABLE rrna (
  genomefeature_id INTEGER REFERENCES genomefeature(genomefeature_id) PRIMARY KEY,
  rrna_note TEXT,
  rrna_score NUMERIC(8,2) NOT NULL,
  rrna_contig INTEGER REFERENCES contig(genomefeature_id) NOT NULL
);

CREATE TABLE trna (
  genomefeature_id INTEGER REFERENCES genomefeature(genomefeature_id) PRIMARY KEY,
  trna_note TEXT,
  trna_score NUMERIC(8,2) NOT NULL,
  trna_trnaanticodon CHAR(3) NOT NULL,
  trna_contig INTEGER REFERENCES contig(genomefeature_id) NOT NULL
);

CREATE TABLE mrnaexref (
  genomefeature_id INTEGER REFERENCES mrna(genomefeature_id) NOT NULL,
  exref_id INTEGER REFERENCES exref(exref_id) NOT NULL
);

CREATE OR REPLACE FUNCTION get_sequence_id (
	arg_sequence_residues TEXT,
	arg_sequence_md5checksum CHAR,
	arg_sequence_length INTEGER
) RETURNS INTEGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_exref_id (
	arg_exdb_name TEXT,
	arg_exref_value TEXT
) RETURNS INTEGER AS $$
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
$$ LANGUAGE plpgsql;


--------------------------------------------------------------------
--------------------------------------------------------------------
-- add side panel to run view
--------------------------------------------------------------------
--------------------------------------------------------------------

UPDATE usecase SET usecase_stylesheet = '2columnright' WHERE usecase_name = '/Run/View';

--------------------------------------------------------------------
--------------------------------------------------------------------
-- Kashi's WorkBench
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
     ___cgb_format.workbench_nuc___
     </commandSet>
     <commandSet type="serial">
      <state>incomplete</state>
      ___translate_sequence.workbench___
      ___join_multifasta.workbench___
      ___cgb_format.workbench_prot___
     </commandSet>
   </commandSet>
'
WHERE cluster_name = 'Predict Gene Function';

-- add componenttemplate
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'cgb_format', '' );

-- add component
INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'cgb_format.workbench_nuc', '', FALSE, FALSE, 13,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'cgb_format' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'cgb_format.workbench_prot', '', FALSE, FALSE, 14,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'cgb_format' ));

-- add usecase
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/MSA', TRUE, 'View MSA Results', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/ProtDist', TRUE, 'Phylogenetic Analysis', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/ProtPars', TRUE, 'Phylogenetic Analysis', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/ProtML', TRUE, 'Phylogenetic Analysis', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/DnaPars', TRUE, 'Phylogenetic Analysis', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/DnaDist', TRUE, 'Phylogenetic Analysis', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/DnaML', TRUE, 'Phylogenetic Analysis', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/ProtDist', TRUE, 'Phylogenetic Analysis Results', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/ProtPars', TRUE, 'Phylogenetic Analysis Results', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/ProtML', TRUE, 'Phylogenetic Analysis Results', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/DnaPars', TRUE, 'Phylogenetic Analysis Results', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/DnaDist', TRUE, 'Phylogenetic Analysis Results', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/WorkBench/Results/DnaML', TRUE, 'Phylogenetic Analysis Results', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/ProtDist', 'WorkBench::ProtDist', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/ProtPars', 'WorkBench::ProtPars', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/ProtML', 'WorkBench::ProtML', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/DnaDist', 'WorkBench::DnaDist', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/DnaPars', 'WorkBench::DnaPars', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/WorkBench/DnaML', 'WorkBench::DnaML', TRUE );

UPDATE usecase SET usecase_title = 'Toolbox Overview' WHERE usecase_name = '/WorkBench/Overview';

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add new alternate cluster, components, inputs and outputs
--------------------------------------------------------------------
--------------------------------------------------------------------
-- component template for geneprediction2bsml
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'geneprediction2bsml', '' );

-- Update gene prediction
UPDATE cluster SET cluster_layoutxml =
'___glimmer3.iter1___ 
___train_for_glimmer3_iteration.train_for_glimmer___
___glimmer3.iter2___' WHERE cluster_name = 'Gene Prediction';

-- Alternate Gene Prediction
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Alternate Gene Prediction', 'AlternateGenePrediction.yaml',
'Process user supplied gene prediction coordinate results to create necessary BSML files needed downstream in the pipeline.',
'___geneprediction2bsml.default___' );

-- Process Gene Prediction
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Process Gene Prediction', 'ProcessGenePrediction.yaml',
'Process gene prediction coordinate results to create all necessary files needed downstream in the pipeline.',
'<commandSet type="parallel">
 <state>incomplete</state>
 ___translate_sequence.translate_prediction___
 ___bsml2fasta.prediction_CDS___
</commandSet>
 ___promote_gene_prediction.promote_prediction___
 ___translate_sequence.translate___
 ___join_multifasta.gene_predict_translated___
' );

-- new Inputs/outputs for Gene Prediction Cluster
INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'glimmer3.iter2'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction Raw Evidence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'glimmer3/___id____iter2/glimmer3.bsml.list');


INSERT INTO clusterinput (filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction Raw Evidence'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Internal Only'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'Gene_Prediction',
    '$;REPOSITORY_ROOT$;/output_repository/glimmer3/$;PIPELINEID$;_iter2/glimmer3.bsml.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'translate_sequence.translate_prediction' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Gene_Prediction' ) );

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2fasta.prediction_CDS' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Gene_Prediction' ) );

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'promote_gene_prediction.promote_prediction' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Gene_Prediction' ) );


-- components, inputs, and outputs for new cluster

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'geneprediction2bsml.default', '', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'geneprediction2bsml' ));

INSERT INTO clusterinput (filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction Raw Evidence'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Glimmer3 Prediction Results'),
    'File',
    'Gene_Coords',
    '');
INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'geneprediction2bsml.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Gene_Coords' ) );

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'geneprediction2bsml.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

-- update components to new cluster
UPDATE component SET cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Gene Prediction' ), component_index = 1 
WHERE component_ergatisname = 'translate_sequence.translate_prediction';

UPDATE component SET cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Gene Prediction' ), component_index = 2
WHERE component_ergatisname = 'bsml2fasta.prediction_CDS';

UPDATE component SET cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Gene Prediction' ), component_index = 3 
WHERE component_ergatisname = 'promote_gene_prediction.promote_prediction';

UPDATE component SET cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Gene Prediction' ), component_index = 4 
WHERE component_ergatisname = 'translate_sequence.translate';

UPDATE component SET cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Gene Prediction' ), component_index = 5 
WHERE component_ergatisname = 'join_multifasta.gene_predict_translated'; 

-- alter Workflow table
ALTER TABLE workflow ADD workflow_altcluster_id INTEGER REFERENCES cluster(cluster_id);
ALTER TABLE workflow  ALTER COLUMN workflow_coordinates DROP NOT NULL;

-- insert new cluster into workflow
INSERT INTO workflow ( pipeline_id, cluster_id, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Gene Prediction'), TRUE);

UPDATE workflow SET workflow_altcluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Gene Prediction' )
WHERE cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' );

UPDATE globalpipeline SET globalpipeline_layout = '<commandSetRoot xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="commandSet.xsd" type="instance">
 <commandSet type="serial">
  <state>incomplete</state>
  ___Process Annotation Input Files___
  <commandSet type="parallel">
   <state>incomplete</state> 
   ___Additional Genome Analysis___
   <commandSet type="serial">
    <state>incomplete</state>
    <name>start pipeline:</name>
    ___Gene Prediction___
    ___Process Gene Prediction___
    <commandSet type="parallel">
     <state>incomplete</state>
     ___Protein Domain Search___
     <commandSet type="serial">
      <state>incomplete</state>
      ___Sequence Similarity Search___
      ___Alternate Start Site Analysis___
     </commandSet>
    </commandSet>
    ___Additional Gene Analysis___
    ___Predict Gene Function___ 
   </commandSet>
  </commandSet>
 </commandSet>
</commandSetRoot>'
WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline');

--------------------------------------------------------------------
--------------------------------------------------------------------
-- change pipeline name to Prokaryotic Annotation Pipeline 
--------------------------------------------------------------------
--------------------------------------------------------------------
-- update pipeline
UPDATE pipeline SET pipeline_name = 'Prokaryotic Annotation Pipeline' WHERE pipeline_name = 'Prokaryotic Annotation Pipeline';

--------------------------------------------------------------------
--------------------------------------------------------------------
-- change file name to Genome Sequence
--------------------------------------------------------------------
--------------------------------------------------------------------
-- update file
UPDATE filetype SET filetype_name = 'Genome Sequence' WHERE filetype_name = 'Assembled Genome Fasta';

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add page for combined Inputs and Outputs
--------------------------------------------------------------------
--------------------------------------------------------------------

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewInputsOutputs', FALSE, 'View Pipeline Inputs and Outputs', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ViewInputsOutputs', FALSE, 'View Pipeline Inputs and Outputs', '2columnright' );

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add 'Process Annotation Input Files' to the pipeline properly
--------------------------------------------------------------------
--------------------------------------------------------------------

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Annotation Input Files'), TRUE);

--------------------------------------------------------------------
--------------------------------------------------------------------
-- add 'Process Annotation Input Files' to the pipeline properly
--------------------------------------------------------------------
--------------------------------------------------------------------

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title ) VALUES ( '/sample_data.fna', FALSE, 'Sample Data');
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title ) VALUES ( '/sample_data.predict', FALSE, 'Sample Data');

--------------------------------------------------------------------
--------------------------------------------------------------------
-- delete unneeded usecases
--------------------------------------------------------------------
--------------------------------------------------------------------

DELETE FROM usecase WHERE usecase_name = '/RunBuilder/UploadFile';
DELETE FROM usecase WHERE usecase_name = '/submit/RunBuilder/UploadFile';


--------------------------------------------------------------------
--------------------------------------------------------------------
-- remove TargetP
--------------------------------------------------------------------
--------------------------------------------------------------------

-- update layoutxml
UPDATE cluster SET cluster_layoutxml =
'  <commandSet type="parallel">
     <state>incomplete</state>
     <commandSet type="serial">
       <state>incomplete</state>
       ___bsml2interevidence_fasta.default___
       ___split_multifasta.split_interevidence_regions___
       ___ncbi-blastx.blast_interevidence_regions___
     </commandSet>
     <commandSet type="serial">
       <state>incomplete</state>
       ___lipop.default___
       ___parse_evidence.lipoprotein___
     </commandSet>
     <commandSet type="serial">
       <state>incomplete</state>
       ___signalp.default___
     </commandSet>
     ___ps_scan.default___
     ___wu-blastp.COGS___
     <commandSet type="serial">
       <state>incomplete</state>
       ___tmhmm.default___
       ___parse_evidence.tmhmm___
     </commandSet>
     ___transterm.default___
     <commandSet type="serial">
       <state>incomplete</state>
       ___rpsblast.priam___
       ___priam_ec_assignment.default___
       ___parse_evidence.priam_ec___
     </commandSet>
     <commandSet type="serial">
       <state>incomplete</state>
       ___bsml2fasta.oligopicker___
       ___oligopicker.default___
     </commandSet>
     <commandSet type="serial">
       <state>incomplete</state>
       <commandSet type="parallel">
         <state>incomplete</state>
         ___join_multifasta.asgard___
         ___ncbi-blastp.asgard___
       </commandSet>
       ___asgard_simple.default___
     </commandSet>
   </commandSet>
 '
WHERE cluster_name = 'Additional Gene Analysis';

DELETE FROM componentinputmap WHERE component_id = (SELECT component_id FROM component WHERE component_ergatisname = 'targetp.default' );
DELETE FROM clusteroutput WHERE component_id = (SELECT component_id FROM component WHERE component_ergatisname = 'targetp.default' );
DELETE FROM  component WHERE component_name = 'TargetP';


--------------------------------------------------------------------
--------------------------------------------------------------------
-- Add cluster TFBS Search
--------------------------------------------------------------------
--------------------------------------------------------------------
-- Add File and Dictionary info
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Mast Raw Result', 'xxx', ' MAST outputs a file containing: the version of MAST and the date it was built, the reference to cite if you use MAST in your research, a description of the database and motifs used in the search, an explanation of the result, high-scoring sequences--sequences matching the group of motifs above a stated level of statistical significance,  motif diagrams showing the order and spacing of occurrences of the motifs in the high-scoring sequences and,  annotated sequences showing the positions and p-values of all motif occurrences in each of the high-scoring sequences.
');

INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('TFBS Motif Predictions', 'Predicted TFBS results produced by searching promoter regions against curated motifs using a program such as Mast.');

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'TFBS Evidence', 'Collected evidence of TFBS',
   (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'TFBS Motif Predictions' ));


-- TFBS Search
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'TFBS Search', 'TFBSSearch.yaml',
'The TFBS search cluster uses <a class="normal" href="http://www.ncbi.nlm.nih.gov/pubmed/9520501">Mast</a> to perfom a motif search against promoter regions of predicted ORFs using motifs from <a href="http://www.ncbi.nlm.nih.gov/pubmed/17142223">RegTransBase</a>.  The output is the raw Mast result in text format.',
' <commandSet type="serial">
   <state>incomplete</state>
   ___bsml2promoterregion.default___
   ___mast.default___
  </commandSet>
' );

-- Add component templates
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'bsml2promoterregion', 'mast.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'mast', '' );

-- Add components and cluster inputs and cluster outputs
INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'bsml2promoterregion.default', 'Extract Promoters for TFBS Search', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'TFBS Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2promoterregion' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2promoterregion.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Gene_Prediction' ) );

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'mast.default', '', FALSE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'TFBS Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'mast' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'mast.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TFBS Evidence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Mast Raw Result'),
    'File List', 'Evidence', 'mast/___id____default/mast.raw.list');

-- update global pipeline
UPDATE globalpipeline SET globalpipeline_layout = '<commandSetRoot xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="commandSet.xsd" type="instance">
 <commandSet type="serial">
  <state>incomplete</state>
  ___Process Annotation Input Files___
  <commandSet type="parallel">
   <state>incomplete</state> 
   ___Additional Genome Analysis___
   <commandSet type="serial">
    <state>incomplete</state>
    <name>start pipeline:</name>
    ___Gene Prediction___
    ___Process Gene Prediction___
    <commandSet type="parallel">
     <state>incomplete</state>
     ___Protein Domain Search___
     <commandSet type="serial">
      <state>incomplete</state>
      ___Sequence Similarity Search___
      ___Alternate Start Site Analysis___
     </commandSet>
      ___TFBS Search___
    </commandSet>
    ___Additional Gene Analysis___
    ___Predict Gene Function___ 
   </commandSet>
  </commandSet>
 </commandSet>
</commandSetRoot>'
WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline');

-- insert into Workflow

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'TFBS Search'), '0, 213, 111, 267', FALSE);

UPDATE workflow SET workflow_coordinates = '156, 100, 295, 153' WHERE pipeline_id = 
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline') 
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction');

UPDATE workflow SET workflow_coordinates = '314, 231, 608, 365' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline') 
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis');

UPDATE workflow SET workflow_coordinates = '125, 235, 275, 288' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Protein Domain Search');

UPDATE workflow SET workflow_coordinates = '244, 162, 410, 215' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search');

UPDATE workflow SET workflow_coordinates = '476, 100, 616, 181' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Genome Analysis');

UPDATE workflow SET workflow_coordinates = '309, 438, 534, 543' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function');

UPDATE workflow SET workflow_coordinates = '308, 0, 484, 53' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Annotation Input Files');

UPDATE workflow SET workflow_coordinates = '' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis');

