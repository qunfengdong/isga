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

use Digest::MD5;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void EditMyDetails();

Edit account details.

=cut
#------------------------------------------------------------------------
sub Account::EditMyDetails {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Account->EditMyDetails($web_args);

  if ( $form->canceled ) {
    $self->redirect( uri => '/Account/MyAccount' );
  } elsif ( $form->ok ) {

    my $disablewalkthrough =  $form->get_input('disablewalkthrough');
    my $account = ISGA::Login->getAccount;
    $account->edit( Name => $form->get_input('name'),
		    Institution => $form->get_input('institution'),
		    IsWalkthroughDisabled => $disablewalkthrough,
		    Email => $form->get_input('email') );
    
    $self->redirect( uri => '/Account/MyAccount' );
  }
    
  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/Account/EditMyDetails' );
}   

#------------------------------------------------------------------------

=item public void ChangeMyPassword();

Change an accounts password.

=cut
#------------------------------------------------------------------------
sub Account::ChangeMyPassword {
  
  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Account->ChangeMyPassword($web_args);

  if ( $form->canceled ) {
    $self->redirect( uri => '/Account/MyAccount' );
  } elsif ( $form->ok ) {

    my $account = ISGA::Login->getAccount;
    $account->edit( Password => Digest::MD5::md5_hex($form->get_input('password')) );
    
    $self->redirect( uri => '/Account/MyAccount' );
  }

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/Account/ChangeMyPassword' );
}

#------------------------------------------------------------------------

=item public void ResetPassword();

Complete the password reset procedure.

=cut
#------------------------------------------------------------------------
sub Account::ResetPassword {
  
  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Account->ResetPassword($web_args);

  if ( $form->canceled ) {
    $self->redirect( uri => "/Home" );
  } elsif ( $form->ok ) {

    my ($request) = @{ISGA::PasswordChangeRequest->query( Hash => $form->get_input('hash'))};
    $request->getAccount->edit( Password => Digest::MD5::md5_hex($form->get_input('password')));
    
    $self->redirect( uri => '/Account/PasswordResetCompleted' );
  }

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/Account/ResetPassword' );
}

#------------------------------------------------------------------------

=item public void LostPassword();

Submit a request for a lost password recovery link.

=cut
#------------------------------------------------------------------------
sub Account::LostPassword {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Account->LostPassword($web_args);
 
  if ( $form->canceled ) {

    $self->redirect( uri => "/Home" );

  } elsif ( $form->ok ) {

    my $email = ISGA::Utility->cleanEmail($form->get_input('email'));

    my ($account) = @{ISGA::Account->query( Email => $email )};

    # if the account doesn't exist, die quietly
    # this is a security feature at the cost of usability, maybe need
    # to reevaluate
    $account or $self->redirect( uri => '/Account/PasswordChangeSent' );

    # see if a request already exists
    my ($request) = @{ISGA::PasswordChangeRequest->query(Account => $account)};
    
    # check to see if old request exists
    if ( $request ) {
      
      # check for expiration
      if ( $request->isExpired ) {
	$request->delete();
      } else {
	$self->redirect( uri => "/Account/PasswordChangeSent?password_change_request=$request" );
      }
    }

    # generate a unique code for the request
    my $code;
    do { 
      $code = Digest::MD5::md5_base64($email, time);
    } while ( ISGA::PasswordChangeRequest->exists(Hash => $code) );    
    $code =~ s/\+/-/go;
    $code =~ s/\//_/go;     
    
    # add the entry
    $request = ISGA::PasswordChangeRequest->create(Hash => $code, 
						       CreatedAt => ISGA::Timestamp->new,
						       Account => $account );

    $self->redirect( uri => "/Account/PasswordChangeSent?password_change_request=$request" );
  }

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/Account/LostPassword' );
}

#------------------------------------------------------------------------

=item public void Request();

Method to request a new account.

=cut
#------------------------------------------------------------------------
sub Account::Request {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Account->Request($web_args);

  if ($form->canceled( )) {

    $self->redirect( uri => "/Account/Overview" );

  } elsif ( $form->ok ) {

    my $email = ISGA::Utility->cleanEmail($form->get_input('email'));
    my $password = $form->get_input('password');

    # generate a unique code for the request
    my $code;
    do { 
      $code = Digest::MD5::md5_base64($password, $email, time);
    } while ( ISGA::AccountRequest->exists(Hash => $code) );    
    $code =~ s/\+/-/go;
    $code =~ s/\//_/go;

    # does this request exist?\
    my ( $ar ) = @{ISGA::AccountRequest->query( Email => $email )};
    
    if ( ! $ar or $ar->getStatus eq 'Expired' ) {
    
    my %form_args = 
      ( 
       Password => Digest::MD5::md5_hex($password),
       Hash => $code,
       Name => $form->get_input('name'), 
       Email => $email, 
       Status => 'Open',
       Institution => $form->get_input('institution'),
       IsPrivate => 1,
       CreatedAt => ISGA::Timestamp->new(),
        );
    
    $ar = ISGA::AccountRequest->create(%form_args);

  }


    $self->redirect( uri => "/Account/Requested?account_request=$ar" );
  }

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/Account/Request' );
}

#------------------------------------------------------------------------

=item public void Confirm();

Confirm an account request

=cut
#------------------------------------------------------------------------
sub Account::Confirm {
  my $self = shift;
  my $web_args = $self->args;

  #retrieve request
  my ($ar) = @{ISGA::AccountRequest->query( Hash => $web_args->{hash} )};
  $ar or X::User::Denied->throw();

  my $status = $ar->getStatus;
  $status eq 'Expired' and X::User::Expired->throw();
  $status eq 'Created' and X::User::Denied->throw();

  $ar->getStatus eq 'Open' or X::User::Expired->throw();
  
  # set to default user class
  my $uc = ISGA::UserClass->new( Name => ISGA::SiteConfiguration->value('default_user_class') );

  my $account = ISGA::Account->create( Email => $ar->getEmail, Password => $ar->getPassword,
					   Name => $ar->getName, Institution => $ar->getInstitution,
					   IsPrivate => $ar->isPrivate,
                                           IsWalkthroughDisabled => 0,
				           UserClass => $uc,
                                           IsWalkthroughHidden => 0,
					   Status => ISGA::PartyStatus->new('Active'));
  
  $ar->edit( Status => 'Created' );
	       
  $self->redirect( uri => "/Account/Confirmed?account=$account" );
}


#------------------------------------------------------------------------

=item public void ShowHideWalkthrough();

Update Hide and Show walkthrough 

=cut
#------------------------------------------------------------------------
sub Account::ShowHideWalkthrough{

  my $self = shift;
  my $web_args = $self->args;
  my $account = ISGA::Login->getAccount;

  if($web_args->{isHidden} eq "show"){
    $account->edit( IsWalkthroughHidden => 0 ) || warn "bad show\n";
  } else {
    $account->edit( IsWalkthroughHidden => 1 ) || warn "bad hide\n";
  }
  $self->redirect( uri => '/Success' );
}


#------------------------------------------------------------------------

=item public void OutageNotification();

Add a notification for a user when outage is restored

=cut
#------------------------------------------------------------------------
sub Account::OutageNotification{

  my $self = shift;
  my $web_args = $self->args;
  my $account = ISGA::Login->getAccount;
  # notify the user their run was canceled

  if(ISGA::AccountNotification->exists( Account => $account, Type =>  ISGA::NotificationType->new( Name => 'Service Outage Restored'))){
    $self->redirect( uri => '/Success' );
  }

  ISGA::AccountNotification->create( Account => $account,
                                     Type =>  ISGA::NotificationType->new( Name => 'Service Outage Restored'));

  $self->redirect( uri => '/Success' );
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
