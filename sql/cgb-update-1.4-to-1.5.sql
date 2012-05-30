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
UPDATE fileformat SET fileformat_extension = 'raw' WHERE fileformat_name = 'TargetP Raw Result';

UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/genomes/H_sapiens/' WHERE reference_name = 'Homo Sapien';
UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/genomes/Arabidopsis_thaliana/' WHERE reference_name = 'Arabidopsis thaliana';
UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/genomes/Drosophila_melanogaster/' WHERE reference_name = 'Drosophila melanogaster';
UPDATE reference SET reference_link = 'ftp://ftp.ncbi.nih.gov/genomes/Caenorhabditis_elegans/' WHERE reference_name = 'Caenorhabditis elegans';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- asgard_simple and lipop have broken component_templates
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE componenttemplate SET componenttemplate_name = 'asgard_simple'
 WHERE componenttemplate_name = 'asgard' AND ergatisinstall_id = 
        ( SELECT ergatisinstall_id FROM ergatisinstall WHERE ergatisinstall_name = 'ergatis-v2r11-cgbr1' );
UPDATE componenttemplate SET componenttemplate_name = 'lipop' WHERE componenttemplate_name = 'lipoprotein_motif';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- add an index on filecollectioncontent_child
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE INDEX filecollectioncontent_child_index ON filecollectioncontent(filecollectioncontent_child);