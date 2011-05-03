-- express pipeline

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'), '62,0,212,37');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search'), '0,121,116,158');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search'), '162,121,259,161');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'), '16,242,257,280');

-- prokaryote pipeline
INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Assembly'), '328,2,414,27');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'), '89,43,227,68');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Analysis'), '550,49,698,74');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Curation'), '133,168,257,193');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'HMM Search'), '2,190,113,215');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'BLAST Search'), '306,158,427,183');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Analysis'), '179,100,302,125');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'), '120,238,309,263');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Pathway & GO Analysis'), '21,318,235,343');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Terminator Motif Finder'), '498,160,700,185');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'RNA Motif Finder'), '385,230,531,255');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
     (SELECT cluster_id FROM cluster WHERE cluster_name = 'Intergenic Region Extraction'), '320,296,560,321');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Noncoding RNA Finder'), '150,362,339,387');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'RNA BLAST Conservation'), '380,362,592,387');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates ) 
  VALUES ( 
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'sRNA Prediction'), '492,421,631,446');
