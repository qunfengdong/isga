package SysMicro::FormEngine::Check::Text;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::Check provides convenient form verification
methods tied to the FormEngine system.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use HTML::Scrubber;

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

SysMicro::FormEngine::SkinUniform->_register_check('Text::checkHTML');


1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
