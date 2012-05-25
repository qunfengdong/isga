SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add links to references
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/blast/db/', reference_name = 'NCBI nr'	
    WHERE reference_name = 'NCBI-nr';

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
-- Fix typo fixes
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE filetype SET filetype_help = 'This is the raw results produced by HMMER. For detailed information, please see this pdf document: ftp://selab.janelia.org/pub/hmmer/CURRENT/Userguide.pdf' WHERE filetype_name = 'HMM Search Result';

UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/' WHERE reference_name = 'Homo Sapien';