## no critic
# we turn off perl critic because we package doesn't match file
package SysMicro::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

SysMicro::WebApp manages the interface to MASON for SysMicro.

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
  my $form = SysMicro::FormEngine::UserGroup->Edit($web_args);
  
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
    foreach ( @{SysMicro::Utility->parseAndCleanEmails( $form->get_input('invite') )} ) {

      # account invitations
      if ( my ( $account ) = @{SysMicro::Account->query( Email => $_ )} ) {

	next if SysMicro::UserGroupInvitation->exists( UserGroup => $group, Account => $account );
	next if $group->hasAccount( $account );

	SysMicro::UserGroupInvitation->create( UserGroup => $group,
					       Account => $account,
					       CreatedAt => SysMicro::Timestamp->new()
					     );
	
      # email invitations
      } else {

	next if 
	  SysMicro::UserGroupEmailInvitation->exists( UserGroup => $group, Email => $_ );
	
	SysMicro::UserGroupEmailInvitation->create( UserGroup => $group,
						    Email => $_,
						    CreatedAt => SysMicro::Timestamp->new()
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
    my $form = SysMicro::FormEngine::UserGroup->Create($web_args);

    if ( $form->canceled() ) {

      $self->redirect( uri => '/Account/MyAccount' );
    } elsif ( $form->ok ) {

      my $name = $form->get_input('name');
      my $account = SysMicro::Login->getAccount;

      my $group = SysMicro::UserGroup->create( Name => $form->get_input('name'),
					       IsPrivate => ! $form->get_input('sharename'),
					       Status => SysMicro::PartyStatus->new('Active'),
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
