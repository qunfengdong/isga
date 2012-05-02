
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Set reference paths
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE reference SET reference_path = '/nfs/bio/db/OrthoDB'
 WHERE reference_name = 'OrthoDB';

UPDATE reference SET reference_path = '/nfs/bio/db/EST'
 WHERE reference_name = 'NCBI dbEST';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencereleases for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI nr'),
         '2012-01-21', 'nr-01-23-2012', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'nr-01-23-2012');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='UniProt100'),
         '2011-12-13', '12-13-2011',(SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), '12-13-2011');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='OrthoDB'),
         '2012-02-11','OrthoDB5', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'OrthoDB5');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI dbEST'),
         '2012-02-06','est-02-06-2012', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'est-02-06-2012');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='nr-01-23-2012'),
    'nr');
INSERT INTO referencedb (referencetemplate_id, referencerelease_id, referencedb_path)
  VALUES (
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniProt100')), 
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version='12-13-2011'),
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


