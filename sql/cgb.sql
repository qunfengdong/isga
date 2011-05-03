INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Chris Hemmerich', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'chemmeri@indiana.edu', '202cb962ac59075b964b07152d234b70' );


INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Aaron Buechlein', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'abuechle@indiana.edu', '202cb962ac59075b964b07152d234b70' );
	
INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden  )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
  	   'Qunfeng Dong', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'qfdong@indiana.edu', '202cb962ac59075b964b07152d234b70' );

INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden  )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
           'Ram Podicheti', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'mnrusimh@indiana.edu', '202cb962ac59075b964b07152d234b70' );

INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, party_iswalkthroughdisabled, party_iswalkthroughhidden  )
  VALUES ( (SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'Account' ),
           'Kashi', (SELECT partystatus_id FROM partystatus WHERE partystatus_name = 'Active'), 'Center for Genomics and Bioinformatics', FALSE, FALSE, FALSE );
INSERT INTO account ( party_id, account_email, account_password )
  VALUES ( (SELECT CURRVAL('party_party_id_seq')),'krevanna@indiana.edu', '202cb962ac59075b964b07152d234b70' );

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
