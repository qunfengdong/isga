-------------------------------------------------------------------
-------------------------------------------------------------------
-- User Classes
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE userclass SET userclass_name = 'External User', userclass_description =
'Users that are not affiliates or customers of the Center for Genomics and Bioinformatics.' 
  WHERE userclass_name = 'Default User';

INSERT INTO userclass ( userclass_name, userclass_description ) VALUES (
'CGB Affiliate', 'Users that are affiliated with the Center for Genomics and Bioinformatics');

INSERT INTO userclass ( userclass_name, userclass_description ) VALUES (
'CGB Customer', 'Users that are customers of the Center for Genomics and Bioinformatics');


INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Chris Hemmerich', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'chemmeri@indiana.edu', '202cb962ac59075b964b07152d234b70',
           (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate') );


INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Aaron Buechlein', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'abuechle@indiana.edu', '202cb962ac59075b964b07152d234b70', 
           (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate') );
	
INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden  )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
           'Ram Podicheti', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password, userclass_id )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'mnrusimh@indiana.edu', '202cb962ac59075b964b07152d234b70', 
            (SELECT userclass_id FROM userclass WHERE userclass_name = 'CGB Affiliate') );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'News Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'News Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Run Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu' ) );

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu'));

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu'));



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

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Edit CGB Contact Address
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE siteconfiguration SET siteconfiguration_value = 'biohelp@cgb.indiana.edu'
  FROM configurationvariable b 
  WHERE siteconfiguration.configurationvariable_id = b.configurationvariable_id AND b.configurationvariable_name = 'support_email';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add User Classes
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE userclass SET userclass_name = 'External User', userclass_description =
'Users that are not affiliates or customers of the Center for Genomics and Bioinformatics.' 
  WHERE userclass_name = 'Default User';

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu'));

INSERT INTO groupmembership (accountgroup_id, party_id) VALUES (
(SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'Policy Administrators'),
(SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu'));

SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Edit CGB Contact Address
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE siteconfiguration SET siteconfiguration_value = 'biohelp@cgb.indiana.edu'
  FROM configurationvariable b 
  WHERE siteconfiguration.configurationvariable_id = b.configurationvariable_id AND b.configurationvariable_name = 'support_email';