
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Set reference paths
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE reference SET reference_path = '/nfs/bio/db/OrthoDB'
 WHERE reference_name = 'OrthoDB';
UPDATE reference SET reference_path = '/nfs/bio/db/EST'
 WHERE reference_name = 'NCBI dbEST';

UPDATE reference SET reference_path = '/nfs/bio/db/NCBI-nr'
 WHERE reference_name = 'NCBI nr';
UPDATE reference SET reference_path = '/nfs/bio/db/OrthoMCL'
 WHERE reference_name = 'OrthoMCL';
UPDATE reference SET reference_path = '/nfs/bio/db/hmmer3_hmm'
 WHERE reference_name = 'Pfam';
UPDATE reference SET reference_path = '/nfs/bio/db/Prosite'
 WHERE reference_name = 'PROSITE';
UPDATE reference SET reference_path = '/nfs/bio/db/UniProt100'
 WHERE reference_name = 'UniRef100';

UPDATE reference SET reference_path = '/nfs/bio/db/TIGRFAM'
 WHERE reference_name = 'TIGRFAM';
UPDATE reference SET reference_path = '/nfs/bio/db/COG'
 WHERE reference_name = 'COG';
UPDATE reference SET reference_path = '/nfs/bio/db/Priam'
 WHERE reference_name = 'Priam';
UPDATE reference SET reference_path = '/nfs/bio/db/RegTransBase'
 WHERE reference_name = 'RegTransBase';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencereleases for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI nr'),
         '05-01-2012', 'nr-05-01-2012', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'nr-05-01-2012');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='UniProt100'),
         '04-18-2012', '04-18-2012',(SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), '04-18-2012');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='OrthoDB'),
         '2012-02-11','OrthoDB5', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'OrthoDB5');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI dbEST'),
         '2012-02-06','est-02-06-2012', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'est-02-06-2012');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='OrthoMCL'),
         '2011-04-14','orthomcl-04-14-2011', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'orthomcl-04-14-2011');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Pfam'),
         '2012-03-05','hmm_all-03-05-12', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'hmm_all-03-05-12');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='PROSITE'),
         '2012-04-11','Prosite-04-11-2012', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'Prosite-04-11-2012');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Pfam'),
         '2009-09-29','hmm_all-09-29-09', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 
	         'hmm_all-09-29-09');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'HMMer Protein Family Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='hmm_all-09-29-09'),
    'coding_hmm.lib.bin');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='TIGRFAM'),
         '2004-01-15','1.0', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'TIGRFAM-v1');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'HMMer Protein Family Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'TIGRFAM')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='1.0'),
    '');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='COG'),
         '2003-03-02','2003-03-02', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'), 
	         'COG-03-2-2003');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'COG')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='2003-03-02'),
    'whog');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Priam'),
         '2009-06-16','2009-06-16', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 
	         'Priam-06-16-2009');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Profile Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Priam')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='2009-06-16'),
    'profile_EZ');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='PROSITE'),
         '2011-02-08','2011-02-08', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 
	         'Prosite-02-08-2011');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'PROSITE Protein Family Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'PROSITE')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='2011-02-08'),
    'prosite.dat');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='RegTransBase'),
         '2006-01-01','1', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 
	         'regtransbase_alignments_v1');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'Regulatory Interaction Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'RegTransBase')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='1'),
    '');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='nr-05-01-2012'),
    'nr');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniProt100')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='04-18-2012'),
    'uniref100.fasta');


INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Mapping Data' 
    	                                                AND referencetemplate_label = 'Arthropods'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/OrthoDBArthropodaGeneMappings.dat');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Mapping Data' 
    	                                                AND referencetemplate_label = 'Diptera'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/OrthoDBDipteraGeneMappings.dat');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Mapping Data' 
    	                                                AND referencetemplate_label = 'Fungi'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/OrthoDBFungiGeneMappings.dat');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Mapping Data' 
    	                                                AND referencetemplate_label = 'Mammals'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/OrthoDBMammaliaGeneMappings.dat');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Mapping Data' 
    	                                                AND referencetemplate_label = 'Metazoa'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/OrthoDBMetazoaGeneMappings.dat');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Mapping Data' 
    	                                                AND referencetemplate_label = 'Primates and Rodents'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/OrthoDBEuarchontogliresGeneMappings.dat');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Mapping Data' 
    	                                                AND referencetemplate_label = 'Vertebrates'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/OrthoDBVertebrataGeneMappings.dat');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Conserved Single Copy' 
    	                                                AND referencetemplate_label = 'Arthropods'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/orthodb_arthropod_conserved_single_copy.txt');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Conserved Single Copy' 
    	                                                AND referencetemplate_label = 'Diptera'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/orthodb_diptera_conserved_single_copy.txt');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Conserved Single Copy' 
    	                                                AND referencetemplate_label = 'Fungi'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/orthodb_fungi_conserved_single_copy.txt');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Conserved Single Copy' 
    	                                                AND referencetemplate_label = 'Mammals'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/orthodb_mammals_conserved_single_copy.txt');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Conserved Single Copy' 
    	                                                AND referencetemplate_label = 'Metazoa'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/orthodb_metazoa_conserved_single_copy.txt');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Conserved Single Copy' 
    	                                                AND referencetemplate_label = 'Primates and Rodents'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/orthodb_primatesrodents_conserved_single_copy.txt');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'OrthoDB Conserved Single Copy' 
    	                                                AND referencetemplate_label = 'Vertebrates'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'tabtext/orthodb_vertebrates_conserved_single_copy.txt');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database'
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'OrthoDB')),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='OrthoDB5'),
    'fasta/OrthoDB');

INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Nucleotide Database' 
    	                                                AND referencetemplate_label = 'dbEST Human'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='est-02-06-2012'),
    'est_human');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Nucleotide Database'
    	                                                AND referencetemplate_label = 'dbEST Mouse'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='est-02-06-2012'),
    'est_mouse');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Nucleotide Database'
    	                                                AND referencetemplate_label = 'dbEST Others'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='est-02-06-2012'),
    'est_others');


INSERT  INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database'
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'OrthoMCL')),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='orthomcl-04-14-2011'),
    'aa_seqs_OrthoMCL-5.fasta');

INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'HMMer Protein Family Database'
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam')),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='hmm_all-03-05-12'),
    'coding_hmm.lib');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'PROSITE Protein Family Database'
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'PROSITE')),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='Prosite-04-11-2012'),
    'prosite.dat');


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add Software for Prok Feb 2011
--
-- I'm sinning and hardcoding pipeline status ( 4 = Published, 1 = Available )
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'NCBI BLAST'), '2.2.19', '2008-11-17', 4,
           '/nfs/bio/sw/encap/blast-2.2.19/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'NCBI BLAST');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'Glimmer'), '3.02', '2006-05-09', 4,
           '/nfs/bio/sw/encap/glimmer-3.02/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Glimmer');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'PS Scan'), '1.67', '2008-09-15', 4,
           '/nfs/bio/sw/encap/ps_scan-20080915/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'PS Scan');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'PS Scan');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'HMMer'), '2.3.2', '2003-10-03', 4,
           '/nfs/bio/sw/encap/hmmer-2.3.2/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'HMMer');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'TRNAScan-SE'), '1.23', '2002-04-01', 4,
           '/nfs/bio/sw/encap/tRNAscanSE-1.23/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'TRNAScan-SE');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'RNAmmer'), '1.2', '2008-09-09', 4,
           '/nfs/bio/sw/encap/rnammer-1.2/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'RNAmmer');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'BER'), '20051118', '2005-11-18', 4,
           '/nfs/bio/sw/encap/praze-20051118/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'BER');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'Praze'), '20051118', '2005/11/18', 4,
           '/nfs/bio/sw/encap/praze-20051118/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Praze');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'LipoP'), '1.0', '2007-06-06', 4,
           '/nfs/bio/sw/encap/lipop-1.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'LipoP');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'SignalP'), '3.0', '2004-01-01', 1,
           '/nfs/bio/sw/encap/signalp-3.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'SignalP');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'SignalP'), '4.0', '2012/12/09', 4,
           '/research/projects/isga/sw/signalp-4.0/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'SignalP');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'TransTermHP'), '2.06', '2008-12-18', 4,
           '/nfs/bio/sw/encap/transterm_hp-2.06/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'TransTermHP');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'Asgard'), '1.5.3', '2011-01-19', 4,
           '/nfs/bio/sw/encap/asgard-1.5/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Asgard');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'asn2all'), '6.3', '2010-07-27', 4,
           '/nfs/bio/sw/encap/asn2all_20100727/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'asn2all');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'tbl2asn'), '13.2', '2009-03-01', 4,
           '/nfs/bio/sw/encap/tbl2asn-13.2/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'tbl2asn');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'MAST'), '4.3.0', '2009-10-06', 4,
           '/nfs/bio/sw/encap/meme-4.3.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'MAST');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'TMHMM'), '2.0c', '2007-05-08', 4,
           '/nfs/bio/sw/encap/TMHMM-2.0c/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'TMHMM');



-- X Name: NCBI BLAST
-- X Name: Glimmer

-- - Name: PS Scan
-- - Name: HMMer
-- - Name: TRNAscan-SE
-- - Name: RNAmmer
-- - Name: BER
-- - Name: LipoP
-- - Name: SignalP
-- - Name: TransTermHP
-- - Name: Asgard
-- - Name: asn2all
-- - Name: tbl2asn
-- - Name: MAST
-- - Name: TMHMM


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add software releases
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'NCBI BLAST+'), '2.2.25', '2011-03-31', 4,
           '/nfs/bio/sw/encap/ncbi_blast-2.2.25/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'NCBI BLAST+');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'HMMer'), '3.0i', '2010/03/28', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/hmmer-3.0i/bin/');
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'TargetP'), '1.1b', '2007/03/05', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/targetp-1.1b/bin/');
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'BLAST2GO'), '2.5.0', '2011/06/10', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/research/projects/isga/sw/b2g4pipe/');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'MEGAN'), '3.8', '2010/07/01', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/megan_3.9/');
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'RepeatMasker'), '3.29', '2010/08/17', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/RepeatMasker-3.29/bin/');

UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/hmmer-3.0i/bin/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'HMMer');
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/targetp-1.1b/bin/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'TargetP');
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/research/projects/isga/sw/b2g4pipe/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'BLAST2GO');
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/megan_3.9/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'MEGAN');
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/RepeatMasker-3.29/bin/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'RepeatMasker');


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add references to pipeline
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE pipelinereference SET referencerelease_id = 
 ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'est-02-06-2012' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI dbEST');

UPDATE pipelinereference SET referencerelease_id = 
 ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'est-02-06-2012' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI dbEST');

-- hack in genome references
INSERT INTO pipelinereference (pipeline_id, reference_id, referencerelease_id) 
SELECT ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' ),
         reference_id, referencerelease_id FROM referencerelease NATURAL JOIN reference WHERE reference_description ~ 'Reference information';


