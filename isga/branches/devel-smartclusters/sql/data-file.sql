INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Protein Function Evidence', 'Collected and parsed evidence of protein function', 
   (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Gene Curation Results' ));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id ) 
  VALUES ( 'Assembled Genome Fasta', 'The whole sequence of a genome, contig, plasmid, chromosome, etc',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Nucleotide Sequence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id ) 
  VALUES ( 'Nucleotide Sequence', 'Generic nucleotide sequence. When possible, use a more specific file type.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Nucleotide Sequence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'ORF Prediction Raw Evidence', 'ORF prediction results produced by gene prediction algorithms such as Glimmer3.  The raw data is ORF coordinate, reading frame, strand, and score information used to extract a nucleotide sequence from a sequence data file.  However, the extracted genes in FASTA format are included in this file type as well.  When supplying as input, this can simply be a set of genes in FASTA format.  When retrieving as output from a pipeline you are receiving the raw coordinate data.  We also provide the extracted ORFs in FASTA format as another file type',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'ORF Sequence', 'The extracted ORFs in FASTA format.  In the pipeline these are often created by using the coordinate data produced by gene prediction software such as Glimmer3.  When supplying as an input, these can be a set of genes ofinterest in FASTA format.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Nucleotide Sequence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Translated ORF Sequence', 'The translated version of extracted ORFs in FASTA format.  In the pipeline these are often created by using the coordinate data produced by gene prediction software and translating the sequences.  When supplying as an input, these can be a set of proteins of interest in FASTA format.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Amino Acid Sequence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id ) 
  VALUES ( 'Amino Acid Sequence', 'Generic amino acid sequence. When possible, use a more specific file type.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Amino Acid Sequence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'HMM Search Result', 'This is the raw results produced by HMMPFAM. For detailed information, please see this pdf document (pages 26 - 27): ftp://selab.janelia.org/pub/software/hmmer/CURRENT/Userguide.pdf',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'BLAST Search Result', 'This is the raw data produced by BLAST.  This data is both the full output and the btab format as well.  When supplying as an input, both the full and the btab formats are acceptable.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'BER Search Result', 'This filetype is the raw results produced by using the BER algorithm on the raw results of a previously performed BLAST search.  A modified Smith-Waterman alignment (Smith and Waterman, 1981) is performed on the protein against the mini-database of BLAST hits. In order to identify potential frameshifts or point mutations in the sequence, the gene is extended 300 nucleotides upstream and downstream of the predicted coding region. If significant homology to a match protein exists and extends into a different frame from that predicted, or extends through a stop codon, the program will continue the alignment past the boundaries of the predicted coding region. The results can be viewed both as pairwise and as multiple alignments of the top scoring matches.  The raw results are presented in btab (BLAST tabulated format).',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Auto-Gene Curation Result', 'This filetype is BSML formatted data which relates CDS and polypeptide sequence information.  In general, this filetype is not considered to be human readable and is internal to the automated pipeline.  However, advanced users familiar with BSML are able to provide this data as input.  Please contact biohelp@cgb.indiana.edu for more information on this filetype.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Gene Curation Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Promote Gene Prediction Result', 'This filetype is BSML formatted data which relates CDS and polypeptide sequence information.  In general, this filetype is not considered to be human readable and is internal to the automated pipeline.  However, advanced users familiar with BSML are able to provide this data as input.  Please contact biohelp@cgb.indiana.edu for more information on this filetype.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Gene Curation Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Start Site Curation Result', 'This filetype is BSML formatted data which relates CDS and polypeptide sequence information.  In general, this filetype is not considered to be human readable and is internal to the automated pipeline.  However, advanced users familiar with BSML are able to provide this data as input.  Please contact biohelp@cgb.indiana.edu for more information on this filetype.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Gene Curation Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'RNAmmer Result', 'This is the results produced by RNAmmer.  There are two main results.  The first is the raw result produced by the program.  It is the format produced by the hmmer program.  The second is a gff file of the results as well.  This will provide sequence location information.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'tRNAscan Result', 'The results produced by tRNAscan-SE.  The main result is the raw result.  That format is described at http://lowelab.ucsc.edu/tRNAscan-SE/trnascanseReadme.html.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'SignalP Result', 'The results produced by SignalP. There are several results from SignalP. The main result is the raw result file. This is accompanied by the visual results for both the Nueral Network and HMM prediction. These outputs are described in full detail at http://www.cbs.dtu.dk/services/SignalP/output.php.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'TargetP Result', 'The results produced by TargetP. The main result is the raw result file. This is described in detail at http://www.cbs.dtu.dk/services/TargetP/output.php',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'TMhmm Result', 'The results produced by TMhmm. The main result is the raw result file. This is described in detail at http://www.cbs.dtu.dk/services/TMHMM/TMHMM2.0b.guide.php',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));
 
INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Prosite Scan Result', 'The results produced by Prosite Scan. The main result is the raw result file.  This is described in more detail at ftp://ftp.expasy.org/databases/prosite/tools/ps_scan/README',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'TransTerm Result', 'The results produced by TransTerm. The main result is the raw result file.  This is described in more detail at http://transterm.cbcb.umd.edu/description.html',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Lipoprotein Motif Result', 'The results produced by the lipoprotein_motif script.. The only current result is the bsml file.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'RPSBLAST Result', 'This is the raw data produced by RPSBLAST.  This data is both the full output and the btab format as well.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Priam EC Assignment Result', 'This is the raw data produced by the Priam EC Assignment script.  The only output provided is the bsml.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'OligoPicker Result', 'This is the raw data produced by OligoPicker.  This is described in detail at http://pga.mgh.harvard.edu/oligopicker/.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Analysis Evidence'));


INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Predict Gene Function Result', 'Annotation data produced by the Gene Function Prediction algorithm.  Data from BLAST, HMMPFAM, tRNA-scan, SignalP and several other programs are used to assign annotation.  The data is reported in BSML format. In general, this filetype is not considered to be human readable and is internal to the automated pipeline. Please contact biohelp@cgb.indiana.edu for more information on this filetype.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Predicted Gene Function Results'));

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'Pipeline Summary', 'This is the annotation data produced by the pipeline. Data from BLAST, HMMPFAM, tRNA-scan, SignalP and several other programs are used to assign annotation.  This data is reported in NCBI tbl format.',
    (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'Predicted Gene Function Results'));


--INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
--  VALUES ( '', '', (SELECT filecontent_id FROM filecontent WHERE filecontent_name = ''));
