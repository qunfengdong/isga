package ISGA::FormEngine::Check::Date;
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

=item public String checkDate(string value);

Returns an error if the supplied text isn't a valid date.

=cut 
#------------------------------------------------------------------------
sub checkDate {

  my $value = shift;

  my $scrubbed = HTML::Scrubber->new()->scrub($value);

  my $error = 'Must not contain HTML code.';

  return $scrubbed eq $value ? '' : $error;
}

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
