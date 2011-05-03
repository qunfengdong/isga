-- gene prediction

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'split_multifasta.default', '', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Annotation Input Files' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'split_multifasta' ));

INSERT INTO clusterinput (filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue) 
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Assembled Genome Fasta'), 
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List',
    'Genome_Contigs', 
    '');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'split_multifasta.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'glimmer3.iter1', 'Glimmer3 First Pass', FALSE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'glimmer3' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'glimmer3.iter1' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'train_for_glimmer3_iteration.train_for_glimmer', '', FALSE, FALSE, 3,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'train_for_glimmer3_iteration' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'train_for_glimmer3_iteration.train_for_glimmer' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'glimmer3.iter2', 'Glimmer3 Refinement Pass', FALSE, FALSE, 4,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'glimmer3' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'glimmer3.iter2' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'glimmer3.iter2'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction Raw Evidence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Glimmer3 Prediction Results'),
    'File List', 'Intermediate', 'glimmer3/___id____iter2/glimmer3.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc) 
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'glimmer3.iter2'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction Raw Evidence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Glimmer3 Detailed Results'),
    'File List', 'Internal', 'glimmer3/___id____iter2/glimmer3.raw.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'translate_sequence.translate_prediction', '', FALSE, FALSE, 5,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'translate_sequence' ));
INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'bsml2fasta.prediction_CDS', '', FALSE, FALSE, 6, 
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2fasta' ));
INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'promote_gene_prediction.promote_prediction', '', FALSE, FALSE, 7, 
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'promote_gene_prediction' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'promote_gene_prediction.promote_prediction'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Promote Gene Prediction Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Intermediate', 'promote_gene_prediction/___id____promote_prediction/promote_gene_prediction.bsml.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'promote_gene_prediction.promote_prediction'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Sequence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List', 'Intermediate', 'bsml2fasta/___id____prediction_CDS/bsml2fasta.fsa.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'translate_sequence.translate', '', FALSE, FALSE, 8, 
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'translate_sequence' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'translate_sequence.translate'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Translated ORF Sequence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List', 'Intermediate', 'join_multifasta/___id____gene_predict_translated/join_multifasta.fsa.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'join_multifasta.gene_predict_translated', '', FALSE, FALSE, 9, 
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'join_multifasta' ));

-- protein domain search

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'hmmpfam.pre_overlap_analysis', 'HMMPfam Analysis', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Protein Domain Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'hmmpfam' ));

INSERT INTO clusterinput ( filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Translated ORF Sequence'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List',
    'HMM_Search_Input',
    '$;REPOSITORY_ROOT$;/output_repository/translate_sequence/$;PIPELINEID$;_translate/translate_sequence.fsa.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.pre_overlap_analysis' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'HMM_Search_Input' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.pre_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'HMM Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'HMMPFAM Raw Results'),
    'File List', 'Intermediate', 'hmmpfam/___id____pre_overlap_analysis/hmmpfam.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.pre_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'HMM Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'hmmpfam/___id____pre_overlap_analysis/hmmpfam.bsml.list');

-- sequence similarity search

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'wu-blastp.pre_overlap_analysis', 'BLASTP Analysis', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'wu-blastp' ));

INSERT INTO clusterinput ( filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Translated ORF Sequence'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List',
    'BLAST_Search_Input',
    '$;REPOSITORY_ROOT$;/output_repository/translate_sequence/$;PIPELINEID$;_translate/translate_sequence.fsa.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'BLAST_Search_Input' ) );

--INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
--  VALUES (
--    (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'),
--    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Search Result'),
--    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BLAST Raw Results'),
--    'File List', 'Intermediate', 'wu-blastp/___id____pre_overlap_analysis/wu-blastp.raw.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'bsml2fasta.pre_overlap_analysis', '', FALSE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2fasta' ));

INSERT INTO clusterinput (filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Promote Gene Prediction Result'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'Promote_Gene_Input',
    '$;REPOSITORY_ROOT$;/output_repository/promote_gene_prediction/$;PIPELINEID$;_promote_prediction/promote_gene_prediction.bsml.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2fasta.pre_overlap_analysis' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Promote_Gene_Input' ) );

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'xdformat.pre_overlap_analysis', '', FALSE, FALSE, 3,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'xdformat' ));
INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) VALUES ( 'bsml2featurerelationships.pre_overlap_analysis', '', FALSE, FALSE, 0,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2featurerelationships' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2featurerelationships.pre_overlap_analysis' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Promote_Gene_Input' ) );

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'ber.pre_overlap_analysis', 'BER Analysis', FALSE, FALSE, 4,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'ber' ));

--INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
--  VALUES (
--    (SELECT component_id FROM component WHERE component_ergatisname = 'ber.pre_overlap_analysis'),
--    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
--    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BER Raw Results'),
--    'File List', 'Intermediate', 'ber/___id____pre_overlap_analysis/ber.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ber.pre_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BTAB'),
    'File List', 'Intermediate', 'ber/___id____pre_overlap_analysis/ber.btab.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ber.pre_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'ber/___id____pre_overlap_analysis/ber.bsml.list');


-- Alternate Start Site Analysis

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'start_site_curation.default', '', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'start_site_curation' ));

INSERT INTO clusterinput ( filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Promote Gene Prediction Result'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'Start_Site_Input',
    '$;REPOSITORY_ROOT$;/output_repository/promote_gene_prediction/$;PIPELINEID$;_promote_prediction/promote_gene_prediction.bsml.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'start_site_curation.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Start_Site_Input' ) );

INSERT INTO clusterinput ( filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'Start_Site_BER_Input',
    '$;REPOSITORY_ROOT$;/output_repository/ber/$;PIPELINEID$;_pre_overlap_analysis/ber.bsml.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'start_site_curation.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Start_Site_BER_Input' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'start_site_curation.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Start Site Curation Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'start_site_curation/___id____default/start_site_curation.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id) 
  VALUES ( 'parse_evidence.hypothetical', '', FALSE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'translate_sequence.translate_new_models', '', FALSE, FALSE, 3,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'translate_sequence' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'hmmpfam.post_overlap_analysis', 'HMMPfam Alternate Start Site Analysis', FALSE, FALSE, 4,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'hmmpfam' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.pre_overlap_analysis'));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.post_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'HMM Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'HMMPFAM Raw Results'),
    'File List', 'Intermediate', 'hmmpfam/___id____post_overlap_analysis/hmmpfam.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.post_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'HMM Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'hmmpfam/___id____post_overlap_analysis/hmmpfam.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'parse_evidence.hmmpfam_post', '', FALSE, FALSE, 5,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.pre_overlap_analysis'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'wu-blastp.post_overlap_analysis', 'BLASTP Alternate Start Site Analysis', FALSE, FALSE, 6,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'wu-blastp' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'));

--INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
--  VALUES (
--    (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.post_overlap_analysis'),
--    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Search Result'),
--    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BLAST Raw Results'),
--    'File List', 'Intermediate', 'wu-blastp/___id____post_overlap_analysis/wu-blastp.raw.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'bsml2fasta.post_overlap_analysis', '', FALSE, FALSE, 7,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2fasta' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'xdformat.post_overlap_analysis', '', FALSE, FALSE, 8,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'xdformat' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'bsml2featurerelationships.post_overlap_analysis', '', FALSE, FALSE, 9,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2featurerelationships' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'ber.post_overlap_analysis', 'BER Alternate Start Site Analysis', FALSE, FALSE, 10,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'ber' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ber.post_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BER Raw Results'),
    'File List', 'Intermediate', 'ber/___id____post_overlap_analysis/ber.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ber.post_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BTAB'),
    'File List', 'Intermediate', 'ber/___id____post_overlap_analysis/ber.btab.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ber.post_overlap_analysis'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BER Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'ber/___id____post_overlap_analysis/ber.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'parse_evidence.ber_post', '', FALSE, FALSE, 11,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id) 
  VALUES ( 'translate_sequence.final_polypeptides', '', FALSE, FALSE, 12,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'translate_sequence' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'translate_sequence.final_polypeptides'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Translated ORF Sequence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'translate_sequence//___id____final_polypeptides/translate_sequence.fsa.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id) 
  VALUES ( 'bsml2fasta.final_cds', '', FALSE, FALSE, 13,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis' ), 
  ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2fasta' ));

-- Additional Genome Analysis

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'RNAmmer.default', 'RNAmmer', TRUE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Genome Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'RNAmmer' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'RNAmmer.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'RNAmmer.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'RNAmmer Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'RNAmmer HMM report'),
    'File List', 'Intermediate', 'RNAmmer/___id____default/RNAmmer.hmmreport.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'RNAmmer.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'RNAmmer Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'GFF'),
    'File List', 'Intermediate', 'RNAmmer/___id____default/RNAmmer.gff.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'RNAmmer.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'RNAmmer Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'RNAmmer/___id____default/RNAmmer.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'tRNAscan-SE.find_tRNA', 'tRNAscan-SE', TRUE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Genome Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'tRNAscan' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'tRNAscan-SE.find_tRNA' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'tRNAscan-SE.find_tRNA'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'tRNAscan Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'tRNAscan Raw Result'),
    'File List', 'Intermediate', 'tRNAscan-SE/___id____find_tRNA/tRNAscan-SE.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'tRNAscan-SE.find_tRNA'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'tRNAscan Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Intermediate', 'tRNAscan-SE/___id____find_tRNA/tRNAscan-SE.bsml.list');

-- Additional Gene Analysis

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'signalp.default', 'SignalP', TRUE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'signalp' ));

INSERT INTO clusterinput ( filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Translated ORF Sequence'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List',
    'FULL_TRANSLATED_LIST',
    '$;REPOSITORY_ROOT$;/output_repository/translate_sequence/$;PIPELINEID$;_final_polypeptides/translate_sequence.fsa.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'signalp.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'FULL_TRANSLATED_LIST' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'signalp.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'SignalP Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'SignalP Raw Result'),
    'File List', 'Intermediate', 'signalp/___id____default/signalp.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'signalp.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'SignalP Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'GIF'),
    'File List', 'Intermediate', 'signalp/___id____default/signalp.gif.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'signalp.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'SignalP Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'EPS'),
    'File List', 'Intermediate', 'signalp/___id____default/signalp.eps.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'signalp.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'SignalP Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'GNUPlot Commands Script'),
    'File List', 'Intermediate', 'signalp/___id____default/signalp.gnu.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'signalp.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'SignalP Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'signalp/___id____default/signalp.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'targetp.default', 'TargetP', TRUE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'targetp' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'targetp.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'FULL_TRANSLATED_LIST' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'targetp.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TargetP Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'TargetP Raw Result'),
    'File List', 'Intermediate', 'targetp/___id____default/targetp.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'targetp.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TargetP Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'targetp/___id____default/targetp.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'tmhmm.default', 'TMhmm', TRUE, FALSE, 3,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'tmhmm' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'tmhmm.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'FULL_TRANSLATED_LIST' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'tmhmm.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TMhmm Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'TMhmm Raw Result'),
    'File List', 'Intermediate', 'tmhmm/___id____default/tmhmm.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'tmhmm.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TMhmm Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'tmhmm/___id____default/tmhmm.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'parse_evidence.tmhmm', '', FALSE, FALSE, 4,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'tmhmm.default'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'ps_scan.default', 'Prosite Scan', TRUE, FALSE, 5,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'ps_scan' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ps_scan.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'FULL_TRANSLATED_LIST' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ps_scan.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Prosite Scan Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Prosite Scan Raw Result'),
    'File List', 'Intermediate', 'ps_scan/___id____default/ps_scan.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'ps_scan.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Prosite Scan Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'ps_scan/___id____default/ps_scan.bsml.list');


INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'transterm.default', 'TransTerm', TRUE, FALSE, 6,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'transterm' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'transterm.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Genome_Contigs' ) );

INSERT INTO clusterinput (filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue) 
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'ORF Prediction Raw Evidence'), 
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Glimmer3 Prediction Results'),
    'File',
    'TransTerm_COORD_Input', 
    '$;REPOSITORY_ROOT$;/output_repository/glimmer3/$;PIPELINEID$;_iter2/glimmer3.raw.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'transterm.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'TransTerm_COORD_Input' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'transterm.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TransTerm Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'TransTerm Raw Result'),
    'File List', 'Intermediate', 'transterm/___id____default/transterm.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'transterm.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TransTerm Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'transterm/___id____default/transterm.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'lipoprotein_motif.default', 'Lipoprotein Motif Discovery', TRUE, FALSE, 7,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'lipoprotein_motif' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'lipoprotein_motif.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'FULL_TRANSLATED_LIST' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'lipoprotein_motif.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Lipoprotein Motif Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'lipoprotein_motif/___id____default/lipoprotein_motif.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'parse_evidence.lipoprotein', '', FALSE, FALSE, 8,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'lipoprotein_motif.default'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'rpsblast.priam', 'Priam rpsblast', TRUE, FALSE, 9,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'rpsblast' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'rpsblast.priam' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'FULL_TRANSLATED_LIST' ) );

--INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
--  VALUES (
--    (SELECT component_id FROM component WHERE component_ergatisname = 'rpsblast.priam'),
--    (SELECT filetype_id FROM filetype WHERE filetype_name = 'RPSBLAST Result'),
--    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'RPSBLAST Raw Result'),
--    'File List', 'Intermediate', 'rpsblast/___id____priam/rpsblast.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'rpsblast.priam'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'RPSBLAST Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BTAB'),
    'File List', 'Intermediate', 'rpsblast/___id____priam/rpsblast.btab.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'rpsblast.priam'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'RPSBLAST Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'rpsblast/___id____priam/rpsblast.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson )
  VALUES ( 'priam_ec_assignment.default', 'Priam EC Assignment', TRUE, FALSE, 10,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'priam_ec_assignment' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'rpsblast.priam'));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'priam_ec_assignment.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Priam EC Assignment Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'priam_ec_assignment/___id____default/priam_ec_assignment.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'parse_evidence.priam_ec', '', FALSE, FALSE, 11,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'priam_ec_assignment.default'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'wu-blastp.COGS', 'BLASTP vs COG', TRUE, FALSE, 12,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'wu-blastp' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.COGS' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'FULL_TRANSLATED_LIST' ) );

--INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
--  VALUES (
--    (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.COGS'),
--    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Search Result'),
--    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BLAST Raw Results'),
--    'File List', 'Intermediate', 'wu-blastp/___id____COGS/wu-blastp.raw.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.COGS'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BTAB'),
    'File List', 'Intermediate', 'wu-blastp/___id____COGS/wu-blastp.btab.list');

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.COGS'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Search Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'wu-blastp/___id____COGS/wu-blastp.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'oligopicker.default', 'Oligo Picker', TRUE, FALSE, 14,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'oligopicker' ));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson )
  VALUES ( 'bsml2fasta.oligopicker', 'BSML2Fasta for OligoPicker', TRUE, TRUE, 13,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2fasta' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'oligopicker.default'));

INSERT INTO clusterinput (filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Start Site Curation Result'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'OligoPicker_Input',
    '$;REPOSITORY_ROOT$;/output_repository/start_site_curation/$;PIPELINEID$;_default/start_site_curation.bsml.list');

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2fasta.oligopicker' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'OligoPicker_Input' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'oligopicker.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'OligoPicker Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'OligoPicker Raw Result'),
    'File List', 'Intermediate', 'oligopicker/___id____default/oligopicker.raw.list');

-- Predict Gene Function

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'parse_evidence.hmmpfam_pre', '', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'hmmpfam.pre_overlap_analysis'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id, component_dependson ) 
  VALUES ( 'parse_evidence.ber_pre', '', FALSE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'parse_evidence' ),
  (SELECT component_id FROM component WHERE component_ergatisname = 'wu-blastp.pre_overlap_analysis'));

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'p_func.default', '', FALSE, FALSE, 3,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'p_func' ));

INSERT INTO clusterinput ( filetype_id, inputdependency_id, fileformat_id, clusterinput_ergatisformat, clusterinput_name, clusterinput_defaultvalue)
  VALUES (
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Protein Function Evidence'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Internal Only'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List',
    'P_Func_Evidence',
    '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_hmmpfam_pre/parse_evidence.tab.list,$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_hmmpfam_post/parse_evidence.tab.list,$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_ber_pre/parse_evidence.tab.list,$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_ber_post/parse_evidence.tab.list,$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_tmhmm/parse_evidence.tab.list,$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_lipoprotein/parse_evidence.tab.list,$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_priam_ec/parse_evidence.tab.list,$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_hypothetical/parse_evidence.tab.list' );

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'p_func.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'P_Func_Evidence' ) );

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'p_func.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Predict Gene Function Result'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'p_func/___id____default/p_func.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'pipeline_summary.default', '', FALSE, FALSE, 4,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'pipeline_summary' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'pipeline_summary.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Pipeline Summary'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'BSML'),
    'File List', 'Internal', 'pipeline_summary/___id____default/pipeline_summary.bsml.list');

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) 
  VALUES ( 'bsml2tbl.default', '', FALSE, FALSE, 5,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2tbl' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2tbl.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Pipeline Summary'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Table'),
    'File List', 'Pipeline', 'bsml2tbl/___id____default/bsml2tbl.bsml.list');

--INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id ) VALUES ( '', '', '', FALSE, FALSE, 0,
--  (SELECT cluster_id FROM cluster WHERE cluster_name = '' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = '' );
