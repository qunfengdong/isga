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
