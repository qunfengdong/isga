--
INSERT INTO party ( partypartition_id, party_name, partystatus_id, party_institution, party_isprivate, 
                    party_iswalkthroughdisabled, party_iswalkthroughhidden ) VALUES ( 
  ( SELECT partypartition_id FROM partypartition WHERE partypartition_name = 'UserGroup' ),
  'Spring 2011 Prokaryotic Annotation Workshop',
  ( SELECT partystatus_id FROM  partystatus WHERE partystatus_name = 'Active' ),
  'Center for Genomics and Bioinformatics',
  FALSE,
  FALSE,
  FALSE
  );

INSERT INTO usergroup ( party_id, account_id ) VALUES ( ( SELECT CURRVAL('party_party_id_seq')), 
       (SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu' ));

INSERT INTO usergroupmembership ( usergroup_id, member_id ) VALUES ( ( SELECT CURRVAL('party_party_id_seq')),
       (SELECT party_id FROM account WHERE account_email = 'chemmeri@cgb.indiana.edu' ));


INSERT INTO resourceshare ( resourcesharepartition_id, party_id )
  VALUES ( ( SELECT resourcesharepartition_id FROM resourcesharepartition WHERE resourcesharepartition_name = 'RunShare' ),
           ( SELECT party_id FROM party WHERE party_name = 'Spring 2011 Prokaryotic Annotation Workshop' ) );

INSERT INTO runshare ( resourceshare_id, run_id ) VALUES ( (SELECT CURRVAL('resourceshare_resourceshare_id_seq')), 1);
