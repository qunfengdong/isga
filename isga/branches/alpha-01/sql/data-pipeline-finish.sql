-- update pipeline with masks

UPDATE pipeline SET pipeline_workflowmask =
'--- !perl/SysMicro::WorkflowMask
start: [ ' || 

(SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'))

|| ', ' ||

(SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Genome Analysis'))

|| ', ' ||

(SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Terminator Motif Finder'))

|| ', ' ||

(SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'RNA Motif Finder'))

|| ', ' || ']
'
WHERE pipeline_name = 'Complete Prokaryote Annotation Pipeline';

-- express pipeline

UPDATE pipeline SET pipeline_workflowmask =
'--- !perl/SysMicro::WorkflowMask
start: [ ' || 
(SELECT workflow_id FROM workflow WHERE pipeline_id = (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline')
      AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction'))

|| ']
'
WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline';