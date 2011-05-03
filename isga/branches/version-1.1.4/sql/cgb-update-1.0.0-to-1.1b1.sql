-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add User Classes
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE userclass SET userclass_name = 'External User', userclass_description =
'Users that are not affiliates or customers of the Center for Genomics and Bioinformatics.' 
  WHERE userclass_name = 'Default User';

INSERT INTO userclass ( userclass_name, userclass_description ) VALUES (
'CGB Affiliate', 'Users that are affiliated with the Center for Genomics and Bioinformatics');

INSERT INTO userclass ( userclass_name, userclass_description ) VALUES (
'CGB Customer', 'Users that are customers of the Center for Genomics and Bioinformatics');


INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu'));

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu'));

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Change Default User Site Configuration
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE siteconfiguration SET siteconfiguration_value = 'External User' WHERE configurationvariable_id = 
  ( SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'default_user_class' );

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add User Class Configuration settings
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'raw_data_retention'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate'),		      
  '90');

INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'raw_data_retention'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Customer'),		      
  '90');

INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'pipeline_quota'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate'),		      
  '3');

INSERT INTO userclassconfiguration (configurationvariable_id, userclass_id, userclassconfiguration_value) VALUES (
 (SELECT configurationvariable_id FROM configurationvariable WHERE configurationvariable_name = 'pipeline_quota'),
 (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Customer'),		      
  '2');