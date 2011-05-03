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

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

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
      $group->addAccount($account);
      
      $self->redirect( uri => "/UserGroup/Edit?user_group=$group" );
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
