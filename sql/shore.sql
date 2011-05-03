-- File Info
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary ) VALUES ('FASTQ', 'fq', 'A FASTQ file.  Find description.', TRUE);

INSERT INTO filetype ( filetype_name, filetype_help )
  VALUES ( 'Illumina Sequencer Output', 'Output from an Illumina sequencing run.' );

INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary ) VALUES ('Shore SNP Output', 'xxx', 'SNP output from Shore.', FALSE);

INSERT INTO filetype ( filetype_name, filetype_help )
  VALUES ( 'SNP Analysis Output', 'Output containing SNP analysis information' );

--Assembler Pipeline
INSERT INTO pipeline ( pipelinepartition_id, pipeline_name, pipeline_description, pipelinestatus_id )
  VALUES ( ( SELECT pipelinepartition_id FROM pipelinepartition WHERE pipelinepartition_name = 'GlobalPipeline' ),
              'SNP Mapping Pipeline',
              '<p>A SNP mapping pipeline using the Shore software package.</p>',
           ( SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Available' )
 );

INSERT INTO globalpipeline ( pipeline_id, globalpipeline_subclass, globalpipeline_image, globalpipeline_layout )
  VALUES ( (SELECT CURRVAL('pipeline_pipeline_id_seq')), 'SNPMapping', '/include/img/snp_mapping.png',
'<commandSetRoot xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="commandSet.xsd" type="instance">
    <commandSet type="serial">
        <state>incomplete</state>
        <name>start</name>
        <commandSet type="serial">
            <state>incomplete</state>
           ___SNP Analysis___ 
        </commandSet>
    </commandSet>
</commandSetRoot>
'
 );

INSERT INTO clusterinput ( filetype_id, clusterinput_dependency, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue, clusterinput_hasparameters, clusterinput_isiterator)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Illumina Sequencer Output'),
    (SELECT inputdependency_name FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTQ'),
    'File', 'Shore_Input', '', FALSE, FALSE);

INSERT INTO clusterinput ( filetype_id, clusterinput_dependency, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue, clusterinput_hasparameters, clusterinput_isiterator)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Illumina Sequencer Output'),
    (SELECT inputdependency_name FROM inputdependency WHERE inputdependency_name = 'Optional'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTQ'),
    'File', 'Shore_Input_Pair', '', FALSE, FALSE);

INSERT INTO pipelineinput (clusterinput_id, pipeline_id)
  VALUES (
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Shore_Input'),
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'SNP Mapping Pipeline'));

INSERT INTO pipelineinput (clusterinput_id, pipeline_id)
  VALUES (
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Shore_Input_Pair'),
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'SNP Mapping Pipeline'));

--Cluster info
INSERT INTO cluster ( cluster_name, cluster_description, cluster_layoutxml ) VALUES ( 'SNP Analysis',
'The SNP Analysis cluster runs Shore against a reference genome to locate SNPs.',
' <commandSet type="serial">
    <state>incomplete</state>
    ___shore_illumina2flat.default___
    ___shore_mapflowcell.default___
    ___shore_correct4pe.default___
    ___shore_merge.default___
    ___shore_consensus.default___
    ___shore_coverage.default___
  </commandSet>
' );

-- Component Template
-- INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'shore_preprocess', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'shore_illumina2flat', 'shore_illumina2flat.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'shore_mapflowcell', 'shore_mapflowcell.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'shore_correct4pe', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'shore_merge', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'shore_consensus', 'shore_consensus.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'shore_coverage', '' );

-- Component info
INSERT INTO component ( component_name, component_ergatisname, component_index, cluster_id, componenttemplate_id )
  VALUES ( '', 'shore_illumina2flat.default', 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'SNP Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'shore_illumina2flat' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'shore_illumina2flat.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Shore_Input' ) );

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'shore_illumina2flat.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Shore_Input_Pair' ) );


INSERT INTO component ( component_name, component_ergatisname, component_index, cluster_id, componenttemplate_id )
  VALUES ( '', 'shore_mapflowcell.default', 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'SNP Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'shore_mapflowcell' ));

INSERT INTO component ( component_name, component_ergatisname, component_index, cluster_id, componenttemplate_id )
  VALUES ( '', 'shore_correct4pe.default', 3,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'SNP Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'shore_correct4pe' ));

INSERT INTO component ( component_name, component_ergatisname, component_index, cluster_id, componenttemplate_id )
  VALUES ( '', 'shore_merge.default', 4,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'SNP Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'shore_merge' ));

INSERT INTO component ( component_name, component_ergatisname, component_index, cluster_id, componenttemplate_id )
  VALUES ( '', 'shore_consensus.default', 5,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'SNP Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'shore_consensus' ));

INSERT INTO component ( component_name, component_ergatisname, component_index, cluster_id, componenttemplate_id )
  VALUES ( '', 'shore_coverage.default', 6,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'SNP Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'shore_coverage' ));


INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'shore_coverage.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'SNP Analysis Output'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Shore SNP Output'),
    'Directory', 'Evidence', 'shore_merge/___id____default/Analysis');

-- Workflow inserts
INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'SNP Mapping Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'SNP Analysis'), '96,0,374,141', TRUE);

-- Pipeline Configuration stuff
INSERT INTO pipelineconfiguration (configurationvariable_id, pipeline_id, pipelineconfiguration_type, pipelineconfiguration_value )
  VALUES(
    (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'pipeline_is_installed'),
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'SNP Mapping Pipeline'), 'PipelineConfiguration', TRUE);
