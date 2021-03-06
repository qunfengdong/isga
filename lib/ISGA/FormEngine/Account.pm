package ISGA::FormEngine::Account;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::Account - provide account forms.

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

=item public hashref form ChangeMyPassword();

Build a FormEngine object to edit account details.

=cut
#------------------------------------------------------------------------
sub ChangeMyPassword {

  my ($class, $args) = @_;

  my $account = ISGA::Login->getAccount;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Account Details',
      sub =>
      [
       {
	NAME => 'old_password',
	TITLE => 'Current Password',
	templ => 'password',
	REQUIRED => 1,
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null', 'Account::isCorrectPassword'],
       },  

       {
	NAME => 'password',
	TITLE => 'New Password',
	templ => 'password',
	REQUIRED => 1,
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null', 'Account::passwordsMatch'],
       },  
       
       {
	NAME => 'confirm_password',
	TITLE => 'Confirm Password',
	templ => 'password',
	REQUIRED => 1,
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null'],
       },     
       
      ]
     }
    );	     
  
  $form->conf( { ACTION => '/submit/Account/ChangeMyPassword',
		 FORMNAME => 'account_change_my_password',
		 SUBMIT => 'Save Password',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form ResetPassword();

Build a FormEngine object to reset passwords.

=cut
#------------------------------------------------------------------------
sub ResetPassword {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $hash = $args->{hash} or X::User::Denied->throw();

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub =>
      [  
        {
	NAME => 'password',
	TITLE => 'Password',
	templ => 'password',
	REQUIRED => 1,
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null', 'Account::passwordsMatch'],
       },  
       
       {
	NAME => 'confirm_password',
	TITLE => 'Confirm Password',
	templ => 'password',
	REQUIRED => 1,
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null'],
       },     
       
       {
	templ => 'print',
	TITLE => 'Confirmation Code',
	VALUE => $hash,
       },
      ]
     },
     { templ => 'hidden',
       NAME  => 'hash',
       VALUE => $hash,
     }
    );	     
  
  $form->conf( { ACTION => '/submit/Account/ResetPassword',
		 FORMNAME => 'account_reset_password',
		 SUBMIT => 'Reset Password',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form LostPassword();

Build a FormEngine object for lost password recovery.

=cut
#------------------------------------------------------------------------
sub LostPassword {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub =>
      [  
       {
	NAME => 'email',
	TITLE => 'Email',
	SIZE => 60,
	MAXLEN => 60,
	REQUIRED => 1,
	ERROR => 'not_null',
       },   
      ]
     }
    );	     
  
  $form->conf( { ACTION => '/submit/Account/LostPassword',
		 FORMNAME => 'account_lost_password',
		 SUBMIT => 'Request New Password',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form Request();

Build a FormEngine object for requesting a new account.

=cut
#------------------------------------------------------------------------
sub Request {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Personal Information',
      sub =>
      [
        {
	NAME => 'name',
	TITLE => 'Name',
	SIZE => 60,
	MAXLEN => 60,
	REQUIRED => 1,
	ERROR => ['not_null', 'Text::checkHTML'],
       },
       
       {
	NAME => 'email',
	TITLE => 'Email',
	SIZE => 60,
	MAXLEN => 60,
	REQUIRED => 1,
	ERROR => ['not_null', 'Text::checkHTML', 'Text::checkEmail', 'Account::emailIsAvailable'],
       },     

       {
	NAME => 'confirm_email',
	TITLE => 'Confirm Email',
	SIZE => 60,
	MAXLEN => 60,
	REQUIRED => 1,
	ERROR => ['not_null', 'Account::emailsMatch'],
       }, 
       
       {
	NAME => 'password',
	TITLE => 'Password',
	templ => 'password',
	REQUIRED => 1,
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null', 'Account::passwordsMatch'],
       },  
       
       {
	NAME => 'confirm_password',
	TITLE => 'Confirm Password',
	templ => 'password',
	REQUIRED => 1,
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null'],
       },        

       {
	NAME => 'institution',
	TITLE => 'Institution',
	SIZE => 60,
	MAXLEN => 100,
	ERROR => 'Text::checkHTML',
       },        
       
      ]
     },
     
    );	     

  $form->conf( { ACTION => '/submit/Account/Request',
		 FORMNAME => 'account_request_avoid_conflict',
		 SUBMIT => 'Request Account',
                 CANCEL => '',
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
