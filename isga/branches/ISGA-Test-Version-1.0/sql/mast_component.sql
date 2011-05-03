--------------------------------------------------------------------
--------------------------------------------------------------------
-- Add cluster TFBS Search
--------------------------------------------------------------------
--------------------------------------------------------------------
-- Add File and Dictionary info
INSERT INTO fileformat ( fileformat_name, fileformat_extension, fileformat_help ) VALUES ('Mast Raw Result', 'xxx', ' MAST outputs a file containing: the version of MAST and the date it was built, the reference to cite if you use MAST in your research, a description of the database and motifs used in the search, an explanation of the result, high-scoring sequences--sequences matching the group of motifs above a stated level of statistical significance,  motif diagrams showing the order and spacing of occurrences of the motifs in the high-scoring sequences and,  annotated sequences showing the positions and p-values of all motif occurrences in each of the high-scoring sequences.
');

INSERT INTO filecontent ( filecontent_name, filecontent_help ) VALUES ('TFBS Motif Predictions', 'Predicted TFBS results produced by searching promoter regions against curated motifs using a program such as Mast.');

INSERT INTO filetype ( filetype_name, filetype_help, filecontent_id )
  VALUES ( 'TFBS Evidence', 'Collected evidence of TFBS',
   (SELECT filecontent_id FROM filecontent WHERE filecontent_name = 'TFBS Motif Predictions' ));


-- TFBS Search
INSERT INTO cluster ( cluster_name, cluster_formpath, cluster_description, cluster_layoutxml ) VALUES ( 'TFBS Search', 'TFBSSearch.yaml',
'The TFBS search cluster uses <a class="normal" href="http://www.ncbi.nlm.nih.gov/pubmed/9520501">Mast</a> to perfom a motif search against promoter regions of predicted ORFs using motifs from <a href="http://www.ncbi.nlm.nih.gov/pubmed/17142223">RegTransBase</a>.  The output is the raw Mast result in text format.',
' <commandSet type="serial">
   <state>incomplete</state>
   ___bsml2promoterregion.default___
   ___mast.default___
  </commandSet>
' );

-- Add component templates
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'bsml2promoterregion', 'mast.yaml' );
INSERT INTO componenttemplate ( componenttemplate_name, componenttemplate_formpath ) VALUES ( 'mast', '' );

-- Add components and cluster inputs and cluster outputs
INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'bsml2promoterregion.default', 'Extract Promoters for TFBS Search', FALSE, FALSE, 1,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'TFBS Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'bsml2promoterregion' ));

INSERT INTO componentinputmap ( component_id, clusterinput_id) VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'bsml2promoterregion.default' ),
    (SELECT clusterinput_id FROM clusterinput WHERE clusterinput_name = 'Gene_Prediction' ) );

INSERT INTO component ( component_ergatisname, component_name, component_isoptional, component_ishidden, component_index, cluster_id, componenttemplate_id )
  VALUES ( 'mast.default', '', FALSE, FALSE, 2,
  (SELECT cluster_id FROM cluster WHERE cluster_name = 'TFBS Search' ), ( SELECT componenttemplate_id FROM componenttemplate WHERE componenttemplate_name = 'mast' ));

INSERT INTO clusteroutput ( component_id, filetype_id, fileformat_id, clusteroutput_ergatisformat, outputvisibility_name, clusteroutput_fileloc)
  VALUES (
    (SELECT component_id FROM component WHERE component_ergatisname = 'mast.default'),
    (SELECT filetype_id FROM filetype WHERE filetype_name = 'TFBS Evidence'),
    (SELECT fileformat_id FROM fileformat WHERE fileformat_name = 'Mast Raw Result'),
    'File List', 'Evidence', 'mast/___id____default/mast.raw.list');

-- update global pipeline
UPDATE globalpipeline SET globalpipeline_layout = '<commandSetRoot xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="commandSet.xsd" type="instance">
 <commandSet type="serial">
  <state>incomplete</state>
  ___Process Annotation Input Files___
  <commandSet type="parallel">
   <state>incomplete</state> 
   ___Additional Genome Analysis___
   <commandSet type="serial">
    <state>incomplete</state>
    <name>start pipeline:</name>
    ___Gene Prediction___
    ___Process Gene Prediction___
    <commandSet type="parallel">
     <state>incomplete</state>
     ___Protein Domain Search___
     <commandSet type="serial">
      <state>incomplete</state>
      ___Sequence Similarity Search___
      ___Alternate Start Site Analysis___
     </commandSet>
      ___TFBS Search___
    </commandSet>
    ___Additional Gene Analysis___
    ___Predict Gene Function___ 
   </commandSet>
  </commandSet>
 </commandSet>
</commandSetRoot>'
WHERE pipeline_id = ( SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline');

-- insert into Workflow

INSERT INTO workflow ( pipeline_id, cluster_id, workflow_coordinates, workflow_isrequired )
  VALUES (
    (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline'),
    (SELECT cluster_id FROM cluster WHERE cluster_name = 'TFBS Search'), '1, 225, 116, 280', FALSE);

UPDATE workflow SET workflow_coordinates = '164, 106, 311, 161' WHERE pipeline_id = 
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline') 
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Gene Prediction');

UPDATE workflow SET workflow_coordinates = '331, 242, 641, 383' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline') 
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Gene Analysis');

UPDATE workflow SET workflow_coordinates = '131, 247, 288, 303' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Protein Domain Search');

UPDATE workflow SET workflow_coordinates = '256, 170, 431, 226' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Sequence Similarity Search');

UPDATE workflow SET workflow_coordinates = '502, 105, 647, 189' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Additional Genome Analysis');

UPDATE workflow SET workflow_coordinates = '323, 460, 561, 571' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Predict Gene Function');

UPDATE workflow SET workflow_coordinates = '325, 0, 510, 57' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Process Annotation Input Files');

UPDATE workflow SET workflow_coordinates = '' WHERE pipeline_id =
  (SELECT pipeline_id FROM pipeline WHERE pipeline_name = 'Prokaryotic Annotation Pipeline')
  AND cluster_id = (SELECT cluster_id FROM cluster WHERE cluster_name = 'Alternate Start Site Analysis');

