-- accountrequeststatus
INSERT INTO accountrequeststatus ( accountrequeststatus_name ) VALUES ('Open');
INSERT INTO accountrequeststatus ( accountrequeststatus_name ) VALUES ('Created');
INSERT INTO accountrequeststatus ( accountrequeststatus_name ) VALUES ('Expired');

-- fileformat
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('FASTA', 'fsa', 'A text-based format for representing either nucleic acid sequences or peptide sequences, in which base pairs or amino acids are represented using single-letter codes. The format also allows for sequence names and comments to precede the sequences. http://www.ncbi.nlm.nih.gov/blast/fasta.shtml');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BSML', 'bsml', 'Bioinformatic Sequence Markup Language (BSML)is a public domain XML application for bioinformatic data.  BSML provides a management tool, visualization interface and container for sequences and other bioinformatic data. BSML may be used in combination with LabBook''s Genomic XML Viewer (free to the scientific community) or Genomic Browser to provide a single document interface to all project data.  http://bsml.sourceforge.net/');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('HMMPFAM Raw Results', 'xxx', 'The raw results produced by HMMPFAM.  This report consists of three sections: a ranked list of the best scoring HMMs, a list of the best scoring domains in order of their occurrence in the sequence, and alignments for all the best scoring domains. A sequence score may be higher than a domain score for the same sequence if there is more than one domain in the sequence; the sequence score takes into account all the domains. All sequences scoring above the -E and -T cutoffs are shown in the first list, then every domain found in this list is shown in the second list of domain hits.  For detailed information, please see this pdf document (pages 26 - 27): ftp://selab.janelia.org/pub/software/hmmer/CURRENT/Userguide.pdf');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Glimmer3 Prediction Results', 'xxx', 'This file has the final gene predictions from glimmer3. Its format is the fasta-header line of the sequence followed by one line per gene.  The columns are:<br>Column 1 The identifier of the predicted gene. The numeric portion matches the number in the ID column of the .detail file.<br>Column 2 The start position of the gene.<br>Column 3 The end position of the gene. This is the last base of the stop codon, i.e., it includes the stop codon.<br>Column 4 The reading frame.<br>Column 5 The per-base raw score of the gene. This is slightly different from the value in the .detail file, because it includes adjustments for the PWM and start-codon frequency.<br>For detailed information, please see this pdf document (pages 13 - 14): http://www.cbcb.umd.edu/software/glimmer/glim302notes.pdf');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Glimmer3 Detailed Results', 'xxx', 'The .detail file begins with the command that invoked the program and a list of the parameters used by the program.  Following that, for each sequence in the input file the fasta-header line is echoed and followed by a list of orfs that were long enough for glimmer3 to score.  For detailed information, please see this pdf document (pages 11 - 13): http://www.cbcb.umd.edu/software/glimmer/glim302notes.pdf');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BLAST Raw Results', 'xxx', '. The report consists of three major sections: (1) the header, which contains information about the query sequence, the database searched. On the Web, there is also a graphical overview; (2) the one-line descriptions of each database sequence found to match the query sequence; these provide a quick overview for browsing; (3) the alignments for each database sequence matched (there may be more than one alignment for a database sequence it matches).  http://www.ncbi.nlm.nih.gov/books/bv.fcgi?rid=handbook.section.615');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BER Raw Results', 'xxx', 'This program first does a BLAST search (Altschul, et al., 1990) (http://blast.wustl.edu) of each protein against niaa and stores all significant matches in a mini-database. Then a modified Smith-Waterman alignment (Smith and Waterman, 1981) is performed on the protein against the mini-database of BLAST hits. In order to identify potential frameshifts or point mutations in the sequence, the gene is extended 300 nucleotides upstream and downstream of the predicted coding region. If significant homology to a match protein exists and extends into a different frame from that predicted, or extends through a stop codon, the program will continue the alignment past the boundaries of the predicted coding region. The results can be viewed both as pairwise and as multiple alignments of the top scoring matches.  The raw results are presented in btab (BLAST tabulated format).');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Table', 'tbl', 'NCBI tbl format.  The feature table format allows different kinds of features (e.g., gene, mRNA, coding region, tRNA) and qualifiers (e.g., /product, /note) to be annotated. The valid features and qualifiers are restricted to those approved by the International Nucleotide Sequence Database Collaboration.  http://www.ncbi.nlm.nih.gov/Sequin/table.html#Table%20Layout');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('BTAB', 'btab', 'BLAST tabulated file');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('GFF', 'gff', 'GFF is a format for describing genes and other features associated with DNA, RNA and Protein sequences. The current specification can be found at http://www.sanger.ac.uk/Software/formats/GFF/GFF_Spec.shtml.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('RNAmmer HMM report', 'hmmreport', 'The raw results produced by RNAmmer.  This report consists of three sections: a ranked list of the best scoring HMMs, a list of the best scoring domains in order of their occurrence in the sequence, and alignments for all the best scoring domains. A sequence score may be higher than a domain score for the same sequence if there is more than one domain in the sequence; the sequence score takes into account all the domains. All sequences scoring above the -E and -T cutoffs are shown in the first list, then every domain found in this list is shown in the second list of domain hits.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('tRNAscan Raw Result', 'xxx', 'The default output for tRNAscan-SE includes overall statistics for the various component programs (trnascan(14), eufindtrna(15) and cove(16)) as well as summary data for the entire search. The summary data includes counts of the total number of tRNAs found, the number of tRNA pseudogenes found, number of tRNAs with introns and which anticodons were detected. Finally, the output shows the predicted secondary structure for each identified sequence.  The output also displays the overall length of the sequence, the location of the anticodon and the overall tRNAscan-SE score. tRNAscan-SE scores for known tRNA sequences for various species are included on the website to facilitate evaluation of the significance of the score.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('GIF', 'gif', 'The Graphics Interchange Format (GIF) is a bitmap image format that was introduced by CompuServe in 1987 and has since come into widespread usage on the World Wide Web due to its wide support and portability.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('EPS', 'eps', 'This is the Encapsulated PostScript format. A PostScript document with additional restrictions intended to make EPS files usable as a graphics file format. In other words, EPS files are more-or-less self-contained, reasonably predictable PostScript documents that describe an image or drawing, that can be placed within another PostScript document.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('SignalP Raw Result', 'xxx', 'The graphical output from SignalP (neural network) comprises three different scores, C, S and Y. Two additional scores are reported in the SignalP3-NN output, namely the S-mean and the D-score, but these are only reported as numerical values. For each organism class in SignalP; Eukaryote, Gram-negative and Gram-positive, two different neural networks are used, one for predicting the actual signal peptide and one for predicting the position of the signal peptidase I (SPase I) cleavage site. The S-score for the signal peptide prediction is reported for every single amino acid position in the submitted sequence, with high scores indicating that the corresponding amino acid is part of a signal peptide, and low scores indicating that the amino acid is part of a mature protein. The C-score is the ``cleavage site'' score. For each position in the submitted sequence, a C-score is reported, which should only be significantly high at the cleavage site. Confusion is often seen with the position numbering of the cleavage site. When a cleavage site position is referred to by a single number, the number indicates the first residue in the mature protein, meaning that a reported cleavage site between amino acid 26-27 corresponds to that the mature protein starts at (and include) position 27. Y-max is a derivative of the C-score combined with the S-score resulting in a better cleavage site prediction than the raw C-score alone. This is due to the fact that multiple high-peaking C-scores can be found in one sequence, where only one is the true cleavage site. The cleavage site is assigned from the Y-score where the slope of the S-score is steep and a significant C-score is found. The S-mean is the average of the S-score, ranging from the N-terminal amino acid to the amino acid assigned with the highest Y-max score, thus the S-mean score is calculated for the length of the predicted signal peptide. The S-mean score was in SignalP version 2.0 used as the criteria for discrimination of secretory and non-secretory proteins. The D-score is introduced in SignalP version 3.0 and is a simple average of the S-mean and Y-max score. The score shows superior discrimination performance of secretory and non-secretory proteins to that of the S-mean score which was used in SignalP version 1 and 2. For non-secretory proteins all the scores represented in the SignalP3-NN output should ideally be very low. The hidden Markov model calculates the probability of whether the submitted sequence contains a signal peptide or not. The eukaryotic HMM model also reports the probability of a signal anchor, previously named uncleaved signal peptides. Furthermore, the cleavage site is assigned by a probability score together with scores for the n-region, h-region, and c-region of the signal peptide, if such one is found.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('GNUPlot Commands Script', 'gnu', 'This is a script that can be run in gnuplot to reproduce the output image.  Modification of this script will allow you to reformat your image to your liking or perhaps output it to a different image type.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('TargetP Raw Result', 'xxx', 'The output is a table in plain text (see the example below). For each input sequence one table row is output. The columns are as follows:<br>Name - Sequence name truncated to 20 characters<br>Len - Sequence length<br>cTP, mTP, SP, other - Final NN scores on which the final prediction is based (Loc, see below). Note that the scores are not really probabilities, and they do not necessarily add to one. However, the location with the highest score is the most likely according to TargetP, and the relationship between the scores (the reliability class, see below) may be an indication of how certain the prediction is.<br>Loc - Prediction of localization, based on the scores above; the possible values are:<br>     C       Chloroplast, i.e. the sequence contains cTP, a chloroplast transit peptide;<br>     M       Mitochondrion, i.e. the sequence contains mTP, a mitochondrial targeting peptide<br>     S       Secretory pathway, i.e. the sequence contains SP, a signal peptide;<br>     _       Any other location;<br>	*       "do not know"; indicates that cutoff restrictions were set and the winning network output score was below the requested cutoff for that category.<br>RC - Reliability class, from 1 to 5, where 1 indicates the strongest prediction. RC is a measure of the size of the difference between the highest (winning) and the second highest output scores. There are 5 reliability classes, defined as follows:<br>     1 : diff > 0.800<br>     2 : 0.800 > diff > 0.600<br>    3 : 0.600 > diff > 0.400<br>    4 : 0.400 > diff > 0.200<br>    5 : 0.200 > diff<br>Thus, the lower the value of RC the safer the prediction.<br>TPlen - Predicted presequence length; it appears only when TargetP was asked to perform cleavage site predictions');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('TMhmm Raw Result', 'xxx', 'For the raw output, tmhmm gives some statistics and a list of the location of the predicted transmembrane helices and the predicted location of the intervening loop regions.  If the whole sequence is labeled as inside or outside, the prediction  is that it contains no membrane helices.  It is probably not wise to interpret it as a prediction of location. The prediction gives the most probable location and orientation of transmembrane helices in the sequence. It is found by an algorithm called N-best (or 1-best in this case) that sums over all paths through the model with the same location and direction of the helices.<br>The first few lines gives some statistics:<br><br>  * Length: the length of the protein sequence.<br>  * Number of predicted TMHs: The number of predicted transmembrane helices.<br>  * Exp number of AAs in TMHs: The expected number of amino acids intransmembrane helices. If this number is larger than 18 it is very likely to be a transmembrane protein (OR have a signal peptide).<br>  * Exp number, first 60 AAs: The expected number of amino acids in transmembrane helices in the first 60 amino acids of the protein. If this number more than a few, you should be warned that a predicted transmembrane helix in the N-term could be a signal peptide.<br>  * Total prob of N-in: The total probability that the N-term is on the cytoplasmic side of the membrane.<br>  * POSSIBLE N-term signal sequence: a warning that is produced when "Exp number, first 60 AAs" is larger than 10.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Prosite Scan Raw Result', 'xxx', 'The default output for Prosite Scan.  The header contains the sequenced header for the protein scanned against prosite as well as the matching Prosite information (ID, etc.)  Below the header will be the start position, end position, and matching pattern from the scan.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('TransTerm Raw Result', 'xxx', 'The organisms genes are listed sorted by their end coordinate and terminators are output between them. A terminator entry looks like this:<br><br>    TERM 19  15310 - 15327  -      F     99      -12.7 -4.0 |bidir<br>    (name)   (start - end)  (sense)(loc) (conf) (hp) (tail) (notes)<br><br>where "conf" is the overall confidence score, "hp" is the hairpin score, and "tail" is the tail score. "Conf" (which ranges from 0 to 100) is what you probably want to use to assess the quality of a terminator. Higher is better. The confidence, hp score, and tail scores are described in the paper cited above.  "Loc" gives type of region the terminator is in:<br><br>    "G" = in the interior of a gene (at least 50bp from an end),<br>    "F" = between two +strand genes,<br>    "R" = between two -strand genes,<br>    "T" = between the ends of a +strand gene and a -strand gene,<br>    "H" = between the starts of a +strand gene and a -strand gene,<br>    "N" = none of the above (for the start and end of the DNA)<br><br>Because of how overlapping genes are handled, these designations are not exclusive. "G", "F", or "R" can also be given in lowercase, indicating that the terminator is on the opposite strand as the region.  Unless the all-context option is given, only candidate terminators that appear to be in an appropriate genome context (e.g. T, F, R) are output.  Following the TERM line is the sequence of the hairpin and the 5` and 3` tails, always written 5` to 3`.');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('RPSBLAST Raw Result', 'xxx', 'This reposrt is similar to the standard BLAST output.  The report consists of three major sections: (1) the header, which contains information about the query sequence, the database searched. On the Web, there is also a graphical overview; (2) the one-line descriptions of each database sequence found to match the query sequence; these provide a quick overview for browsing; (3) the alignments for each database sequence matched (there may be more than one alignment for a database sequence it matches).');
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('OligoPicker Raw Result', 'xls', 'The OligoPicker output file contains the following information:<br><br>   1. The sequence definitions from the input FASTA file.<br>   2. Total sequence lengths.<br>   3. The probe sequences.<br>   4. The probe Tm values in 1M NaCl.<br>   5. The probe positions in the DNA sequences.<br>   6. Probe Blast scores (no entry means the score is too low to be recorded).<br>   7. Cross-reactivity screening stringencies. For example, "16-32.5" means the threshold values are 16-mer for contiguous match filter and 32.5 for Blast filter.');

INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Asgard Raw Result', 'path_rec', 'This is the data produced by Asgard.  It includes the database match identifies as well as associated EC and GO terms.');

INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Genbank', 'gbf', 'The flat file format used by Genbank to described an annototated genome.  A sampel file can be viewed here: http://www.ncbi.nlm.nih.gov/Sitemap/samplerecord.html.');

--INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('', '', '');


-- filecollectiontype
INSERT INTO filecollectiontype ( filecollectiontype_name, filecollectiontype_isuniform, filecollectiontype_description ) VALUES ( 'File List', TRUE,
'List of files, all of the same type that should be processed together.' );
INSERT INTO filecollectiontype ( filecollectiontype_name, filecollectiontype_isuniform, filecollectiontype_description ) VALUES ( 'Run Results', FALSE, 
'Results for a pipeline run.' );

-- filecontent
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Nucleotide Sequence', 'Sequence data using A, T, C, and G string format (generally in FASTA format).');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Amino Acid Sequence', 'Translated sequence data (generally in FASTA format).');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Analysis Evidence', 'Generally, this is the raw data produced by a software package or analysis.');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Gene Curation Results', 'BSML formatted data which relates CDS and polypeptide sequence information.  Please contact biohelp@cgb.indiana.edu for more information.');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('Predicted Gene Function Results', 'Annotation data produced by the Gene Function Prediction algorithm.  Data from BLAST, HMMPFAM, tRNA-scan, SignalP and several other programs are used to assign annotation.');
INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('RNA Curation Results', 'BSML formatted data which relates to predicited RNA sequence information.  Please contact biohelp@cgb.indiana.edu for more information.');

-- fileresourcepartition
INSERT INTO fileresourcepartition (fileresourcepartition_name, fileresourcepartition_class ) VALUES ('File', 'SysMicro::File');
INSERT INTO fileresourcepartition (fileresourcepartition_name, fileresourcepartition_class ) VALUES ('FileCollection', 'SysMicro::FileCollection');


-- inputdependency
INSERT INTO inputdependency ( inputdependency_name ) VALUES ('Required');
INSERT INTO inputdependency ( inputdependency_name ) VALUES ('Optional');
INSERT INTO inputdependency ( inputdependency_name ) VALUES ('Internal Only');

-- newstype
INSERT INTO newstype ( newstype_name ) VALUES ( 'Pipeline Service News');
INSERT INTO newstype ( newstype_name ) VALUES ( 'Release Announcement' );
INSERT INTO newstype ( newstype_name ) VALUES ( 'Service Outage Report' );


-- outputvisibility
INSERT INTO outputvisibility ( outputvisibility_name ) VALUES ('Pipeline');
INSERT INTO outputvisibility ( outputvisibility_name ) VALUES ('Evidence');
INSERT INTO outputvisibility ( outputvisibility_name ) VALUES ('Internal');

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
INSERT INTO runstatus (runstatus_name) VALUES ('Interrupted');

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
