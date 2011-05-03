package ISGA::FormEngine::Check::Account;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::Check provides convenient form verification
methods tied to the FormEngine system.

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

=item public String isCorrectPassword(string value, string name, Form form);

Tests if a user has entered the correct password.

=cut 
#------------------------------------------------------------------------
sub isCorrectPassword {

  my ($data, $form) = @_;

  my $account = ISGA::Login->getAccount;

  my $error = 'Incorrect Password.';

  return  $account->getPassword eq Digest::MD5::md5_hex( $form->get_input('old_password') ) ? 
    '' : $error;
}

#------------------------------------------------------------------------

=item public String emailIsAvailable(String value, String name, Form form);

Asserts that the name supplied to the form isAvailable for the class

=cut 
#------------------------------------------------------------------------
sub emailIsAvailable {

  my ($data, $form) = @_;
  
  my $email = ISGA::Utility->cleanEmail($form->get_input('email'));

  my $error = "This email address is already in use.";
  # check values
  return  ( ISGA::Account->exists(Email => $email) ? $error : '' );
}

#------------------------------------------------------------------------

=item public String emailIsAvailableOrMine(String value, String name, Form form);

Asserts that the email supplied to the form is available or owned by this account.

=cut 
#------------------------------------------------------------------------
sub emailIsAvailableOrMine {

  my ($data, $form) = @_;
  
  my $email = ISGA::Utility->cleanEmail($form->get_input('email'));

  $email eq ISGA::Login->getAccount->getEmail and return '';

  my $error = "This email address is already in use.";
  # check values
  return  ( ISGA::Account->exists(Email => $email) ? $error : '' );
}

#------------------------------------------------------------------------

=item public String passwordsMatch(String value, String name, Form form);

Asserts that the two passwords entered are identical.

=cut 
#------------------------------------------------------------------------
sub passwordsMatch {

  my ($data, $form) = @_;

  if ( $form->get_input('password') eq $form->get_input('confirm_password') ) {
    return '';
  }
  return 'Passwords do not match.';
}

#------------------------------------------------------------------------

=item public String emailsMatch(String value, String name, Form form);

Asserts that the two email addresses entered are identical.

=cut 
#------------------------------------------------------------------------
sub emailsMatch {

  my ($data, $form) = @_;

  if ( $form->get_input('email') eq $form->get_input('confirm_email') ) {
    return '';
  }
  return 'Email addresses do not match.';
}

#------------------------------------------------------------------------

=item public String emailsMatch(String value, String name, Form form);

Asserts that the two email addresses entered are identical.

=cut
#------------------------------------------------------------------------
sub illegalCharacters {

  my ($data, $form) = @_;

  if ( $form->get_input('password') =~ /(\;|\`|\^)/g ) {
    return 'You password contains an illegal character.  The characters for acute accent, caret, and semi-colon are not allowed';
  }
  return '';
}

#
#
# Register all methods below
#

ISGA::FormEngine::SkinUniform->_register_check('Account::emailIsAvailable');
ISGA::FormEngine::SkinUniform->_register_check('Account::emailIsAvailableOrMine');
ISGA::FormEngine::SkinUniform->_register_check('Account::passwordsMatch');
ISGA::FormEngine::SkinUniform->_register_check('Account::emailsMatch');
ISGA::FormEngine::SkinUniform->_register_check('Account::isCorrectPassword');
ISGA::FormEngine::SkinUniform->_register_check('Account::illegalCharacters');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
