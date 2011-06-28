-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencetags
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO referencetag (referencetag_name) VALUES ('Organism');
INSERT INTO referencetag (referencetag_name) VALUES ('Collection');

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

INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary) 
  VALUES('formatdb', 'xxx', 'formatdb formated database', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary) 
  VALUES('Shore Index Folder', 'xxx', 'indexed shore file', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary) 
  VALUES('bsseeker preprocessed', 'xxx', 'preprocessed for bsseeker', TRUE);

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

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencereleases for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
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

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries
---- These are currently dummy place holders
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path) 
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/rna/rna.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)    
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/protein/protein.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)    
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'shore/human.fasta.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='GRCh37.p2'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    '/some/fake/path');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/cdna/TAIR10_cdna_20101214');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/protein/TAIR10_pep_20101214');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'shore/arab10.fasta.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Tair10'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    '/some/fake/path');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/ncbi_cds/cds.ffn');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/ncbi_proteins/proteins.faa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'shore/drosophila.fasta.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='5.31'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    '/some/fake/path');


INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/cds/c_elegans.WS225.cds_transcripts.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/protein/c_elegans.WS225.protein.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'shore/c_elegans.WS225.genomic.fa.shore');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='WS225'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    '/some/fake/path');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v1.0'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/cds/FrozenGeneCatalog20110204.CDS.fasta');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v1.0'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/protein/FrozenGeneCatalog20110204.proteins.fasta');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v1.0'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    '/some/fake/path');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='v1.0'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    '/some/fake/path');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='K-12 MG1655'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/cds/NC_000913.ffn');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='K-12 MG1655'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/protein/NC_000913.faa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='168'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/cds/NC_000964.ffn');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='168'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/protein/NC_000964.faa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Zv9'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/transcript/rna.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='Zv9'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'blast/protein/protein.fa');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='nt-05-17-2011'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'nt');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='nr-02-19-2011'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'nr');

INSERT INTO referencedb (referencetype_id, referencerelease_id, pipelinestatus_id, referencedb_path)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    (SELECT referencerelease_id FROM referencerelease WHERE referencerelease_release='11-30-2010'),
    (SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name='Available'),
    'uniref100.fasta');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries myself to Accound Admins
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Account Administrators'),
(SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu'));
