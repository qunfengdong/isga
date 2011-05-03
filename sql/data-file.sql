INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id ) 
  VALUES ( 'Assembled Genome Fasta', 'The whole sequence of a genome, contig, plasmid, chromosome, etc',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Nucleotide Sequence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'ORF Prediction', 'ORF prediction results produced by gene prediction algorithms such as Glimmer3.  The raw data is ORF coordinate, reading frame, strand, and score information used to extract a nucleotide sequence from a sequence data file.  However, the extracted genes in FASTA format are included in this file type as well.  When supplying as input, this can simply be a set of genes in FASTA format.  When retrieving as output from a pipeline you can choose to the raw coordinate data and/or the extracted sequences in FASTA format.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'ORF Prediction Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Translated ORF Prediction', 'The translated version of genes in FASTA format.  In the pipeline these are often created by gene prediction software and translated.  However, when supplying as an input, these can be a set of proteins of interest in FASTA format.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'ORF Prediction Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Detailed ORF Prediction', 'This file type is the Glimmer3 *.detail file.  This filetype contains program paramter information as well as the ORF coordinate, reading frame, and score information for all ORFs that where considered long enough to be scored.  This includes all ORFs regardless of them being above or below the threshold score.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'ORF Prediction Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'HMM Search Result', 'This is the raw results produced by HMMPFAM. For detailed information, please see this pdf document (pages 26 - 27): ftp://selab.janelia.org/pub/software/hmmer/CURRENT/Userguide.pdf',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Similarity Scores'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'BLAST Search Result', 'This is the raw data produced by BLAST.  This data is both the full output and the btab format as well.  When supplying as an input, both the full and the btab formats are acceptable.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Similarity Scores'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'BER Search Result', 'This filetype is the raw results produced by using the BER algorithm on the raw results of a previously performed BLAST search.  A modified Smith-Waterman alignment (Smith and Waterman, 1981) is performed on the protein against the mini-database of BLAST hits. In order to identify potential frameshifts or point mutations in the sequence, the gene is extended 300 nucleotides upstream and downstream of the predicted coding region. If significant homology to a match protein exists and extends into a different frame from that predicted, or extends through a stop codon, the program will continue the alignment past the boundaries of the predicted coding region. The results can be viewed both as pairwise and as multiple alignments of the top scoring matches.  The raw results are presented in btab (BLAST tabulated format).',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Similarity Scores'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Auto-Gene Curation  Result', 'This filetype is BSML formatted data which relates CDS and polypeptide sequence information.  In general, this filetype is not considered to be human readable and is internal to the automated pipeline.  However, advanced users familiar with BSML are able to provide this data as input.  Please contact biohelp@cgb.indiana.edu for more information on this filetype.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Gene Curation Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Predict Gene Function Result', 'Annotation data produced by the Gene Function Prediction algorithm.  Data from BLAST, HMMPFAM, tRNA-scan, SignalP and several other programs are used to assign annotation.  The data is reported in BSML format. In general, this filetype is not considered to be human readable and is internal to the automated pipeline. Please contact biohelp@cgb.indiana.edu for more information on this filetype.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Predicted Gene Function Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Pipeline Summary', 'This is the annotation data produced by the pipeline. Data from BLAST, HMMPFAM, tRNA-scan, SignalP and several other programs are used to assign annotation.  This data is reported in NCBI tbl format.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Predicted Gene Function Results'));

