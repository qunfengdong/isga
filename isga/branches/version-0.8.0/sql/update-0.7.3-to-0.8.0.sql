-------------------------------------------------------------------
-------------------------------------------------------------------
-- add notification type for gene details prepared
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO notificationtype ( notificationtype_name, notificationpartition_id, notificationtype_template, notificationtype_subject ) VALUES
( 'Gbrowse Instance Ready', (SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = 'RunNotification'), 'gbrowse_ready.mas', 'Your pipelines results have been loaded into Gbrowse.' );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- add request status stable
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE requeststatus (
 requeststatus_name TEXT PRIMARY KEY
);

INSERT INTO requeststatus ( requeststatus_name ) VALUES ( 'Not Requested' );
INSERT INTO requeststatus ( requeststatus_name ) VALUES ( 'Requested' );
INSERT INTO requeststatus ( requeststatus_name ) VALUES ( 'Processing' );
INSERT INTO requeststatus ( requeststatus_name ) VALUES ( 'Complete' );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- add additional usecases
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin) VALUES ('/submit/Workbench/Notify', 'WorkBench::Notify', TRUE);
DELETE FROM usecase WHERE usecase_name = '/blast_sample.fsa';
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin) VALUES ('/nucleotide_blast_sample.fna', 'Sample Data', TRUE);
INSERT INTO usecase (usecase_name, usecase_title, usecase_requireslogin) VALUES ('/amino_acid_blast_sample.fsa', 'Sample Data', TRUE);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Update Prokaryotic Pipeline Description
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE pipeline SET pipeline_description='The Prokaryotic Annotation Pipeline predicts ORFs using Glimmer3, performs sequence similarity searches using WU-BLAST, and performs protein domain searches using HMMPFAM. The pipeline also uses tRNA-scan and RNAMMER to predict RNA sequences and performs several other analysis to discover things such as signal peptides, transmembrane regions, report GO and EC numbers, etc. This information is then used to create a final pipeline summary.' WHERE pipeline_name = 'Prokaryotic Annotation Pipeline';


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add type infrormation for Genes
-------------------------------------------------------------------
-------------------------------------------------------------------
CREATE TABLE genetype ( 
 genetype_name TEXT PRIMARY KEY
);

INSERT INTO genetype ( genetype_name ) VALUES ( 'mRNA' );
INSERT INTO genetype ( genetype_name ) VALUES ( 'tRNA' );
INSERT INTO genetype ( genetype_name ) VALUES ( 'rRNA' );

ALTER TABLE gene ADD COLUMN gene_type TEXT REFERENCES genetype(genetype_name);

UPDATE gene SET gene_type = 'mRNA' WHERE genomefeature_id IN ( SELECT mrna_gene FROM mrna );
UPDATE gene SET gene_type = 'tRNA' WHERE genomefeature_id IN ( SELECT trna_gene FROM trna );
UPDATE gene SET gene_type = 'rRNA' WHERE genomefeature_id IN ( SELECT rrna_gene FROM rrna );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Delete Create usecases for PipelineBuilder and RunBuilder
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM usecase WHERE usecase_name = '/PipelineBuilder/Create';
DELETE FROM usecase WHERE usecase_name = '/RunBuilder/Create';
DELETE FROM usecase WHERE usecase_name = '/News/Resources';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Create usecase for Pipeline/ClusterOptions
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_requireslogin) VALUES ('/Pipeline/ClusterOptions', TRUE);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Update Workflow Coordinates for Input and Output
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE workflow SET workflow_coordinates = '260,0,455,53' WHERE cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name='Process Annotation Input Files');
UPDATE workflow SET workflow_coordinates = '150,448,575,560' WHERE cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name='Output');
