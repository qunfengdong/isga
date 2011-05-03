-- accountrequeststatus
INSERT INTO accountrequeststatus ( accountrequeststatus_name ) VALUES ('Open');
INSERT INTO accountrequeststatus ( accountrequeststatus_name ) VALUES ('Created');
INSERT INTO accountrequeststatus ( accountrequeststatus_name ) VALUES ('Expired');

-- fileformat
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('FASTA', 'fsa', 'A text-based format for representing either nucleic acid sequences or peptide sequences, in which base pairs or amino acids are represented using single-letter codes. The format also allows for sequence names and comments to precede the sequences. http://www.ncbi.nlm.nih.gov/blast/fasta.shtml');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BSML', 'bsml', 'Bioinformatic Sequence Markup Language (BSML)is a public domain XML application for bioinformatic data.  BSML provides a management tool, visualization interface and container for sequences and other bioinformatic data. BSML may be used in combination with LabBook\'s Genomic XML Viewer (free to the scientific community) or Genomic Browser to provide a single document interface to all project data.  http://bsml.sourceforge.net/');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('HMMPFAM Raw Results', 'xxx', 'The raw results produced by HMMPFAM.  This report consists of three sections: a ranked list of the best scoring HMMs, a list of the best scoring domains in order of their occurrence in the sequence, and alignments for all the best scoring domains. A sequence score may be higher than a domain score for the same sequence if there is more than one domain in the sequence; the sequence score takes into account all the domains. All sequences scoring above the -E and -T cutoffs are shown in the first list, then every domain found in this list is shown in the second list of domain hits.  For detailed information, please see this pdf document (pages 26 - 27): ftp://selab.janelia.org/pub/software/hmmer/CURRENT/Userguide.pdf');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Glimmer3 Prediction Results', 'xxx', 'This file has the final gene predictions from glimmer3. Its format is the fasta-header line of the sequence followed by one line per gene.  The columns are:<br>Column 1 The identifier of the predicted gene. The numeric portion matches the number in the ID column of the .detail file.<br>Column 2 The start position of the gene.<br>Column 3 The end position of the gene. This is the last base of the stop codon, i.e., it includes the stop codon.<br>Column 4 The reading frame.<br>Column 5 The per-base raw score of the gene. This is slightly different from the value in the .detail file, because it includes adjustments for the PWM and start-codon frequency.<br>For detailed information, please see this pdf document (pages 13 - 14): http://www.cbcb.umd.edu/software/glimmer/glim302notes.pdf');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Glimmer3 Detailed Results', 'xxx', 'The .detail file begins with the command that invoked the program and a list of the parameters used by the program.  Following that, for each sequence in the input file the fasta-header line is echoed and followed by a list of orfs that were long enough for glimmer3 to score.  For detailed information, please see this pdf document (pages 11 - 13): http://www.cbcb.umd.edu/software/glimmer/glim302notes.pdf');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BLAST Raw Results', 'xxx', '. The report consists of three major sections: (1) the header, which contains information about the query sequence, the database searched. On the Web, there is also a graphical overview; (2) the one-line descriptions of each database sequence found to match the query sequence; these provide a quick overview for browsing; (3) the alignments for each database sequence matched (there may be more than one alignment for a database sequence it matches).  http://www.ncbi.nlm.nih.gov/books/bv.fcgi?rid=handbook.section.615');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BER Raw Results', 'xxx', 'This program first does a BLAST search (Altschul, et al., 1990) (http://blast.wustl.edu) of each protein against niaa and stores all significant matches in a mini-database. Then a modified Smith-Waterman alignment (Smith and Waterman, 1981) is performed on the protein against the mini-database of BLAST hits. In order to identify potential frameshifts or point mutations in the sequence, the gene is extended 300 nucleotides upstream and downstream of the predicted coding region. If significant homology to a match protein exists and extends into a different frame from that predicted, or extends through a stop codon, the program will continue the alignment past the boundaries of the predicted coding region. The results can be viewed both as pairwise and as multiple alignments of the top scoring matches.  The raw results are presented in btab (BLAST tabulated format).');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Table', 'tbl', 'NCBI tbl format.  The feature table format allows different kinds of features (e.g., gene, mRNA, coding region, tRNA) and qualifiers (e.g., /product, /note) to be annotated. The valid features and qualifiers are restricted to those approved by the International Nucleotide Sequence Database Collaboration.  http://www.ncbi.nlm.nih.gov/Sequin/table.html#Table%20Layout');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BTAB', 'btab', 'BLAST tabulated file');

-- filecontent
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Nucleotide Sequence', 'Sequence data using A, T, C, and G string format (generally in FASTA format).');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Amino Acid Sequence', 'Translated sequence data (generally in FASTA format).');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Similarity Scores', 'Data produced through comparison algorithms producing similarity scores often represnted as e-values. (BLAST, HMMPFAM, etc.)');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('ORF Prediction Results', 'Data currently produced by Glimmer3.  This is coordinate data as well as both the nucleotide and translated FASTA data.');
  -- ORF Prediction Detailed Results is redundant and probably should be deleted.
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('ORF Prediction Detailed Results', 'The detailed data currently produced by Glimmer3.  This includes all orf scored strings.');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Gene Curation Results', 'BSML formatted data which relates CDS and polypeptide sequence information.  Please contact biohelp@cgb.indiana.edu for more information.');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Predicted Gene Function Results', 'Annotation data produced by the Gene Function Prediction algorithm.  Data from BLAST, HMMPFAM, tRNA-scan, SignalP and several other programs are used to assign annotation.');

-- inputdependency
INSERT INTO inputdependency ( inputdependency_name ) VALUES ('Required');
INSERT INTO inputdependency ( inputdependency_name ) VALUES ('Optional');
INSERT INTO inputdependency ( inputdependency_name ) VALUES ('Internal Only');

-- partystatus
INSERT INTO partystatus ( partystatus_name ) VALUES ( 'Active' );
INSERT INTO partystatus ( partystatus_name ) VALUES ( 'ReadOnly' );
INSERT INTO partystatus ( partystatus_name ) VALUES ( 'Disabled' );
INSERT INTO partystatus ( partystatus_name ) VALUES ( 'Closed' );


-- partypartition
INSERT INTO partypartition (partypartition_name, partypartition_class )
 VALUES ( 'Account', 'SysMicro::Account' );
INSERT INTO partypartition (partypartition_name, partypartition_class )
 VALUES ( 'UserGroup', 'SysMicro::UserGroup' );

-- pipelinepartition

INSERT INTO pipelinepartition (pipelinepartition_name, pipelinepartition_class )
 VALUES ( 'GlobalPipeline', 'SysMicro::GlobalPipeline' );
INSERT INTO pipelinepartition (pipelinepartition_name, pipelinepartition_class )
 VALUES ( 'UserPipeline', 'SysMicro::UserPipeline' );


-- pipelinestatus
INSERT INTO pipelinestatus (pipelinestatus_name) VALUES ('Available');
INSERT INTO pipelinestatus (pipelinestatus_name) VALUES ('Hidden');
INSERT INTO pipelinestatus (pipelinestatus_name) VALUES ('Retired');

-- runstatus
INSERT INTO runstatus (runstatus_name) VALUES ('Running');
INSERT INTO runstatus (runstatus_name) VALUES ('Canceled');
INSERT INTO runstatus (runstatus_name) VALUES ('Complete');
INSERT INTO runstatus (runstatus_name) VALUES ('Held');
INSERT INTO runstatus (runstatus_name) VALUES ('Error');
INSERT INTO runstatus (runstatus_name) VALUES ('Submitting');
INSERT INTO runstatus (runstatus_name) VALUES ('Incomplete');
INSERT INTO runstatus (runstatus_name) VALUES ('Failed');

--- lightweight dictionaryies

-- ergatisformat
INSERT INTO ergatisformat ( ergatisformat_name ) VALUES ('File');
INSERT INTO ergatisformat ( ergatisformat_name ) VALUES ('File List');
INSERT INTO ergatisformat ( ergatisformat_name ) VALUES ('Directory');

-- stylesheet
INSERT INTO stylesheet (stylesheet_name) VALUES ('1column');
INSERT INTO stylesheet (stylesheet_name) VALUES ('2column');
INSERT INTO stylesheet (stylesheet_name) VALUES ('2columnright');
INSERT INTO stylesheet (stylesheet_name) VALUES ('3column');
INSERT INTO stylesheet (stylesheet_name) VALUES ('none');
