
-- account groups

INSERT INTO accountgroup ( accountgroup_name, accountgroup_description )
  VALUES ( 'News Administrators', 'Staff members that can post and edit news');
--INSERT INTO accountgroup ( accountgroup_name, accountgroup_description )
--  VALUES ( '', '');
--INSERT INTO accountgroup ( accountgroup_name, accountgroup_description )
--  VALUES ( '', '');

-- account group membership

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'News Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'chemmeri@indiana.edu' ) );

INSERT INTO groupmembership ( accountgroup_id, party_id )
  VALUES ( (SELECT accountgroup_id FROM accountgroup WHERE accountgroup_name = 'News Administrators' ),
  	   (SELECT party_id FROM account WHERE account_email = 'abuechle@indiana.edu' ) );
