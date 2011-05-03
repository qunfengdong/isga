---- /
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/index.html', FALSE, 'Home', '2columnright', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/Home', FALSE, 'Home', '2columnright', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Error', FALSE, 'Error', '2columnright');
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/LoginSuccess', FALSE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/LoginError', FALSE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Success', FALSE );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Login', 'Login', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Logout', 'Logout', TRUE );


-------- Account
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Overview', FALSE, 'Accounts Overview', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Request', FALSE, 'Request Account', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Requested', FALSE, 'Requested Account', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/Confirmed', FALSE, 'Confirm Account Request', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/MyAccount', TRUE, 'My Account', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/LostPassword', FALSE, 'Lost Password Help', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/PasswordChangeSent', FALSE, 'Password Change Sent', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/ResetPassword', FALSE, 'Password Reset Form', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/PasswordResetCompleted', FALSE, 'Password Successfully Reset', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/EditMyDetails', TRUE, 'Edit My Account', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Account/ChangeMyPassword', TRUE, 'Change My Password', '2columnright' );

-- AJAX & Forms
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/Request', 'Account::Request', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/Confirm', 'Account::Confirm', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/LostPassword', 'Account::LostPassword', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/ResetPassword', 'Account::ResetPassword', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/ChangeMyPassword', 'Account::ChangeMyPassword', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/EditMyDetails', 'Account::EditMyDetails', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Account/ShowHideWalkthrough', 'Account::ShowHideWalkthrough', FALSE );

-------- Cluster

-- AJAX & Forms
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Cluster/GetClusterDescription', FALSE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Cluster/Configure', 'Cluster::Configure', TRUE );

-------- Component
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Component/GetParameterDescription', FALSE );


-------- FileCollection
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) 
     VALUES ( '/FileCollection/View', TRUE, 'File Collection Details', '2columnright' );


-------- File
    INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/File/Overview', FALSE, 'File Overview', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/File/BrowseMy', TRUE, 'List My Files', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/File/View', TRUE, 'File Details', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/File/EditDescription', TRUE, 'Edit File Description', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/File/Upload', TRUE, 'File Upload', '2columnright' );


-- File Table Ajax Sort
INSERT INTO usecase ( usecase_name, usecase_requireslogin ) VALUES ( '/File/BrowseMySort', TRUE );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/File/Upload', 'File::Upload', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/File/Hide', 'File::Hide', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/File/Restore', 'File::Restore', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/File/EditDescription', 'File::EditDescription', TRUE );

-------- FileContent
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/FileContent/ViewHelp', FALSE );

-------- FileFormat
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/FileFormat/ViewHelp', FALSE );

-------- FileType
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/FileType/ViewHelp', FALSE );

-- Help

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Help/ContactUs', FALSE, 'Send Feedback', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Help/FAQ', FALSE, 'FAQs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Help/FeedbackSent', FALSE, 'Feedback Sent', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Help/Introduction', FALSE, 'Site Introduction', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Help/Tutorial', FALSE, 'Tutorials', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Help/KnownIssues', FALSE, 'Known Issues', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Help/Overview', FALSE, 'Help Overview', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Help/ContactUs', 'Help::ContactUs', FALSE );

-- News

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/News/Recent', FALSE, 'Recent News', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/News/AboutUs', FALSE, 'About Us', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/News/Resources', FALSE, 'Pipeline Resources', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/News/Archive', FALSE, 'News Archive', '2columnright' );

-------- Pipeline
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/Pipeline/List', FALSE, 'Pipeline List', '2columnright', TRUE );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/Pipeline/View', FALSE, 'Pipeline', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewInputs', FALSE, 'Pipeline Inputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewOutputs', FALSE, 'Pipeline Outputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewClusters', TRUE, 'Select A Cluster', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewParameters', TRUE, 'View Program Parameters', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Pipeline/ViewComponents', TRUE, 'View Cluster Components', '2columnright' );

-- Ajax
INSERT INTO usecase ( usecase_name, usecase_requireslogin ) VALUES ( '/Pipeline/GetDescription', FALSE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Pipeline/DrawWorkflow', FALSE);

-------- PipelineBuilder

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/Create', TRUE, 'Build a Pipeline', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/EditDetails', TRUE, 'Pipeline Builder Details', '2columnright'  );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/Overview', TRUE, 'Pipeline Builder Overview', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/EditWorkflow', TRUE, 'Pipeline Builder Workflow', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/ViewClusters', TRUE, 'Pipeline Builder Clusters', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/EditCluster', TRUE, 'Pipeline Builder Edit Cluster', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/EditComponent', TRUE, 'Pipeline Builder Edit Component', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/AnnotateCluster', TRUE, 'Pipeline Builder Annotate Cluster', '2columnright', TRUE )
;
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/Status', TRUE, 'Pipeline Customization', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ViewInputs', TRUE, 'Pipeline Builder Inputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ViewOutputs', TRUE, 'Pipeline Builder Outputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/PipelineBuilder/Success', TRUE, 'Pipeline Created', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/ListMy', TRUE, 'List My Pipeline Builders', '2columnright' );
--INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/PipelineBuilder/Cancel', TRUE, 'Pipeline Builder Cancel', '2columnright' );

-- AJAX & Forms
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/DrawWorkflow', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/DrawClusters', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/ChooseComponent', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/Cancel', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/PipelineBuilder/ConfirmFinalize', TRUE);


INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/Create', 'PipelineBuilder::Create', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/AnnotateCluster', 'PipelineBuilder::AnnotateCluster', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/EditCluster', 'PipelineBuilder::EditCluster', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/EditWorkflow', 'PipelineBuilder::EditWorkflow', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/Finalize', 'PipelineBuilder::Finalize', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/EditDetails', 'PipelineBuilder::EditDetails', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/Remove', 'PipelineBuilder::Remove', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/EditComponent', 'PipelineBuilder::EditComponent', TRUE);
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/PipelineBuilder/ChooseComponent', 'PipelineBuilder::ChooseComponent', TRUE);

------ Run
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/View', TRUE, 'View Run', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/Overview', FALSE, 'Run Overview', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/ListMy', TRUE, 'List My Runs', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/MyResults', TRUE, 'Summarize Results', '1column' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/Run/Status', TRUE, 'Runs', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/Run/GetOutputs', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin ) VALUES ( '/Run/GetDescription', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/Run/Submit', 'Run::Submit', TRUE );


------ RunBuilder

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/RunBuilder/View', TRUE, 'View RunBuilder Status', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/RunBuilder/Create', TRUE, 'Create a New Run', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/EditDetails', TRUE, 'Edit Run Details', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/RunBuilder/EditParameters', TRUE, 'Edit Run Parameters', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/ListMy', TRUE, 'View Runs Being Built', '2columnright' );
--INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/ViewInputs', TRUE, 'View Run Inputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/SelectInput', TRUE, 'Select Run Inputs', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet, usecase_hasdocumentation ) VALUES ( '/RunBuilder/SelectInputList', TRUE, 'Select Run Inputs', '2columnright', TRUE );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/RunBuilder/UploadFile', TRUE, 'File Upload', '2columnright' );

INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/SelectInput', 'RunBuilder::SelectInput', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/SelectInputList', 'RunBuilder::SelectInputList', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/EditDetails', 'RunBuilder::EditDetails', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/EditParameters', 'RunBuilder::EditParameters', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/Create', 'RunBuilder::Create', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/Cancel', 'RunBuilder::Cancel', TRUE );
INSERT INTO usecase ( usecase_name, usecase_action, usecase_requireslogin) VALUES ( '/submit/RunBuilder/UploadFile', 'RunBuilder::UploadFile', TRUE );

------ RunBuilder AJAX
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/RunBuilder/Cancel', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/RunBuilder/ViewInputs', TRUE);
INSERT INTO usecase ( usecase_name, usecase_requireslogin) VALUES ( '/RunBuilder/Submit', TRUE);

-- Login

-- UserGroup

INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/Create', TRUE, 'Create new Group', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/Edit', TRUE, 'Edit a Group', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/View', TRUE, 'View a Group', '2columnright' );
INSERT INTO usecase ( usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet ) VALUES ( '/UserGroup/Overview', FALSE, 'Group Details', '2columnright' );

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

