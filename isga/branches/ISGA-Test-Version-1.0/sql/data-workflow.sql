-- annotation pipelines

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'), '89,17,232,57', FALSE);

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Genome Analysis'), '340,2,483,42', FALSE);

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Protein Domain Search'), '2,145,146,185', TRUE);

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search'), '354,86,497,126', TRUE);

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis'), '244,155,388,195', FALSE);

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis'), '138,231,282,271', FALSE);

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function'), '173,349,317,389', TRUE);
