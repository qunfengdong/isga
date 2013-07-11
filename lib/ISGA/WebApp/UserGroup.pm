## no critic
# we turn off perl critic because we package doesn't match file
package ISGA::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

ISGA::WebApp manages the interface to MASON for ISGA.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use Digest::SHA;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void Leave()

Remove yourself from a user group.

=cut
#------------------------------------------------------------------------
sub UserGroup::Leave {

  my $self = shift;

  my $group = $self->args->{user_group};
  my $account = ISGA::Login->getAccount;

  # make sure I am in this group
  $group->hasMember($account)
      or X::User::PermissionDenied->throw();

  $group->removeMember($account);

  $self->redirect(uri => "/Account/MyAccount");
}

#------------------------------------------------------------------------

=item public void RevokeInvitation()

Revoke an invitation to your user group.

=cut
#------------------------------------------------------------------------
sub UserGroup::RevokeInvitation {

  my $self = shift;

  my $invitation = $self->args->{user_group_invitation};
  my $group = $invitation->getUserGroup();

  # make sure I own this group
  ISGA::Login->getAccount == $group->getCreatedBy
      or X::User::PermissionDenied->throw();

  $invitation->delete();

  $self->redirect(uri => "/UserGroup/View?user_group=$group");
}

#------------------------------------------------------------------------

=item public void AcceptInvitation()

Accept an invitation to a group.

=cut
#------------------------------------------------------------------------
sub UserGroup::AcceptInvitation {

  my $self = shift;

  my $group = $self->args->{user_group};
  my $account = ISGA::Login->getAccount;

  # make sure I have an invitation
  my ($invitation) = @{ISGA::UserGroupInvitation->query( UserGroup => $group, Email => $account->getEmail)};
  $invitation or X::User::PermissionDenied->throw();

  $group->addMember($account);
  $invitation->delete();

  $self->redirect(uri => "/UserGroup/View?user_group=$group");
}

#------------------------------------------------------------------------

=item public void TransferInvitation()

Associate an invitation with your ISGA account.

=cut
#------------------------------------------------------------------------
sub UserGroup::TransferInvitation {

  my $self = shift;

  my $code = $self->args->{code};

  my $invitation = ISGA::UserGroupInvitation->new( Hash => $code );
  my $group = $invitation->getUserGroup;
  my $account = ISGA::Login->getAccount();

  if ( $invitation->getEmail ne $account->getEmail ) {

    # if the email belongs to someone else we can't do it
    ISGA::Account->exists( Email => $invitation->getEmail )
	and X::User::Denied->throw();
    
    # if the account is already invited to this group, delete the duplicate
    if ( ISGA::UserGroupInvitation->exists( UserGroup => $group, Email => $account->getEmail ) ) {
      $invitation->delete();
    } else {
      $invitation->edit( Email => $account->getEmail );
    }
  }
  
  $self->redirect(uri => "/UserGroup/View?user_group=$group");
}

#------------------------------------------------------------------------

=item public void Invite();

Invite an email address to join your User Group.

=cut
#------------------------------------------------------------------------
sub UserGroup::Invite {

  my $self = shift;
  my $web_args = $self->args;
  
  my $form = ISGA::FormEngine::UserGroup->Invite($web_args);

  my $group = $form->get_input('user_group');

  # make sure I own this group
  ISGA::Login->getAccount == $group->getCreatedBy
      or X::User::PermissionDenied->throw();

  if ( $form->canceled() ) {
    $self->redirect( uri => "/UserGroup/View?user_group=$group" );

  } elsif ( $form->ok ) {

    my @email;

    my $finder = Email::Find->new(sub { push( @email, ISGA::Utility->cleanEmail($_[0]) ); });

    foreach ( split(/\n/, $form->get_input('invite')) ) {   
      $finder->find(\$_);
    }

    foreach ( @email ) {

      next if ISGA::UserGroupInvitation->exists( UserGroup => $group, Email => $_ );

      # create a hash key for the invite
      my $code;
      do { 
	$code = substr(Digest::SHA::sha256_base64($group, $_, time), -8);
	$code =~ tr{+/}{-_};
      } while ( ISGA::UserGroupInvitation->exists(Hash => $code) );        
      
      if ( my ( $account ) = @{ISGA::Account->query( Email => $_ )} ) {
	next if $group->hasMember( $account );

	ISGA::UserGroupInvitation->create( UserGroup => $group,
					   Email => $_,
					   Hash => $code,
					   CreatedAt => ISGA::Timestamp->new()
					 );

	# send email
	ISGA::AccountNotification->create( Account => $account, Var1 => $group, 
					   Type => ISGA::NotificationType->new( Name => 'Group Invitation' ) );
	
      } else {

	ISGA::UserGroupInvitation->create( UserGroup => $group,
					   Email => $_,
					   Hash => $code,
					   CreatedAt => ISGA::Timestamp->new()
					 );
	
	ISGA::EmailNotification->create( Email => $_, Var1 => $group, Var2 => $code,
					 Type => ISGA::NotificationType->new( Name => 'Group Invitation by Email' ) );
	
      }
    } 

    $self->redirect( uri => "/UserGroup/View?user_group=$group" );
  }
  
  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/UserGroup/View?user_group=$group" );
}  

#------------------------------------------------------------------------

=item public void Edit();

Edits membership of a usergroup.

=cut
#------------------------------------------------------------------------
sub UserGroup::Edit {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::UserGroup->Edit($web_args);
  
  my $group = $form->get_input('user_group');

  if ( $form->canceled() ) {
    $self->redirect( uri => "/UserGroup/Edit?user_group=$group" );
  } elsif ( $form->ok ) {

    # edit privacy status
    $group->edit( IsPrivate => ! $form->get_input('sharename') );

    # process any removals
    foreach ( @{$form->get_inputs('accounts')} ) {
      $group->removeAccount($_);
    }

    # process any canceled invitations
    foreach ( @{$form->get_inputs('user_group_invitation')} ) {
      $_->delete;
    }

    # process any canceled invitations
    foreach ( @{$form->get_inputs('user_group_email_invitation')} ) {
      $_->delete;
    }

    # process new invitations
    foreach ( @{ISGA::Utility->parseAndCleanEmails( $form->get_input('invite') )} ) {

      # account invitations
      if ( my ( $account ) = @{ISGA::Account->query( Email => $_ )} ) {

	next if ISGA::UserGroupInvitation->exists( UserGroup => $group, Account => $account );
	next if $group->hasAccount( $account );

	ISGA::UserGroupInvitation->create( UserGroup => $group,
					       Account => $account,
					       CreatedAt => ISGA::Timestamp->new()
					     );
	
      # email invitations
      } else {

	next if 
	  ISGA::UserGroupEmailInvitation->exists( UserGroup => $group, Email => $_ );
	
	ISGA::UserGroupEmailInvitation->create( UserGroup => $group,
						    Email => $_,
						    CreatedAt => ISGA::Timestamp->new()
						  );
      }
    }

    $self->redirect( uri => "/UserGroup/Edit?user_group=$group" );
  }

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/UserGroup/Edit' );
}  


#------------------------------------------------------------------------

=item public void Create();

Create a new user group.

=cut
#------------------------------------------------------------------------
sub UserGroup::Create {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::UserGroup->Create($web_args);
  
  if ( $form->canceled() ) {
    
    $self->redirect( uri => '/Account/MyAccount' );
  } elsif ( $form->ok ) {
    
    my $name = $form->get_input('name');
    my $account = ISGA::Login->getAccount;
    
    my $group = ISGA::UserGroup->create( Name => $form->get_input('name'),
					 IsPrivate => ! $form->get_input('sharename'),
					 Status => ISGA::PartyStatus->new('Active'),
					 CreatedBy => $account );
    $group->addMember($account);
    
    $self->redirect( uri => "/UserGroup/View?user_group=$group" );
  }
  
  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/Account/EditMyDetails' );   
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
