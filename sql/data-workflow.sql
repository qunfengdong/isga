-- express pipeline

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'), '141,1,290,36');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Protein Domain Search'), '0,135,160,198');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search'), '269,133,445,198');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'), '96,282,336,319');


-- annotation pipelines

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'), '89,17,232,57');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Genome Analysis'), '340,2,483,42');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Protein Domain Search'), '2,145,146,185');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search'), '354,86,497,126');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis'), '244,155,388,195');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), '138,231,282,271');

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryote Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'), '173,349,317,389');
