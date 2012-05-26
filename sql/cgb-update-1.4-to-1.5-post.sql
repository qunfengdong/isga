

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Change UniProt100 to UniRef100
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE referencerelease SET reference_id = ( SELECT reference_id FROM reference where reference_name = 'UniRef100' )
 WHERE reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'UniProt100' );
UPDATE referencedb SET referencetemplate_id = ( SELECT referencetemplate_id FROM referencetemplate WHERE reference_id = 
                                           ( SELECT reference_id FROM reference where reference_name = 'UniRef100' ))
 WHERE referencetemplate_id = ( SELECT referencetemplate_id FROM referencetemplate WHERE reference_id = 
                                           ( SELECT reference_id FROM reference where reference_name = 'UniProt100' ));
DELETE FROM referencetemplate WHERE reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'UniProt100' );
DELETE FROM reference WHERE reference_name = 'UniProt100';

UPDATE referencerelease SET referencerelease_version = '2010_11'
  WHERE reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'UniRef100' )
        AND referencerelease_version = '11-30-2010';

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

UPDATE reference SET reference_path = '/nfs/bio/db/NIAA/' WHERE reference_name = 'NIAA';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencereleases for referencedb
--
-- I'm sinning and hardcoding pipeline status ( 4 = Published, 1 = Available )
-------------------------------------------------------------------
-------------------------------------------------------------------

-- NIAA
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NIAA'), '2009-07-27','NIAA-07-27-2009', 1, 'NIAA-07-27-2009');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'AllGroup.niaa',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
       AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NIAA')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NIAA');

-- nr 09-20-2009
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI nr'), '2009-09-20','nr-09-20-2009', 1, 'nr-09-20-2009');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'nr',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
       AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr');

-- nr 11-19-2010
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI nr'), '2010-11-19','nr-11-19-2010', 1, 'nr-11-19-2010');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'nr',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
       AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr');

-- nr 02-19-2011 already exists in our database
UPDATE pipelinereference SET referencerelease_id = 
  ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'nr-02-19-2011' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI nr'), '05-01-2012', 'nr-05-01-2012', 4, 'nr-05-01-2012');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'nr',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr')));

--uniprot 11-30-2010 already exists in our database
UPDATE pipelinereference SET referencerelease_id = 
  ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '2010_11' 
       AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniRef100') )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniRef100');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='UniRef100'), '04-14-2009', '15.0', 4, '/nfs/bio/db/Asgard/asgard_data-09-23-2009/');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'UniRef100',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniRef100')));
UPDATE pipelinereference SET referencerelease_id = 
  ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '15.0' 
       AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniRef100') )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniRef100');


INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='UniRef100'), '04-18-2012', '2012_03', 4, '04-18-2012');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'uniref100.fasta',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'UniRef100')));

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='OrthoDB'), '2012-02-11','OrthoDB5', 4, 'OrthoDB5');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI dbEST'), '2012-02-06','est-02-06-2012', 4, 'est-02-06-2012');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='OrthoMCL'), '2011-04-14','orthomcl-04-14-2011', 4, 'orthomcl-04-14-2011');

-- hack in hmm2 database
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Pfam'), '2009-09-29','23', 4, '/nfs/bio/db/hmm_all/hmm_all-09-29-09');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'coding_hmm.lib.bin',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'HMMer Protein Family Database' 
       AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam')));
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'coding_hmm.lib.db',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'Protein Family Mapping Database' 
       AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam');
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Pfam'), '2012-03-05', '26', 4, 'hmm_all-03-05-12');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'coding_hmm.lib',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'HMMer Protein Family Database'
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam'))); 


INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='PROSITE'),
         '2012-04-11','Prosite-04-11-2012', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'), 'Prosite-04-11-2012');


INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='TIGRFAM'), '2009-11-18','8.0', 4, 'TIGRFAM-v1');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), '',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'HMMer Protein Family Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'TIGRFAM')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'TIGRFAM');
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'TIGRFAM');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='COG'), '2003-03-02','2003-03-02', 4, 'COG-03-2-2003');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'myva',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Amino Acid Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'COG')));
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'whog',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'Protein Family Mapping Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'COG')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'COG');
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'COG');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Priam'), '2009-06-16','2009-06-16', 4, 'Priam-06-16-2009');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'profile_EZ',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'BLAST Profile Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Priam')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Priam');
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Priam');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='PROSITE'), '2011-02-08','20.70', 1, 'Prosite-02-08-2011');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'prosite.dat',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'PROSITE Protein Family Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'PROSITE')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'PROSITE');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='PROSITE'), '2009-03-17','20.44', 1, 'Prosite-03-17-2009');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), 'prosite.dat',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'PROSITE Protein Family Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'PROSITE')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'PROSITE');

INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, pipelinestatus_id, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='RegTransBase'), '2006-01-01','1',  4, 'regtransbase_alignments_v1');
INSERT INTO referencedb (referencerelease_id, referencedb_path, referencetemplate_id)
  VALUES ( (SELECT CURRVAL('referencerelease_referencerelease_id_seq')), '',
    (SELECT referencetemplate_id FROM referencetemplate WHERE referencetemplate_format = 'Regulatory Interaction Database' 
            AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'RegTransBase')));
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'RegTransBase');
UPDATE pipelinereference SET referencerelease_id = (SELECT CURRVAL('referencerelease_referencerelease_id_seq'))
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'RegTransBase');

UPDATE pipelinereference SET referencerelease_id = (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'GRCh37.p2')
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Shore SNP Mapping Pipeline' AND globalpipeline_release = 'Apr 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Homo Sapien');

UPDATE pipelinereference SET referencerelease_id = (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'Tair10')
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Shore SNP Mapping Pipeline' AND globalpipeline_release = 'Apr 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Arabidopsis thaliana');

UPDATE pipelinereference SET referencerelease_id = (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '5.31')
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Shore SNP Mapping Pipeline' AND globalpipeline_release = 'Apr 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Drosophila melanogaster');

UPDATE pipelinereference SET referencerelease_id = (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'WS225')
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Shore SNP Mapping Pipeline' AND globalpipeline_release = 'Apr 2011' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Caenorhabditis elegans');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries
-------------------------------------------------------------------
-------------------------------------------------------------------


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
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'NCBI BLAST');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'NCBI BLAST');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'WU-BLAST'), '2.0', '2008-01-01', 4,
           '/nfs/bio/sw/encap/wublast-2.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'WU-BLAST');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'OligoPicker'), '2.3.2', '2003-05-22', 4,
           '/research/projects/isga/sw/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'OligoPicker');


INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'ELPH'), '1.01', '2006-11-02', 4,
           '/nfs/bio/sw/encap/elph-1.01/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'ELPH');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'ELPH');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'Glimmer'), '3.02', '2006-05-09', 4,
           '/nfs/bio/sw/encap/glimmer-3.02/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Glimmer');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Glimmer');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'PS Scan'), '1.67', '2008-09-15', 4,
           '/nfs/bio/sw/encap/ps_scan-20080915/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'PS Scan');
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
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'HMMer');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'HMMer');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'tRNAscan-SE'), '1.23', '2002-04-01', 4,
           '/nfs/bio/sw/encap/tRNAscanSE-1.23/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'tRNAscan-SE');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'tRNAscan-SE');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'RNAmmer'), '1.2', '2008-09-09', 4,
           '/nfs/bio/sw/encap/rnammer-1.2/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'RNAmmer');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'RNAmmer');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'BER'), '20051118', '2005-11-18', 4,
           '/nfs/bio/sw/encap/praze-20051118/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'BER');
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
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'LipoP');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'LipoP');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'SignalP'), '3.0', '2004-01-01', 1,
           '/nfs/bio/sw/encap/signalp-3.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'SignalP');
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
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'TransTermHP');
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
   VALUES ((SELECT software_id FROM software WHERE software_name = 'Asgard'), '1.0', '2007-11-27', 1,
           '/nfs/bio/sw/encap/isga_utils-1.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Asgard');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'asn2all'), '6.3', '2010-07-27', 4,
           '/nfs/bio/sw/encap/asn2all_20100727/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'asn2all');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'asn2all');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'tbl2asn'), '13.2', '2009-03-01', 4,
           '/nfs/bio/sw/encap/tbl2asn-13.2/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'tbl2asn');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'tbl2asn');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'MAST'), '4.3.0', '2009-10-06', 4,
           '/nfs/bio/sw/encap/meme-4.3.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'MAST');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'MAST');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'TMHMM'), '2.0c', '2007-05-08', 4,
           '/nfs/bio/sw/encap/TMHMM-2.0c/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Jan 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'TMHMM');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Prokaryotic Annotation' AND globalpipeline_release = 'Feb 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'TMHMM');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'Celera Assembler'), '6.0-beta', '2009-11-05', 4,
           '/nfs/bio/sw/encap/wgs-7.0/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Celera Assembly' AND globalpipeline_release = 'Jun 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'Celera Assembler');

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'AMOS'), '2.0.8', '2008-06-22', 4,
           '/nfs/bio/sw/encap/amos-2.0.8/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Celera Assembly' AND globalpipeline_release = 'Jun 2010' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'AMOS');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add software releases
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'SHORE'), '0.6unstable', '2011-02-14', 4,
           '/nfs/bio/sw/encap/shore-0.6.unstable/bin/');
UPDATE pipelinesoftware SET softwarerelease_id = (SELECT CURRVAL('softwarerelease_softwarerelease_id_seq'))
     WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Shore SNP Mapping Pipeline' AND globalpipeline_release = 'Apr 2011' )
           AND software_id = (SELECT software_id FROM software WHERE software_name = 'SHORE');

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

INSERT INTO softwarerelease ( software_id, softwarerelease_version, softwarerelease_release, pipelinestatus_id, softwarerelease_path )
   VALUES ((SELECT software_id FROM software WHERE software_name = 'ORFPredictor'), '2.0', '2010/04/15', (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Published'),
           '/nfs/bio/sw/encap/orfpredictor_2.0/bin/');

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
 ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'nr-05-01-2012' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr');

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

UPDATE pipelinereference SET referencerelease_id =
 ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'OrthoDB5' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'OrthoDB');

UPDATE pipelinereference SET referencerelease_id =
 ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'orthomcl-04-14-2011' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'OrthoMCL');

UPDATE pipelinereference SET referencerelease_id =
 ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '26' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'Pfam');

UPDATE pipelinereference SET referencerelease_id =
 ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'Prosite-04-11-2012' )
 WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' )
           AND reference_id = (SELECT reference_id FROM reference WHERE reference_name = 'PROSITE');

-- hack in genome references
INSERT INTO pipelinereference (pipeline_id, reference_id, referencerelease_id) 
SELECT ( SELECT pipeline_id FROM pipeline NATURAL JOIN globalpipeline WHERE
                                pipeline_name = 'Transcriptome Analysis' AND globalpipeline_release = 'Apr 2012' ),
         reference_id, referencerelease_id FROM referencerelease NATURAL JOIN reference WHERE reference_description ~ 'Reference information';



-------------------------------------------------------------------
-------------------------------------------------------------------
-- Set Versions for all existing pipelines
-------------------------------------------------------------------
-------------------------------------------------------------------

-- CeleraAssembly::Jun2010        | Celera Assembler | 6.0-beta
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '6.0-beta'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'Celera Assembler' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'CeleraAssembly::Jun2010';
-- CeleraAssembly::Jun2010        | AMOS             | 2.0.8
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '2.0.8'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'AMOS' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'CeleraAssembly::Jun2010';
-- ProkaryoticAnnotation::Feb2011 | LipoP            | 1.0
-- ProkaryoticAnnotation::Jan2010 | LipoP            | 1.0
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '1.0'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'LipoP' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | ELPH             | 1.01
-- ProkaryoticAnnotation::Jan2010 | ELPH             | 1.01
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '1.01'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'ELPH' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | Glimmer          | 3.02
-- ProkaryoticAnnotation::Jan2010 | Glimmer          | 3.02
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '3.02'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'Glimmer' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | PS Scan          | 1.67
-- ProkaryoticAnnotation::Jan2010 | PS Scan          | 1.67
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '1.67'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'PS Scan' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | HMMer            | 2.3.2
-- ProkaryoticAnnotation::Jan2010 | HMMer            | 2.3.2
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '2.3.2'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'HMMer' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | tRNAscan-SE      | 1.23
-- ProkaryoticAnnotation::Jan2010 | tRNAscan-SE      | 1.23
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '1.23'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'tRNAscan-SE' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | RNAmmer          | 1.2
-- ProkaryoticAnnotation::Jan2010 | RNAmmer          | 1.2
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '1.2'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'RNAmmer' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
--  ProkaryoticAnnotation::Feb2011 | BER              | 20051118
-- ProkaryoticAnnotation::Jan2010 | BER              | 20051118
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '20051118'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'BER' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | NCBI BLAST       | 2.2.19
-- ProkaryoticAnnotation::Jan2010 | NCBI BLAST       | 2.2.19
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '2.2.19'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'NCBI BLAST' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | SignalP          | 3.0
-- ProkaryoticAnnotation::Jan2010 | SignalP          | 3.0
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '3.0'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'SignalP' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | TransTermHP      | 2.06
-- ProkaryoticAnnotation::Jan2010 | TransTermHP      | 2.06
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '2.06'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'TransTermHP' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | Asgard           | 1.5.3
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '1.5.3'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'Asgard' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Feb2011';
-- ProkaryoticAnnotation::Feb2011 | asn2all          | 6.3
-- ProkaryoticAnnotation::Jan2010 | asn2all          | 6.3
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '6.3'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'asn2all' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | tbl2asn          | 13.2
-- ProkaryoticAnnotation::Jan2010 | tbl2asn          | 13.2
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '13.2'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'tbl2asn' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | MAST             | 4.3.0
-- ProkaryoticAnnotation::Jan2010 | MAST             | 4.3.0
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '4.3.0'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'MAST' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | TMHMM            | 2.0c
-- ProkaryoticAnnotation::Jan2010 | TMHMM            | 2.0c
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '2.0c'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'TMHMM' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Jan2010 | OligoPicker      | 2.3.2
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '2.3.2'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'OligoPicker' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010';
-- ProkaryoticAnnotation::Jan2010 | WU-BLAST         | 2.0
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '2.0'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'WU-BLAST' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010';
-- ProkaryoticAnnotation::Jan2010 | Asgard           | 1.0
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '1.0'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'Asgard' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010';
-- ShoreMapping::Apr2011          | SHORE            | 0.6unstable
INSERT INTO runsoftware (run_id, softwarerelease_id)
  SELECT run_id, ( SELECT softwarerelease_id FROM softwarerelease WHERE softwarerelease_version = '0.6unstable'
                          AND software_id = ( SELECT software_id FROM software WHERE software_name = 'SHORE' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ShoreMapping::Apr2011';


-- ProkaryoticAnnotation::Feb2011 | COG            | 2003-03-02
-- ProkaryoticAnnotation::Jan2010 | COG            | 2003-03-02
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '2003-03-02'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'COG' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | Pfam           | 23
-- ProkaryoticAnnotation::Jan2010 | Pfam           | 23
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '23'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'Pfam' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | Priam          | 2009-06-16
-- ProkaryoticAnnotation::Jan2010 | Priam          | 2009-06-16
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '2009-06-16'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'Priam' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );

-- ProkaryoticAnnotation::Feb2011 | TIGRFAM        | 8.0
-- ProkaryoticAnnotation::Jan2010 | TIGRFAM        | 8.0
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '8.0'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'TIGRFAM' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | RegTransBase   | 1
-- ProkaryoticAnnotation::Jan2010 | RegTransBase   | 1
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '1'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'RegTransBase' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass IN ( 'ProkaryoticAnnotation::Feb2011', 'ProkaryoticAnnotation::Jan2010' );
-- ProkaryoticAnnotation::Feb2011 | PROSITE        | 20.70
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '20.70'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'PROSITE' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Feb2011';
-- ProkaryoticAnnotation::Feb2011 | NCBI nr        | nr-02-19-2011
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'nr-02-19-2011'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Feb2011';
-- ProkaryoticAnnotation::Jan2010 | UniRef100      | 2010_11
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '2010_11'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'UniRef100' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Feb2011';

-- ProkaryoticAnnotation::Jan2010 | NIAA           | NIAA-07-27-2009
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'NIAA-07-27-2009'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'NIAA' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010';
-- ProkaryoticAnnotation::Jan2010 | NCBI nr        | nr-09-20-2009
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'nr-09-20-2009'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010'
                                                  AND run_createdat <= '2010-11-20';
-- ProkaryoticAnnotation::Jan2010 | NCBI nr        | nr-11-19-2010
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'nr-11-19-2010'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'NCBI nr' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010'
                                                  AND run_createdat > '2010-11-20';
-- ProkaryoticAnnotation::Jan2010 | PROSITE        | 20.44
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '20.44'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'PROSITE' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010';
-- ProkaryoticAnnotation::Jan2010 | UniRef100      | 15.0
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '15.0'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'UniRef100' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ProkaryoticAnnotation::Jan2010';
-- ShoreMapping::Apr2011          | Homo Sapien             | GRCh37.p2
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'GRCh37.p2'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'Homo Sapien' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ShoreMapping::Apr2011';
-- ShoreMapping::Apr2011          | Arabidopsis thaliana    | Tair10
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'Tair10'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'Arabidopsis thaliana' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ShoreMapping::Apr2011';
-- ShoreMapping::Apr2011          | Drosophila melanogaster | 5.31
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = '5.31'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'Drosophila melanogaster' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ShoreMapping::Apr2011';
-- ShoreMapping::Apr2011          | Caenorhabditis elegans  | WS225
INSERT INTO runreference (run_id, referencerelease_id)
  SELECT run_id, ( SELECT referencerelease_id FROM referencerelease WHERE referencerelease_version = 'WS225'
                          AND reference_id = ( SELECT reference_id FROM reference WHERE reference_name = 'Caenorhabditis elegans' ))
       FROM run NATURAL JOIN globalpipeline WHERE globalpipeline_subclass = 'ShoreMapping::Apr2011';

