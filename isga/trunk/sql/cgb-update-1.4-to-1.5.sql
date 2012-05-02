SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add links to references
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/blast/db/', reference_name = 'NCBI nr'	
    WHERE reference_name = 'NCBI-nr';
UPDATE reference SET reference_link = 'http://cegg.unige.ch/orthodb5/'	
    WHERE reference_name = 'OrthoDB';
UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/blast/db/'	
    WHERE reference_name = 'NCBI dbEST';

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
-- Add referencetags
-------------------------------------------------------------------
-------------------------------------------------------------------
--INSERT INTO referencetag (referencetag_name) VALUES ('OTU');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add filetypes and fileformats specific for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
--INSERT INTO filetype (filetype_name, filetype_help)
--  VALUES ('OrthoDB Mapping', 'Preprocessed OrthoDB Gene to Ortholog ID Mappings');
--INSERT INTO filetype (filetype_name, filetype_help)
--  VALUES ('OrthoDB Conserved Single Copy', 'OrthoDB conserved single copy genes for a given OTU.');

--INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary)
--  VALUES('OrthoDB Preprocessed Mapping', 'xxx', 'preprocessed for OrthoDB classification', TRUE);
--INSERT INTO fileformat (fileformat_name, fileformat_extension, fileformat_help, fileformat_isbinary)
--        VALUES('OrthoDB Conserved Single Copy List', 'xxx', 'Tab-delimeted list of OrthoDB conserved single copy genes', FALSE);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add referencetypes for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
--INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
--  VALUES ('OrthoDB Mapping Data',
--         (SELECT filetype_id FROM filetype WHERE filetype_name = 'OrthoDB Mapping'),
--         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'OrthoDB Preprocessed Mapping'));
--INSERT INTO referencetype (referencetype_name, filetype_id, fileformat_id)
--  VALUES ('OrthoDB Conserved Single Copy',
--         (SELECT filetype_id FROM filetype WHERE filetype_name = 'OrthoDB Conserved Single Copy'),
--         (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'OrthoDB Conserved Single Copy List'));

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add references for referencedb
-------------------------------------------------------------------
-------------------------------------------------------------------
--INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
--  VALUES('OrthoDB', '/nfs/bio/db/OrthoDB',
--         'OrthoDB presents a catalog of eukaryotic orthologous protein-coding genes across 44 vertebrates, 25 arthropods, and 46 fungi.',
--        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='OTU'));
--INSERT INTO reference (reference_name, reference_path, reference_description, referencetag_id)
--  VALUES('NCBI dbEST', '/nfs/bio/db/EST',
--         'dbEST contains sequence data and other information on "single-pass" cDNA sequences, or "Expressed Sequence Tags", from a number of organisms.',
--        (SELECT referencetag_id FROM referencetag WHERE referencetag_name='Collection'));
