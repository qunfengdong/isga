
-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add filetypes and fileformats specific for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO filetype (filetype_name, filetype_help) VALUES ('BLAST Database', 'blast formated db');
INSERT INTO filetype (filetype_name, filetype_help) VALUES ('SHOREDB', 'preprocessed for shore');
INSERT INTO filetype (filetype_name, filetype_help) VALUES ('Genomic cDNA', 'Annotated cDNA');
INSERT INTO filetype (filetype_name, filetype_help) VALUES ('BSSEEKERDB', 'preprocessed for bsseeker');

INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary) VALUES('formatdb', 'xxx', 'formatdb formated database', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary) VALUES('Shore Index Folder', 'xxx', 'indexed shore file', TRUE);
INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary) VALUES('bsseeker preprocessed', 'xxx', 'preprocessed for bsseeker', TRUE);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencetypes for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id) VALUES ('BLAST Nucleotide Database', 
  (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Database'), 
  (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'formatdb'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id) VALUES ('BLAST Amino Acid Database', 
  (SELECT filetype_id FROM filetype WHERE filetype_name = 'BLAST Database'),
  (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'formatdb'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id) VALUES ('SHORE Preprocess Data', 
  (SELECT filetype_id FROM filetype WHERE filetype_name = 'SHOREDB'),
  (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Shore Index Folder'));
INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id) VALUES ('BSEEKER Data', 
  (SELECT filetype_id FROM filetype WHERE filetype_name = 'BSSEEKERDB'),
  (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'bsseeker preprocessed'));

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencedb entries
---- These are currently dummy place holders
-------------------------------------------------------------------
-------------------------------------------------------------------

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description) 
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    'Homo Sapiens', '/nfs/bio/db/Homo_sapien/blast/rna/rna.fa',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    'Homo Sapiens', '/nfs/bio/db/Homo_sapien/blast/protein/protein.fa',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    'Homo Sapiens', '/some/fake/path',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    'Homo Sapiens', '/some/fake/path',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    'Arabidopsis thaliana', '/nfs/bio/db/Arabidopsis_thaliana/blast/cdna/TAIR10_cdna_20101214',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    'Arabidopsis thaliana', '/nfs/bio/db/Arabidopsis_thaliana/blast/protein/TAIR10_pep_20101214',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    'Arabidopsis thaliana', '/nfs/bio/db/Arabidopsis_thaliana/shore/arab10.fasta.shore',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    'Arabidopsis thaliana', '/some/fake/path',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    'Drosophila melanogaster', '/nfs/bio/db/Drosophila_melanogaster/blast/ncbi_cds/cds.ffn',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    'Drosophila melanogaster', '/nfs/bio/db/Drosophila_melanogaster/blast/ncbi_proteins/proteins.faa',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'SHORE Preprocess Data'),
    'Drosophila melanogaster', '/some/fake/path',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BSEEKER Data'),
    'Drosophila melanogaster', '/some/fake/path',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Nucleotide Database'),
    'NCBI-nt', '/nfs/bio/db/NCBI-nt/nt-05-17-2011/nt',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    'NCBI-nr', '/nfs/bio/db/NCBI-nr/nr-02-19-2011/nr',
    'Some description');

INSERT INTO referencedb (referencetype_id, referencedb_name, referencedb_path, referencedb_description)
  VALUES (
    (SELECT referencetype_id FROM referencetype WHERE referencetype_name = 'BLAST Amino Acid Database'),
    'UniRef100', '/nfs/bio/db/UniProt100/11-30-2010/uniref100.fasta',
    'Some description');

