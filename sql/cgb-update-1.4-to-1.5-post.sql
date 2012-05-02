
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
-- Add software releases
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'NCBI BLAST+'), '2.2.25', '2011-03-31', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/ncbi_blast-2.2.25/bin/');
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
   VALUES ((SELECT software_id FROM software WHERE software_name = 'PS Scan'), '1.67', '2008/09/15', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/ps_scan-20080915/bin/');
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'Praze'), '20051118', '2005/11/18', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/praze-20051118/bin/');
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'MEGAN'), '3.8', '2010/07/01', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/megan_3.9/');
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'SignalP'), '4.0', '2012/12/09', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/research/projects/isga/sw/signalp-4.0/');
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'RepeatMasker'), '3.29', '2010/08/17', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/RepeatMasker-3.29/bin/');

--INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
--   VALUES ((SELECT software_id FROM software WHERE software_name = ''), '', '', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = ''),
--           '');

UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/ncbi_blast-2.2.25/bin/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'NCBI BLAST+');

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
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/ps_scan-20080915/bin/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'PS Scan');
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/praze-20051118/bin/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Praze');
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/nfs/bio/sw/encap/megan_3.9/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'MEGAN');
UPDATE pipelinesoftware SET softwarerelease_id = ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_path = '/research/projects/isga/sw/signalp-4.0/')
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'SignalP');
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
SELECT 3, reference_id, referencerelease_id FROM referencerelease NATURAL JOIN reference WHERE reference_description ~ 'Reference information';


