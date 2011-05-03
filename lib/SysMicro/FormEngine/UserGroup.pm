package SysMicro::FormEngine::UserGroup;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::UserGroup - provide user group forms.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public hashref form Create();

Builds a FormEngine object for creating new user groups.

=cut
#------------------------------------------------------------------------
sub Edit {

  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  my $group = $args->{user_group};

  my $members = [];
  my $sharename = ! $group->isPrivate;


  foreach ( @{$group->getAccounts} ) {

    push @$members, {
		     NAME => 'account',
		     TITLE => $_->getName,
		     templ => 'check',
		     VALUE => $_->getId,
		     OPTION => 'Remove'
		    };
    
  }

  @$members or push @$members, { templ => 'print', TITLE => 'No members' };


  my $invitations = [];

  foreach ( @{SysMicro::UserGroupInvitation->query( UserGroup => $group )} ) {

    my $account = $_->getAccount;

    push @$invitations, {
			 NAME => 'user_group_invitation',
			 TITLE => $account->getName,
			 templ => 'check',
			 VALUE => $_->getId,
			 OPTION => 'Remove',
			 ERROR => 'UserGroup::ownsInvitation'
			};
  }

  foreach ( @{SysMicro::UserGroupEmailInvitation->query( UserGroup => $group )} ) {
    
    push @$invitations, {
			 NAME => 'user_group_email_invitation',
			 TITLE => $_->getEmail,
			 templ => 'check',
			 VALUE => $_->getId,
			 OPTION => 'Remove',
			 ERROR => 'UserGroup::ownsInvitation'
			};
  } 
  
  @$invitations or push @$invitations, { templ => 'print',
					 TITLE => 'No outstanding invitations'
				       };

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Current Members',
      sub   => $members,
     },
     {
      templ => 'fieldset',
      TITLE => 'Current Invitations',
      sub   => $invitations,
     },
    {
      templ => 'fieldset',
      TITLE => 'Privacy Options',
      sub => 
      [
       { 
	NAME => 'sharename',
	TITLE => 'Share Name with Other Users',
	templ => 'check',
	VALUE => 1,
	OPT_VAL => $sharename,
	OPTION => '',
	HINT => 'Check this box to allow other users to see your group and request membership ( youmay deny requests ).'
       }
      ]
     },
     {
      templ => 'fieldset',
      TITLE => 'Invite New Members',
      sub   => 
      [
       {
	templ => 'textarea',
	ROWS => 10,
	COLS => 60,
	TITLE => 'Email address to invite',
	NAME => 'invite',
	ERROR => 'Text::checkHTML',
       }
      ]
     },
     { templ => 'hidden',
       NAME  => 'user_group',
       VALUE => $group,
       ERROR => ['not_null', 'UserGroup::isMine'],
     }
    );

  $form->conf( { ACTION => '/submit/UserGroup/Edit',
		 FORMNAME => 'user_group_edit',
		 SUBMIT => 'Edit Membership',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form Create();

Builds a FormEngine object for creating new user groups.

=cut
#------------------------------------------------------------------------
sub Create {

  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub => 
      [
       
        {
	NAME => 'name',
	TITLE => 'Name',
	SIZE => 60,
	MAXLEN => 60,
	REQUIRED => 1,
	LABEL => 'name',
	ERROR => ['not_null', 'Text::checkHTML', 'UserGroup::nameIsAvailable'],
	},

       {
	templ => 'print',
	TITLE => 'Owner',
	VALUE => SysMicro::Login->getAccount->getName
       },
      ],
     },

     {
      templ => 'fieldset',
      TITLE => 'Privacy Options',
      sub => 
      [
       { 
	NAME => 'sharename',
	TITLE => 'Share Name with Other Users',
	templ => 'check',
	VALUE => 1,
	HINT => 'Check this box to allow other users to see your group and request membership ( you may deny requests ).'
       }
      ]
     }

    );

  $form->conf( { ACTION => '/submit/UserGroup/Create',
		 FORMNAME => 'user_group_create',
		 SUBMIT => 'Create Group',
		 sub => \@form } );

  $form->make;
  return $form;
}

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, biohelp@cgb.indiana.edu

=cut
