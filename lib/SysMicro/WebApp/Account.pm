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
  my $form = SysMicro::FormEngine::Account->EditMyDetails($web_args);

  if ( $form->canceled ) {
    $self->redirect( uri => '/Account/MyAccount' );
  } elsif ( $form->ok ) {

    my $disablewalkthrough =  $form->get_input('disablewalkthrough');
    my $account = SysMicro::Login->getAccount;
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
  my $form = SysMicro::FormEngine::Account->ChangeMyPassword($web_args);

  if ( $form->canceled ) {
    $self->redirect( uri => '/Account/MyAccount' );
  } elsif ( $form->ok ) {

    my $account = SysMicro::Login->getAccount;
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
  my $form = SysMicro::FormEngine::Account->ResetPassword($web_args);

  if ( $form->canceled ) {
    $self->redirect( uri => "/Home" );
  } elsif ( $form->ok ) {

    my ($request) = @{SysMicro::PasswordChangeRequest->query( Hash => $form->get_input('hash'))};
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
  my $form = SysMicro::FormEngine::Account->LostPassword($web_args);
 
  if ( $form->canceled ) {

    $self->redirect( uri => "/Home" );

  } elsif ( $form->ok ) {

    my $email = SysMicro::Utility->cleanEmail($form->get_input('email'));

    my ($account) = @{SysMicro::Account->query( Email => $email )};

    # if the account doesn't exist, die quietly
    # this is a security feature at the cost of usability, maybe need
    # to reevaluate
    $account or $self->redirect( uri => '/Account/PasswordChangeSent' );

    # see if a request already exists
    my ($request) = @{SysMicro::PasswordChangeRequest->query(Account => $account)};
    
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
    } while ( SysMicro::PasswordChangeRequest->exists(Hash => $code) );    
    $code =~ s/\+/-/go;
    $code =~ s/\//_/go;     
    
    # add the entry
    $request = SysMicro::PasswordChangeRequest->create(Hash => $code, 
						       CreatedAt => SysMicro::Timestamp->new,
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
  my $form = SysMicro::FormEngine::Account->Request($web_args);

  if ($form->canceled( )) {

    $self->redirect( uri => "/Account/Overview" );

  } elsif ( $form->ok ) {

    my $email = SysMicro::Utility->cleanEmail($form->get_input('email'));
    my $password = $form->get_input('password');

    # generate a unique code for the request
    my $code;
    do { 
      $code = Digest::MD5::md5_base64($password, $email, time);
    } while ( SysMicro::AccountRequest->exists(Hash => $code) );    
    $code =~ s/\+/-/go;
    $code =~ s/\//_/go;

    # does this request exist?\
    my ( $ar ) = @{SysMicro::AccountRequest->query( Email => $email )};
    
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
       CreatedAt => SysMicro::Timestamp->new(),
        );
    
    $ar = SysMicro::AccountRequest->create(%form_args);

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
  my ($ar) = @{SysMicro::AccountRequest->query( Hash => $web_args->{hash} )};
  $ar or X::User::Denied->throw();

  my $status = $ar->getStatus;
  $status eq 'Expired' and X::User::Expired->throw();
  $status eq 'Created' and X::User::Denied->throw();

  $ar->getStatus eq 'Open' or X::User::Expired->throw();
  
  my $account = SysMicro::Account->create( Email => $ar->getEmail, Password => $ar->getPassword,
					   Name => $ar->getName, Institution => $ar->getInstitution,
					   IsPrivate => $ar->isPrivate,
                                           IsWalkthroughDisabled => 0,
                                           IsWalkthroughHidden => 0,
					   Status => SysMicro::PartyStatus->new('Active'));
  
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
  my $account = SysMicro::Login->getAccount;

  if($web_args->{isHidden} eq "show"){
    $account->edit( IsWalkthroughHidden => 0 ) || warn "bad show\n";
  } else {
    $account->edit( IsWalkthroughHidden => 1 ) || warn "bad hide\n";
  }
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
