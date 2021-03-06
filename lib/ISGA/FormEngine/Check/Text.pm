package ISGA::FormEngine::Check::Text;
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

use HTML::Scrubber;
use URI;
use Email::Valid;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public String checkHTML(string value);

Returns an error if the supplied text contains html code.

=cut 
#------------------------------------------------------------------------
sub checkHTML {

  my $value = shift;

  my $scrubbed = HTML::Scrubber->new()->scrub($value);

  my $error = 'Must not contain HTML code.';

  return $scrubbed eq $value ? '' : $error;
}

#------------------------------------------------------------------------

=item public String checkEmail(string value);

Returns an error if the supplied text isn't an email address. Weak validation.

=cut 
#------------------------------------------------------------------------
sub checkEmail {
  
  my $value = shift;

  my ($address, $object) = Email::Valid->address($value);
  
  return ($address ? '' : "$value is not a valid email address");  
}

#------------------------------------------------------------------------

=item public String checkEmailList(string value);

Parses the supplied text by line and verifies that an email address
can be extracted from each one.

=cut 
#------------------------------------------------------------------------
sub checkEmailList {
  
  my $value = shift;

  my $finder = Email::Find->new(sub {$_[1]});

  my $sum = 0;

  foreach ( split(/\n/, $value) ) {

    $_ =~ /\S/ or next;

    my $new = $finder->find(\$_) or return "'$_' doesn't seem to contain an email address";
    $sum += $new;
  }

  return ( $sum ? '' : 'no email addresses found' );
}

#------------------------------------------------------------------------

=item public String checkUnixFileName(string value);

Returns an error if the supplied text contains code to break a unix file path.

=cut 
#------------------------------------------------------------------------
sub checkUnixFileName {

  my $value = shift;

  if ( $value !~ /^[-A-Za-z0-9_ \.]+$/ ) {
    return 'Must not contain special characters.';
  }

  return '';
}

#------------------------------------------------------------------------

=item public String alphaNumeric(string value);

Returns an error if the supplied text is not alphaNumeric.

=cut
#------------------------------------------------------------------------
sub alphaNumeric {

  my $value = shift;

  if ($value =~ /[^A-Za-z0-9]/g){
    return 'Must only contain letters and numbers.';
  }
  return '';
}

#------------------------------------------------------------------------

=item public String checkDate(string value);

Returns an error if the supplied text isn't a valid date.

=cut 
#------------------------------------------------------------------------
sub checkDate {

  my $value = shift;

  eval { ISGA::Date->new($value) };

  if($@) {
    return 'Must be a numerical date in YYYY-MM-DD format.';
  }
  
  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('Text::checkHTML');
ISGA::FormEngine::SkinUniform->_register_check('Text::checkEmail');
ISGA::FormEngine::SkinUniform->_register_check('Text::checkEmailList');
ISGA::FormEngine::SkinUniform->_register_check('Text::alphaNumeric');
ISGA::FormEngine::SkinUniform->_register_check('Text::checkUnixFileName');
ISGA::FormEngine::SkinUniform->_register_check('Text::checkDate');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
