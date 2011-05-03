package ISGA::FormEngine::Check::Cluster;
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
=item public string codonCheck(string value, Form form);

Checks if value is a list of codons.

=cut 
#------------------------------------------------------------------------
sub codonCheck {
  my ($value, $form) = @_;
  if($value =~ /[^atcgATCG0\,]/go){
    return 'Invalid character usage. Specifiy a comma separted list of codons. Do not use spaces.';
  }
  my @codons = split(/\,/, $value);
  foreach my $codon (@codons){
    if ( length($codon) != 3 and $codon ne 0 )  {
      return 'Improper codon length.  Specifiy a comma separted list of codons. Do not use spaces.';
    }
  }
  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('Cluster::codonCheck');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
