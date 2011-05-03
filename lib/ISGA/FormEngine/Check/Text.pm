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

ISGA::FormEngine::SkinUniform->_register_check('Text::checkHTML');
ISGA::FormEngine::SkinUniform->_register_check('Text::alphaNumeric');
ISGA::FormEngine::SkinUniform->_register_check('Text::checkUnixFileName');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
