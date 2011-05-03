-- Process Annotation Input
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ('Process Annotation Input Files', 'ProcessInput.yaml',
'Perform any necessary processing on user input files to prepare them for the pipeline run.',
'___split_multifasta.default___' );

-- Gene Prediction
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Gene Prediction', 'GenePrediction.yaml', 
'The gene prediction cluster accepts a FASTA file as input and predicts open reading frames using gene prediction software.  Glimmer3 is the current software used.  The resulting data includes coordinate, frame, strand, and score information as well as the extracted genes in FASTA format.',
' <commandSet type="serial">
    <state>incomplete</state>
    ___glimmer3.iter1___ 
    ___train_for_glimmer3_iteration.train_for_glimmer___
    ___glimmer3.iter2___
    <commandSet type="parallel">
      <state>incomplete</state>
      ___translate_sequence.translate_prediction___
      ___bsml2fasta.prediction_CDS___
    </commandSet>
  ___promote_gene_prediction.promote_prediction___
  </commandSet>
  ___translate_sequence.translate___
  ___join_multifasta.gene_predict_translated___
' );


-- Protein Domain Search
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Protein Domain Search', 'HMMSearch.yaml', 
'The HMM search cluster uses hmmpfam to perform similarity searches against an HMM database to identify protein family or domain matches.  Hmmpfam reads a sequence file and compares each sequence in it, one at a time, against all the HMMs in the HMM databse looking for significantly similar sequence matches.  Hmmpfam is run against a dataset which includes both PFAM and TIGRFAM HMM information.  The output of this cluster is the hmmpfam raw result.',
' <commandSet type="serial">
   <state>incomplete</state>
   ___hmmpfam.pre_overlap_analysis___
  </commandSet>
' );

-- Sequence Similiarity Search
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Sequence Similarity Search', 'BlastSearch.yaml', 
'The BLAST search cluster performs a BLAST homology search using a set of translated sequences as input against a non-redundant database comprised of several sources including NCBI, SwissProt, PDB, etc.  The BLAST result is then used as input for the BER algorithm.  A modified Smith-Waterman alignment is performed on the protein against the mini-database of BLAST hits. In order to identify potential frameshifts or point mutations in the sequence, the gene is extended 300 nucleotides upstream and downstream of the predicted coding region. The output of this cluster includes BLAST raw results in both full format and btab format and also BER raw results in btab format.',
'  <commandSet type="serial">
     <state>incomplete</state>
     <commandSet type="parallel">
       <state>incomplete</state>
        ___wu-blastp.pre_overlap_analysis___
        <commandSet type="serial">
          <state>incomplete</state>
          ___bsml2fasta.pre_overlap_analysis___
	  ___xdformat.pre_overlap_analysis___
        </commandSet>
        ___bsml2featurerelationships.pre_overlap_analysis___
      </commandSet>
      ___ber.pre_overlap_analysis___
    </commandSet>
' );

-- Alternative Start Site Analysis
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Alternate Start Site Analysis', 'StartSiteCuration.yaml', 
'This cluster discovers and analyzes genes originating form an alternative start site.  Discovery is performed by a scoring method which incorporates the BER results of a previous analysis and also a characterized database of verified genes.  The analysis of the discovered genes will, by default, reflect the choices you have made in the prior portions of the pipeline.  For example, if you chose to run both BLAST and HMMPFAM, then these will both be run on the new genes.  However, if you chose to only run BLAST, then by default, only BLAST will be run on the new genes.',
'  ___overlap_analysis.default___
   ___start_site_curation.default___
   ___translate_sequence.translate_new_models___
   ___parse_evidence.hypothetical___
   <commandSet type="parallel">
     <state>incomplete</state>

     <commandSet type="serial">
       <state>icncomplete</state>
       ___hmmpfam.post_overlap_analysis___
       ___parse_evidence.hmmpfam_post___
     </commandSet>

     <commandSet type="serial">
       <state>incomplete</state>
       <commandSet type="parallel">
         <state>incomplete</state>
         ___wu-blastp.post_overlap_analysis___
         <commandSet type="serial">
           <state>incomplete</state>
           ___bsml2fasta.post_overlap_analysis___
	   ___xdformat.post_overlap_analysis___
         </commandSet>
         ___bsml2featurerelationships.post_overlap_analysis___
       </commandSet>
       ___ber.post_overlap_analysis___
       ___parse_evidence.ber_post___
     </commandSet>
   </commandSet>
   <commandSet type="parallel">
     <state>incomplete</state>
     ___translate_sequence.final_polypeptides___
     ___bsml2fasta.final_cds___
   </commandSet>
' );

-- Additional Genome Analysis
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Additional Genome Analysis', '', 
'The Additional Genome Analysis cluster is a collection of various components that provided additional information about the genome.  The components cover varying areas including RNA analysis.  Currently the software includes RNAmmer and tRNAscan-SE.  There are plans to expand this cluster by providing additional software to support sRNA prediction.', 
'  <commandSet type="parallel">
     <state>incomplete</state>
     ___RNAmmer.default___
     ___tRNAscan-SE.find_tRNA___
   </commandSet>
 ');


-- Additional Gene Analysis
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Additional Gene Analysis', '',
'The Additional Gene Analysis cluster is a collection of various components that provided additional information about potential genes.  The components cover varying areas including signal peptided cleavage site prediction, sub-cellular location prediction, transcription terminator prediction, transmembrane protein prediction, lipoprotein motif prediction, Oligo probe creation, pathway analysis and EC assignment.  The software included is SignalP, TargetP, TransTerm, TMhmm, BLASTP against the COG database, Priam EC assignment using rpsblast, Prosite Scan, and OligoPicker.  Additional software will be added in the future.  Immediate plans include the addition of Asgard, a pathway prediction program.',
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
     ___targetp.default___
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
 ');


-- Predict Gene Function
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'Predict Gene Function', 'PredictGeneFunction.yaml', 
'The Predict Gene Function cluster assigns annotation information to a gene using data produced by the Gene Function Prediction algorithm.  Data from BLAST, HMMPFAM, tRNA-scan, SignalP and several other programs are used to assign annotation.  The output of this cluster is a summary file in NCBI tbl format.',
'  <commandSet type="parallel">
    <state>incomplete</state>
    ___parse_evidence.hmmpfam_pre___
    ___parse_evidence.ber_pre___
   </commandSet>
   ___p_func.default___
   ___pipeline_summary.default___
   ___cgb_bsml2tbl.default___
   ___tbl2asn.default___
' );

