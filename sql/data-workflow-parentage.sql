-- express workflow
INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')));

-- complete workflow

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES ( 
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Assembly')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Assembly')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Analysis')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Curation')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Curation')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Curation')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Analysis')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id =(SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Curation')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Analysis')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Curation')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Pathway & GO Analysis')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Assembly')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Terminator Motif Finder')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Assembly')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'RNA Motif Finder')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Intergenic Region Extraction')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Intergenic Region Extraction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Noncoding RNA Finder')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Intergenic Region Extraction')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'RNA BLAST Conservation')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Noncoding RNA Finder')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'sRNA Prediction')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'RNA BLAST Conservation')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'sRNA Prediction')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Terminator Motif Finder')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'sRNA Prediction')));

INSERT INTO workflowparentage ( workflow_parent, workflow_child ) VALUES (
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'RNA Motif Finder')),
  (SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'sRNA Prediction')));

