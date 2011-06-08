---- test case
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Test/Ajax', FALSE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/index.html', FALSE, 'Home', '2columnright');
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/error.html', FALSE, 'Error', '1column');

-------- Account
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Overview', FALSE, 'Accounts Overview', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Request', FALSE, 'Request Account', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Requested', FALSE, 'Requested Account', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Confirmed', FALSE, 'Confirm Account Request', '1column' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/MyAccount', TRUE, 'My Account', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/LostPassword', FALSE, 'Lost Password Help', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/PasswordChangeSent', FALSE, 'Password Change Sent', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/ResetPassword', FALSE, 'Password Reset Form', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/PasswordResetCompleted', FALSE, 'Password Successfully Reset', '1column' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/EditMyDetails', TRUE, 'Edit My Account', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/ChangeMyPassword', TRUE, 'Change My Password', '2columnright' );

-- AJAX & Forms
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/Request', 'Account::Request', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/Confirm', 'Account::Confirm', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/LostPassword', 'Account::LostPassword', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/ResetPassword', 'Account::ResetPassword', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/ChangeMyPassword', 'Account::ChangeMyPassword', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/EditMyDetails', 'Account::EditMyDetails', FALSE );

-------- Cluster

-- AJAX & Forms
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Cluster/GetParameterDescription', FALSE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Cluster/GetClusterDescription', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Cluster/Configure', 'Cluster::Configure', TRUE );

-------- File
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/File/Overview', FALSE, 'File Overview', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/File/BrowseMy', TRUE, 'List My Files', '1column' );

-------- FileContent
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/FileContent/ViewHelp', FALSE );

-------- FileFormat
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/FileFormat/ViewHelp', FALSE );

-------- FileType
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/FileType/ViewHelp', FALSE );

-------- Pipeline
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/Overview', 'Pipeline', FALSE, 'Pipelines', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/View', FALSE, 'Pipeline', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewWorkflow', FALSE, 'Pipeline Image', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/List', TRUE, 'List Public Pipelines', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ListMy', TRUE, 'List My Pipelines', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewInputs', TRUE, 'Pipeline Inputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewOutputs', TRUE, 'Pipeline Outputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewClusters', TRUE, 'Select A Cluster', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewParameters', TRUE, 'View Program Parameters', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin ) VALUES ( '/Pipeline/GetDescription', FALSE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Pipeline/DrawWorkflow', TRUE);

-------- PipelineBuilder

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/Create', TRUE, 'Build a Pipeline', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/EditDetails', TRUE, 'Pipeline Builder Details', '2columnright'  );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/Overview', TRUE, 'Pipeline Builder Overview', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/EditWorkflow', TRUE, 'Pipeline Builder Workflow', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ViewClusters', TRUE, 'Pipeline Builder Clusters', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/EditCluster', TRUE, 'Pipeline Builder Edit Cluster', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/AnnotateCluster', TRUE, 'Pipeline Builder Annotate Cluster', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ViewInputs', TRUE, 'Pipeline Builder Inputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ViewOutputs', TRUE, 'Pipeline Builder Outputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/Success', TRUE, 'Pipeline Created', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ListMy', 'MyAccount', TRUE, 'List My Pipeline Builders', '1column' );

-- AJAX & Forms
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/DrawWorkflow', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/UpdateWorkflow', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/DrawClusters', TRUE);

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/Create', 'PipelineBuilder::Create', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/AnnotateCluster', 'PipelineBuilder::AnnotateCluster', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/EditCluster', 'PipelineBuilder::EditCluster', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/EditWorkflow', 'PipelineBuilder::EditWorkflow', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/Finalize', 'PipelineBuilder::Finalize', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/EditDetails', 'PipelineBuilder::EditDetails', TRUE);

------ Run
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/View', TRUE, 'View Run', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/Overview', FALSE, 'Run Overview', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/ListMy', TRUE, 'List My Runs', '1column' );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Run/Submit', 'Run::Submit', TRUE );

------ RunBuilder

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/View', TRUE, 'Select Run Inputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/Create', TRUE, 'Create a New Run', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/EditDetails', TRUE, 'Edit Run Details', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/ListMy', TRUE, 'View Runs Being Built', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/UploadFile', TRUE, 'File Upload', '1column' );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/SelectInput', 'RunBuilder::SelectInput', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/EditDetails', 'RunBuilder::EditDetails', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/Create', 'RunBuilder::Create', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/Cancel', 'RunBuilder::Cancel', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/UploadFile', 'RunBuilder::UploadFile', TRUE );

-- Support

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Support/Overview', FALSE, 'Support Overview', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Support/ContactUs', FALSE, 'Send Feedback', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Support/FeedbackSent', FALSE, 'Feedback Sent', '1column' );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Support/ContactUs', 'Support::ContactUs', FALSE );

-- Login
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Login', 'Login', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Logout', 'Logout', TRUE );


-- UserGroup

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/Create', TRUE, 'Create new Group', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/Edit', TRUE, 'Edit a Group', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/View', TRUE, 'View a Group', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/Overview', FALSE, 'Group Details', '1column' );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/UserGroup/Create', 'UserGroup::Create', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/UserGroup/Edit', 'UserGroup::Edit', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/UserGroup/Leave', 'UserGroup::Leave', TRUE );




--INSERT INTO usecase 
--    ( usecase_name, usecase_requireslogin, usecase_description )
--  VALUES ( '/', '', FALSE, '' );

--INSERT INTO usecase 
--    ( usecase_name, usecase_requireslogin, usecase_description )
--  VALUES ( '/', '', TRUE, '' );
--INSERT INTO grouppermission (accountgroup_id, usecase_id)
--  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE
--            accountgroup_name = '' ),
--           (SELECT usecase_id FROM usecase WHERE 
--            usecase_name = '' ));
