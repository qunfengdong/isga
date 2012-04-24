-------------------------------------------------------------------
-------------------------------------------------------------------
-- User Classes
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE userclass SET userclass_name = 'External User', userclass_description =
'Users that are not affiliates or customers of the Center for Genomics and Bioinformatics.' 
  WHERE userclass_name = 'Default User';

INSERT INTO userclass ( userclass_name, userclass_description ) VALUES (
'CGB Affiliate', 'Users that are affiliated with the Center for Genomics and Bioinformatics');

INSERT INTO userclass ( userclass_name, userclass_description ) VALUES (
'CGB Customer', 'Users that are customers of the Center for Genomics and Bioinformatics');


INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Chris Hemmerich', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'chemmeri@indiana.edu', '202cb962ac59075b964b07152d234b70',
           (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate') );


INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Aaron Buechlein', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'abuechle@indiana.edu', '202cb962ac59075b964b07152d234b70', 
           (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate') );
	
INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden  )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
           'Ram Podicheti', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'mnrusimh@indiana.edu', '202cb962ac59075b964b07152d234b70', 
            (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate') );

INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden  )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
           'Boshu Liu', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'liuboshu@gmail.com', '202cb962ac59075b964b07152d234b70',
            (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate') );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'News Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'News Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu' ) );

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu'));

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu'));

INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Chris Hemmo', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'chemmeri@cgb.indiana.edu', '202cb962ac59075b964b07152d234b70',
           (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Customer') );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add User Class Configuration settings
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'raw_data_retention'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate'),		      
  '90');

INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'raw_data_retention'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Customer'),		      
  '90');

INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'pipeline_quota'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate'),		      
  '3');

INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'pipeline_quota'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Customer'),		      
  '2');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Edit CGB Contact Address
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE siteconfiguration SET siteconfiguration_value = 'biohelp@cgb.indiana.edu'
  FROM configurationvariable b 
  WHERE siteconfiguration.configurationvariable_id = b.configurationvariable_id AND b.configurationvariable_name = 'support_email';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add User Classes
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE userclass SET userclass_name = 'External User', userclass_description =
'Users that are not affiliates or customers of the Center for Genomics and Bioinformatics.' 
  WHERE userclass_name = 'Default User';

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu'));

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu'));

SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Edit CGB Contact Address
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE siteconfiguration SET siteconfiguration_value = 'biohelp@cgb.indiana.edu'
  FROM configurationvariable b 
  WHERE siteconfiguration.configurationvariable_id = b.configurationvariable_id AND b.configurationvariable_name = 'support_email';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Edit CGB tmp space
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE siteconfiguration SET siteconfiguration_value = '/usr/tmp'
  FROM configurationvariable b
  WHERE siteconfiguration.configurationvariable_id = b.configurationvariable_id AND b.configurationvariable_name = 'local_tmp';

UPDATE siteconfiguration SET siteconfiguration_value = '/research/projects/isga/tmp/ISGA'
  FROM configurationvariable b
  WHERE siteconfiguration.configurationvariable_id = b.configurationvariable_id AND b.configurationvariable_name = 'shared_tmp';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Fix broken component_template names
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE componenttemplate set componenttemplate_name = 'cgb_bsml2tbl' WHERE componenttemplate_name = 'bsml2tbl';
UPDATE componenttemplate SET componenttemplate_name = 'tRNAscan-SE' WHERE componenttemplate_name = 'tRNAscan';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencetags
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referencetag (referencetag_name) VALUES ('Organism');
INSERT INTO referencetag (referencetag_name) VALUES ('Collection');
INSERT INTO referencetag (referencetag_name) VALUES ('OTU');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add filetypes and fileformats specific for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO filetype (filetype_name, filetype_help)
  VALUES ('BLAST Nucleotide Database', 'blast formated db');
INSERT INTO filetype (filetype_name, filetype_help)
  VALUES ('BLAST Amino Acid Database', 'blast formated db');
INSERT INTO filetype (filetype_name, filetype_help)
  VALUES ('SHOREDB', 'preprocessed for shore');
INSERT INTO filetype (filetype_name, filetype_help)
  VALUES ('Genomic cDNA', 'Annotated cDNA');
INSERT INTO filetype (filetype_name, filetype_help)
  VALUES ('BSSEEKERDB', 'preprocessed for bsseeker');
INSERT INTO filetype (filetype_name, filetype_help)
  VALUES ('OrthoDB Mapping', 'Preprocessed OrthoDB Gene to Ortholog ID Mappings');
INSERT INTO filetype (filetype_name, filetype_help)
  VALUES ('OrthoDB Conserved Single Copy', 'OrthoDB conserved single copy genes for a given OTU.');

INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary)
  VALUES('formatdb', 'xxx', 'formatdb formated database', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary)
  VALUES('Shore Index Folder', 'xxx', 'indexed shore file', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary)
  VALUES('bsseeker preprocessed', 'xxx', 'preprocessed for bsseeker', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary)
  VALUES('OrthoDB Preprocessed Mapping', 'xxx', 'preprocessed for OrthoDB classification', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary)
        VALUES('OrthoDB Conserved Single Copy List', 'xxx', 'Tab-delimeted list of OrthoDB conserved single copy genes', FALSE);


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencetypes for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
  VALUES ('BLAST Nucleotide Database',
         (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Nucleotide Database'),
         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'formatdb'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
  VALUES ('BLAST Amino Acid Database',
         (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Amino Acid Database'),
         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'formatdb'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
  VALUES ('SHORE Preprocess Data',
         (SELECT filetype_id FROM filetype WHERE filetype_name = 'SHOREDB'),
         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Shore Index Folder'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
  VALUES ('BSEEKER Data',
         (SELECT filetype_id FROM filetype WHERE filetype_name = 'BSSEEKERDB'),
         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'bsseeker preprocessed'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
  VALUES ('OrthoDB Mapping Data',
         (SELECT filetype_id FROM filetype WHERE filetype_name = 'OrthoDB Mapping'),
         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'OrthoDB Preprocessed Mapping'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
  VALUES ('OrthoDB Conserved Single Copy',
         (SELECT filetype_id FROM filetype WHERE filetype_name = 'OrthoDB Conserved Single Copy'),
         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'OrthoDB Conserved Single Copy List'));

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add references for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('NCBI-nr', '/nfs/bio/db/NCBI-nr',
         'Non-redundant GenBank CDS translations as well as, PDB, SwissProt, PIR, and PRF',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Collection'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('NCBI-nt', '/nfs/bio/db/NCBI-nt',
         'Non-redundant GenBank CDS translations as well as, PDB, SwissProt, PIR, and PRF',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Collection'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('UniProt100', '/nfs/bio/db/UniProt100',
         'UniRef100 contains all the records in the UniProt knowledgebase and selected UniParc records.',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Collection'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Homo Sapien', '/nfs/bio/db/Homo_sapien',
         'Reference information for Homo sapien.',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Arabidopsis thaliana', '/nfs/bio/db/Arabidopsis_thaliana',
         'Reference information for Arabidopsis thaliana',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Drosophila melanogaster', '/nfs/bio/db/Drosophila_melanogaster',
         'Reference information for Drosophila_melanogaster',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Caenorhabditis elegans', '/nfs/bio/db/Caenorhabditis_elegans',
         'Reference information for Caenorhabditis elegans',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Daphnia pulex', '/nfs/bio/db/Daphnia_pulex',
         'Reference information for Daphnia pulex',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Escherichia coli', '/nfs/bio/db/Escherichia_coli',
         'Reference information for Escherichia coli',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Bacillus subtilis', '/nfs/bio/db/Bacillus_subtilis',
         'Reference information for Bacillus subtilis',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Danio rerio', '/nfs/bio/db/Danio_rerio',
         'Reference information for Danio rerio',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Anopheles gambiae', '/nfs/bio/db/Anopheles_gambiae',
         'Reference information for Anopheles gambiae',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Taeniopygia guttata', '/nfs/bio/db/Taeniopygia_guttata',
         'Reference information for Taeniopygia guttata',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Vitis vinifera', '/nfs/bio/db/Vitis_vinifera',
         'Reference information for Vitis vinifera',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('Populus trichocarpa', '/nfs/bio/db/Populus_trichocarpa',
         'Reference information for Populus trichocarpa',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Organism'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('OrthoDB', '/nfs/bio/db/OrthoDB',
         'OrthoDB presents a catalog of eukaryotic orthologous protein-coding genes across 44 vertebrates, 25 arthropods, and 46 fungi.',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='OTU'));
INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
  VALUES('NCBI dbEST', '/nfs/bio/db/EST',
         'dbEST contains sequence data and other information on "single-pass" cDNA sequences, or "Expressed Sequence Tags", from a number of organisms.',
        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Collection'));

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencereleases for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI-nr'),
         'nr-01-23-2012', '01-23-2012', 'nr-01-23-2012');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI-nr'),
         'nr-02-19-2011', '02-19-2011', 'nr-02-19-2011');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI-nr'),
         'nr-05-02-2010', '05-02-2010', 'nr-05-02-2010');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI-nt'),
         'nt-05-17-2011', '05-17-2011', 'nt-05-17-2011');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='UniProt100'),
         '12-13-2011', '12-13-2011', '12-13-2011');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='UniProt100'),
         '11-30-2010', '11-30-2010', '11-30-2010');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Homo Sapien'),
         'GRCh37.p2', '07-30-2010', 'GRCh37.p2');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Arabidopsis thaliana'),
         'Tair10', '11-17-2010', 'Tair10');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Drosophila melanogaster'),
         '5.31', '11-19-2010', '5.31');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Caenorhabditis elegans'),
         'WS225', '05-19-2011', 'WS225');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Daphnia pulex'),
         'v1.0', '07-03-2007', 'v1.0');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Escherichia coli'),
         'K-12 MG1655', '10-26-2010', 'K-12_MG1655');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Bacillus subtilis'),
         '168', '02-16-2011', '168');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Danio rerio'),
         'Zv9', '05-17-2011', 'Zv9');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Anopheles gambiae'),
         'AgamP3.6', '07-13-2011', 'AgamP3.6');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Taeniopygia guttata'),
         '3.2.4', '03-02-2009', '3.2.4');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Vitis vinifera'),
         'v7.0_145', '03-31-2011', 'v7.0_145');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='Populus trichocarpa'),
         'v7.0_156', '03-31-2011', 'v7.0_156');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='OrthoDB'),
         'OrthoDB5', '02-11-2012', 'OrthoDB5');
INSERT INTO referencerelease (reference_id, referencerelease_release, referencerelease_version, referencerelease_path)
  VALUES((SELECT reference_id FROM reference WHERE reference_name='NCBI dbEST'),
         'est-02-06-2012', '02-06-2012', 'est-02-06-2012');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/rna/rna.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/protein.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'shore/human.fasta.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'bsseeker/reference_genome/');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/cdna/TAIR10_cdna_20101214');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/TAIR10_pep_20101214');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'shore/arab10.fasta.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'bsseeker/reference_genome/');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/ncbi_cds/cds.ffn');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/ncbi_proteins/proteins.faa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'shore/drosophila.fasta.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'bsseeker/reference_genome/');


INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/cds/c_elegans.WS225.cds_transcripts.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/c_elegans.WS225.protein.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'shore/c_elegans.WS225.genomic.fa.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'bsseeker/reference_genome/');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v1.0'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/cds/FrozenGeneCatalog20110204.CDS.fasta');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v1.0'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/FrozenGeneCatalog20110204.proteins.fasta');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='K-12 MG1655'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/cds/NC_000913.ffn');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='K-12 MG1655'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/NC_000913.faa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='168'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/cds/NC_000964.ffn');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='168'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/NC_000964.faa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Zv9'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/transcript/rna.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Zv9'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/protein.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='AgamP3.6'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/transcripts/agambiae.TRANSCRIPTS-AgamP3.6.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='AgamP3.6'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/peptides/agambiae.PEPTIDES-AgamP3.6.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='3.2.4'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/rna/rna.fa');


INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v7.0_145'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/Vvinifera_145_peptide.fa');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v7.0_145'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/cds/Vvinifera_145_cds.fa');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v7.0_145'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/genome/Vvinifera_145.fa');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v7.0_156'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/protein/Ptrichocarpa_156_peptide.fa');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v7.0_156'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/cds/Ptrichocarpa_156_cds.fa');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v7.0_156'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'blast/genome/Ptrichocarpa_156.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='nt-05-17-2011'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'nt');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='nr-01-23-2012'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'nr');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='nr-02-19-2011'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'nr');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='nr-05-02-2010'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'nr');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='12-13-2011'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'uniref100.fasta');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='11-30-2010'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'uniref100.fasta');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Mapping Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/OrthoDBArthropodaGeneMappings.dat', 'Arthropods');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Mapping Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/OrthoDBDipteraGeneMappings.dat', 'Diptera');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Mapping Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/OrthoDBFungiGeneMappings.dat', 'Fungi');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Mapping Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/OrthoDBMammaliaGeneMappings.dat', 'Mammals');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Mapping Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/OrthoDBMetazoaGeneMappings.dat', 'Metazoa');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Mapping Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/OrthoDBEuarchontogliresGeneMappings.dat', 'Primates and Rodents');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Mapping Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/OrthoDBVertebrataGeneMappings.dat', 'Vertebrates');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Conserved Single Copy'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/orthodb_arthropod_conserved_single_copy.txt', 'Arthropods');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Conserved Single Copy'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/orthodb_diptera_conserved_single_copy.txt', 'Diptera');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Conserved Single Copy'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/orthodb_fungi_conserved_single_copy.txt', 'Fungi');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Conserved Single Copy'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/orthodb_mammals_conserved_single_copy.txt', 'Mammals');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Conserved Single Copy'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/orthodb_metazoa_conserved_single_copy.txt', 'Metazoa');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Conserved Single Copy'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/orthodb_primatesrodents_conserved_single_copy.txt', 'Primates and Rodents');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'OrthoDB Conserved Single Copy'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='OrthoDB5'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'tabtext/orthodb_vertebrates_conserved_single_copy.txt', 'Vertebrates');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='est-02-06-2012'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'est_human', 'dbEST Human');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='est-02-06-2012'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'est_mouse', 'dbEST Mouse');
INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path, referencedb_label)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='est-02-06-2012'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Published'),
    'est_others', 'dbEST Others');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries myself to Accound Admins
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'),
(SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu'));

