-- pipeline
INSERT INTO pipeline ( pipelinepartition_id, pipeline_name, pipeline_workflowmask, pipeline_description, pipelinestatus_id  )
  VALUES ( ( SELECT pipelinepartition_id FROM pipelinepartition WHERE pipelinepartition_name = 'GlobalPipeline' ),
	   'Complete Prokaryote Annotation Pipeline', '',
           '<p>This is the full annotation pipeline. It will predict protein function as well as perform pathway analysis, sRNA prediction, and other analyses at the genome and gene level.</p>',
	   ( SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Available' )
);

INSERT INTO globalpipeline ( pipeline_id, globalpipeline_image, globalpipeline_layout )
  VALUES ( (SELECT CURRVAL('pipeline_pipeline_id_seq')), '/include/img/fullpipeline.png', '' );



-- pipeline
INSERT INTO pipeline ( pipelinepartition_id, pipeline_name, pipeline_workflowmask, pipeline_description, pipelinestatus_id )
  VALUES ( ( SELECT pipelinepartition_id FROM pipelinepartition WHERE pipelinepartition_name = 'GlobalPipeline' ),
	      'Express Prokaryote Annotation Pipeline', '',
	      '<p>Detects ORFs in the provided sequence and then uses sequence familiarity and Hidden Markov Models to predict protein fuction for found genes.</p>',
           ( SELECT pipelinestatus_id FROM pipelinestatus WHERE pipelinestatus_name = 'Available' )
 );

INSERT INTO globalpipeline ( pipeline_id, globalpipeline_image, globalpipeline_layout )
  VALUES ( (SELECT CURRVAL('pipeline_pipeline_id_seq')), '/include/img/express-pipeline.png', 

'
<commandSetRoot xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="commandSet.xsd" type="instance">
 <commandSet type="serial">
  <state>incomplete</state>
  <name>start pipeline:</name>
___Gene Prediction___
 <commandSet type="parallel">
  <state>incomplete</state>
___HMM Search___
___BLAST Search___
 </commandSet>
___Predict Gene Function___ 
 </commandSet>
</commandSetRoot>
'
 );

INSERT INTO pipelineinput (pipeline_id, filetype_id, inputdependency_id, fileformat_id, clusterinput_id, pipelineinput_ergatisformat)
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Express Prokaryote Annotation Pipeline'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'Assembled Genome Fasta'),
    (SELECT inputdependency_id FROM inputdependency WHERE inputdependency_name = 'Required'),
    (SELECT clusterinput_id FROM clusterinput WHERE cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction') 
                            AND filetype_id = (SELECT filetype_id FROM filetype WHERE filetype_name = 'Assembled Genome Fasta')),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'FASTA'),
    'File List');
