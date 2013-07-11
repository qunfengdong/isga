SET SESSION client_min_messages TO 'warning';

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Add use case for AJAX editing
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/Account/Edit', 'Account::Edit', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/PipelineBuilder/Edit', 'PipelineBuilder::Edit', TRUE, 'none');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Migrate iswalkthroughdisabled and iswalkthroughidden to account
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE account ADD COLUMN account_iswalkthroughdisabled BOOLEAN;
ALTER TABLE account ADD COLUMN account_iswalkthroughhidden BOOLEAN;
UPDATE account SET account_iswalkthroughdisabled = b.party_iswalkthroughdisabled, 
    account_iswalkthroughhidden = b.party_iswalkthroughhidden FROM party b
    WHERE account.party_id = b.party_id;
ALTER TABLE account ALTER COLUMN account_iswalkthroughdisabled SET NOT NULL;
ALTER TABLE account ALTER COLUMN account_iswalkthroughhidden SET NOT NULL;
ALTER TABLE party DROP COLUMN party_iswalkthroughdisabled;
ALTER TABLE party DROP COLUMN party_iswalkthroughhidden;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Convert all email addresses to lower case
-------------------------------------------------------------------
-------------------------------------------------------------------
UPDATE account SET account_email = lower(account_email);

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Remove subject line from notification types
-------------------------------------------------------------------
-------------------------------------------------------------------
ALTER TABLE notificationtype DROP COLUMN notificationtype_subject;

-------------------------------------------------------------------
-------------------------------------------------------------------
-- Combine usergroupinvitation and usergroupemailinvitation
-------------------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE usergroupemailinvitation;
DROP SEQUENCE usergroupemailinvitation_usergroupemailinvitation_id_seq;
DROP TABLE usergroupinvitation;
DROP sequence usergroupinvitation_usergroupinvitation_id_seq;

CREATE TABLE usergroupinvitation (
    usergroupinvitation_id SERIAL PRIMARY KEY,
    party_id integer REFERENCES usergroup(party_id) NOT NULL,
    usergroupinvitation_email TEXT NOT NULL,
    usergroupinvitation_hash CHAR(8) NOT NULL UNIQUE,
    usergroupinvitation_createdat TIMESTAMP NOT NULL DEFAULT 'now'
);

INSERT INTO notificationtype ( notificationtype_name, notificationtype_template, notificationpartition_id )
 VALUES ( 'Group Invitation', 'group_invitation.mas',
          (SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = 'AccountNotification'));

INSERT INTO notificationtype ( notificationtype_name, notificationtype_template, notificationpartition_id )
 VALUES ( 'Group Invitation by Email', 'group_email_invitation.mas',
          (SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = 'EmailNotification'));

INSERT INTO notificationtype ( notificationtype_name, notificationtype_template, notificationpartition_id )
 VALUES ( 'Group Membership Request', '',
          (SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = ''));

INSERT INTO notificationtype ( notificationtype_name, notificationtype_template, notificationpartition_id )
 VALUES ( '', '', 
          (SELECT notificationpartition_id FROM notificationpartition WHERE notificationpartition_name = ''),

-------------------------------------------------------------------
-------------------------------------------------------------------
-- use cases for invitations
-------------------------------------------------------------------
-------------------------------------------------------------------
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/UserGroup/Invite', 'UserGroup::Invite', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/UserGroup/RevokeInvitation', 'UserGroup::RevokeInvitation', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/UserGroup/AcceptInvitation', 'UserGroup::AcceptInvitation', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/UserGroup/TransferInvitation', 'UserGroup::TransferInvitation', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/UserGroup/Leave', 'UserGroup::LeaveGroup', TRUE, 'none');

INSERT INTO usecase (usecase_name, usecase_requireslogin, usecase_title, usecase_stylesheet) 
  VALUES ('/UserGroup/ViewInvitation', FALSE, 'View Group Invitation', '2columnright');


INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/UserGroup/', 'UserGroup::', TRUE, 'none');
INSERT INTO usecase (usecase_name, usecase_action, usecase_requireslogin, usecase_stylesheet) 
  VALUES ('/submit/UserGroup/', 'UserGroup::', TRUE, 'none');

-------------------------------------------------------------------
-------------------------------------------------------------------
-- remove usecases that are no longer needed because of new modals
-------------------------------------------------------------------
-------------------------------------------------------------------
DELETE FROM usecase WHERE usecase_name = ('/LoginSuccess');
DELETE FROM usecase WHERE usecase_name = ('/LoginError');
DELETE FROM usecase WHERE usecase_name = ('/PipelineBuilder/ConfirmFinalize');
DELETE FROM usecase WHERE usecase_name = ('/PipelineBuilder/Cancel');
DELETE FROM usecase WHERE usecase_name = ('/Account/EditMyDetails');
DELETE FROM usecase WHERE usecase_name = ('/submit/Account/EditMyDetails');

DELETE FROM usecase WHERE usecase_name = ('/PipelineBuilder/EditDetails');
DELETE FROM usecase WHERE usecase_name = ('/submit/PipelineBuilder/EditDetails');
DELETE FROM usecase WHERE usecase_name = ('');
DELETE FROM usecase WHERE usecase_name = ('');
