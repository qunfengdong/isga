-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Genome Assembly', 'GenomeAssembly.yaml', ' ' );


-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Gene Prediction', 'GenePrediction.yaml', 
'           <commandSet type="serial">
               <state>incomplete</state>
               <name>split_multifasta.default</name>
            </commandSet>
            <commandSet type="serial">
                <state>incomplete</state>
                <commandSet type="serial">
                    <state>incomplete</state>
                    <name>glimmer3.iter1</name>
                </commandSet>
                <commandSet type="serial">
                    <state>incomplete</state>
                    <name>train_for_glimmer3_iteration.train_for_glimmer</name>
                </commandSet>
                <commandSet type="serial">
                    <state>incomplete</state>
                    <name>glimmer3.iter2</name>
                </commandSet>
                <commandSet type="parallel">
                    <state>incomplete</state>
                    <commandSet type="serial">
                        <state>incomplete</state>
                        <name>translate_sequence.translate_prediction</name>
                    </commandSet>
                    <commandSet type="serial">
                        <state>incomplete</state>
                        <name>bsml2fasta.prediction_CDS</name>
                    </commandSet>
                </commandSet>
                <commandSet type="serial">
                    <state>incomplete</state>
                    <name>promote_gene_prediction.promote_prediction</name>
                </commandSet>
            </commandSet>
            <commandSet type="serial">
                <state>incomplete</state>
                <name>translate_sequence.translate</name>
            </commandSet>
            <commandSet type="serial">
                <state>incomplete</state>
                <name>join_multifasta.gene_predict_translated</name>
            </commandSet>
' );

INSERT INTO clusterinput (cluster_id, filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue) 
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Assembled Genome Fasta'), 
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File',
    'GENE_PREDICTION_INPUT', 
    ' ');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Glimmer3 Prediction Results'),
    'File List', TRUE, 'glimmer3/___id____iter2/glimmer3.raw.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc) 
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Detailed ORF Prediction'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Glimmer3 Detailed Results'),
    'File List', FALSE, 'glimmer3/___id____iter2/glimmer3.raw.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List', TRUE, 'bsml2fasta/___id____prediction_CDS/bsml2fasta.fsa.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Translated ORF Prediction'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List', TRUE, 'join_multifasta/___id____gene_predict_translated/join_multifasta.fsa.list');

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Genome Analysis', 'GenomeAnalysis.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Gene Curation', 'GeneCuration.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'HMM Search', 'HMMSearch.yaml', 
'            <commandSet type="serial">
                <state>incomplete</state>
                <name>hmmpfam.pre_overlap_analysis</name>
            </commandSet>
' );

INSERT INTO clusterinput (cluster_id, filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List',
    'HMM_Search_Input',
    '$;REPOSITORY_ROOT$;/output_repository/translate_sequence/$;PIPELINEID$;_translate/translate_sequence.fsa.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'HMM Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'HMMPFAM Raw Results'),
    'File List', TRUE, 'hmmpfam/___id____pre_overlap_analysis/hmmpfam.raw.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'HMM Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', FALSE, 'hmmpfam/___id____pre_overlap_analysis/hmmpfam.bsml.list');

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'BLAST Search', 'BlastSearch.yaml', 
'            <commandSet type="serial">
                <state>incomplete</state>
                <commandSet type="parallel">
                    <state>incomplete</state>
                    <commandSet type="serial">
                        <state>incomplete</state>
                        <name>wu-blastp.pre_overlap_analysis</name>
                    </commandSet>
                    <commandSet type="serial">
                        <state>incomplete</state>
                        <commandSet type="serial">
                            <state>incomplete</state>
                            <name>bsml2fasta.pre_overlap_analysis</name>
                        </commandSet>
                        <commandSet type="serial">
                            <state>incomplete</state>
                            <name>xdformat.pre_overlap_analysis</name>
                        </commandSet>
                    </commandSet>
                    <commandSet type="serial">
                        <state>incomplete</state>
                        <name>bsml2featurerelationships.pre_overlap_analysis</name>
                    </commandSet>
                </commandSet>
                <commandSet type="serial">
                    <state>incomplete</state>
                    <name>ber.pre_overlap_analysis</name>
                </commandSet>
            </commandSet>
' );

INSERT INTO clusterinput (cluster_id, filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List',
    'BLAST_Search_Iput',
    '$;REPOSITORY_ROOT$;/output_repository/translate_sequence/$;PIPELINEID$;_translate/translate_sequence.fsa.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BLAST Raw Results'),
    'File List', TRUE, 'wu-blastp/___id____pre_overlap_analysis/wu-blastp.raw.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BER Raw Results'),
    'File List', TRUE, 'ber/___id____pre_overlap_analysis/ber.raw.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BTAB'),
    'File List', TRUE, 'ber/___id____pre_overlap_analysis/ber.btab.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', FALSE, 'ber/___id____pre_overlap_analysis/ber.bsml.list');

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Gene Analysis', 'GeneAnalysis.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Predict Gene Function', 'PredictGeneFunction.yaml', 
'                                <commandSet type="serial">
                                    <state>incomplete</state>
                                    <name>predict_prokaryotic_gene_function.default</name>
                                </commandSet>
                                <commandSet type="serial">
                                    <state>incomplete</state>
                                    <name>pipeline_summary.default</name>
                                </commandSet>
                                <commandSet type="serial">
                                    <state>incomplete</state>
                                    <name>bsml2tbl.default</name>
                                </commandSet>
' );

INSERT INTO clusterinput (cluster_id, filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Auto-Gene Curation  Result'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Internal Only'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'Predict_Gene_Function',
    '$;REPOSITORY_ROOT$;/output_repository/promote_gene_prediction/$;PIPELINEID$;_promote_prediction/promote_gene_prediction.bsml.list');
--True Default    $;REPOSITORY_ROOT$;/output_repository/auto_gene_curation/$;PIPELINEID$;_overlap_analysis/auto_gene_curation.bsml.list.all

INSERT INTO clusterinput (cluster_id, filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'HMM Search Result'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Optional'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'HMM_Result',
    '$;REPOSITORY_ROOT$;/output_repository/hmmpfam/$;PIPELINEID$;_pre_overlap_analysis/hmmpfam.bsml.list');

INSERT INTO clusterinput (cluster_id, filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Optional'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'BER_Result',
    ' ');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Predict Gene Function Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', FALSE, 'predict_prokaryotic_gene_function/___id____default/predict_prokaryotic_gene_function.bsml.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Pipeline Summary'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', FALSE, 'pipeline_summary/___id____default/pipeline_summary.bsml.list');

INSERT INTO clusteroutput (cluster_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, clusteroutput_ispipelineoutput, clusteroutput_fileloc)
  VALUES (
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Pipeline Summary'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Table'),
    'File List', TRUE, 'bsml2tbl/___id____default/bsml2tbl.bsml.list');

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Pathway & GO Analysis', 'PathwayAndGOAnalysis.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Terminator Motif Finder', 'TerminatorMotifFinder.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'RNA Motif Finder', 'RNAMotifFinder.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Intergenic Region Extraction', 'IntergenicRegionExtraction.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'Noncoding RNA Finder', 'NoncodingRNAFinder.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'RNA BLAST Conservation', 'RNABlastConservation.yaml', ' ' );

-- cluster
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_layoutxml ) VALUES ( 'sRNA Prediction', 'sRNAPrediction.yaml', ' ' );
