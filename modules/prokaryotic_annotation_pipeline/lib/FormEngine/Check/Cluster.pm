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

=item public string extendOrfsOffEndDependency(string value, Form form);

Enforces the dependency of extedORFsOffEnd on linearGenome.

=cut 
#------------------------------------------------------------------------
sub extendOrfsOffEndDependency {

  my ($data, $form) = @_;
  my $extendorfsoffend = $form->get_input('extendorfsoffend');
  my $lineargenome = $form->get_input('lineargenome');
  if ( $extendorfsoffend and  not($lineargenome) ) {
    return "Extend ORF off end option only works if the Linear Genome option is selected also.";
  }

  return '';
}

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

#------------------------------------------------------------------------
=item public string codonProbability(string value, Form form, Caller caller string condon Input Name);

Checks if the number of probabilities is the same as number of codons.

=cut
#------------------------------------------------------------------------
sub codonProbability {
  my ($value, $form, $caller, $codon_input_name) = @_;
  my $codon_input_value = $form->get_input($codon_input_name);

  return '' if($value eq '');
  return 'Invalid character usage. Specifiy a comma separted list of probabilities. Do not use spaces' 
    if($value =~ /[^0-9\,\.]/go);

  my @probabilities = split(/\,/, $value);
  my @codons;
  if($codon_input_value ne ''){
    @codons = split(/\,/, $codon_input_value);
    return 'The number of probabilities is not equal to the number of specified codons'
      if($#codons != $#probabilities);
  }elsif($#probabilities != 2){
    return 'Since no codons were specified the number of probabilities must equal 3.  3 is the default number of codons.';
  }

  my $sum = 0;
  foreach my $probability (@probabilities){
    if (not ($probability =~ /^\d*\.?\d+$/o)){
      return 'Probability is not a proper number.';
    }
    $sum += $probability;
  }

  return 'Probabilities do not sum to 1' if ($sum != 1);

  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('Cluster::extendOrfsOffEndDependency');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::codonCheck');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::codonProbability');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
