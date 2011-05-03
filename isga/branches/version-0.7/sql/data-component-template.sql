-- Gene Prediction Cluster
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'split_multifasta', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'glimmer3', 'Glimmer3.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'train_for_glimmer3_iteration', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'translate_sequence', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'bsml2fasta', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'promote_gene_prediction', 'promote_gene_prediction.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'join_multifasta', '' );

-- Protein Domain Search

INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'hmmpfam', 'HMMPfam.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'tar_list', '' );

-- Sequence Similarity Search

INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'wu-blastp', 'wu-blastp.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'xdformat', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'bsml2featurerelationships', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'ber', 'Ber.yaml' );

-- Alternative Start Site Analysis

INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'start_site_curation', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'overlap_analysis', '' );

-- Interevidence Analysis
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'bsml2interevidence_fasta', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'ncbi-blastx', 'ncbi-blastx.yaml' );

-- Geneome Analysis
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'RNAmmer', 'RNAmmer.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'signalp', 'Signalp.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'oligopicker', 'oligopicker.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'ps_scan', 'ps_scan.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'tRNAscan', 'tRNAscan-SE.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'targetp', 'targetp.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'transterm', 'transterm.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'tmhmm', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'rpsblast', 'rpsblast.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'priam_ec_assignment', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'lipoprotein_motif', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'ncbi-blastp', 'ncbi-blastp.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'asgard', '' );


-- Predict Gene Function

INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'parse_evidence', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'p_func', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'pipeline_summary', 'pipeline_summary.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'bsml2tbl', '' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'tbl2asn', 'tbl2asn.yaml' );


--INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( '', '' );
