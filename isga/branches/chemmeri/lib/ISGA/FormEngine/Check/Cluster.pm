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

#------------------------------------------------------------------------

=item public string linkerInsertSizeDependency(string value, string value, Form form);

Enforces the dependency of linker and insertsize

=cut
#------------------------------------------------------------------------
sub linkerInsertSizeDependency {

  my ($data, $form) = @_;
  my $linker = $form->get_input('linker');
  my $insertsize = $form->get_input('insertsizeavg');
  my $stdev = $form->get_input('insertsizestd');

  if ( ($linker eq 'flx' or $linker eq 'titanium') and not($insertsize and $stdev) ) {
    return "You must provide an Insert Size when using a linker other than none.";
  }elsif($linker eq ' ' and ($insertsize ne '' and $stdev ne '')){
    return "Do not provide an Insert Size when when not using a linker.";
  }

  return '';
}

#------------------------------------------------------------------------

=item public string linkerRequired(string value, Form form);

Enforces the dependency of linker type

=cut
#------------------------------------------------------------------------
sub linkerRequired {

  my ($data, $form) = @_;
  my $linker = $form->get_input('linker');

  if ( not($linker) or $linker eq '' ) {
    return "You must select a linker type.  Select none if not using a linker.";
  }

  return '';
}

#------------------------------------------------------------------------

=item public string insertSizeAvgStdDependency(string value, string value, Form form);

Enforces the dependency of insertsizeavg and insertsizestd

=cut
#------------------------------------------------------------------------
sub insertSizeAvgStdDependency {

  my ($data, $form) = @_;
  my $avg = $form->get_input('insertsizeavg');
  my $std = $form->get_input('insertsizestd');

  if ( $avg ne '' and  $std eq '' ) {
    return "You must provide an Insert Size Average and an Insert Size Standard Deviation together when using a linker other than none.";
  }elsif($avg eq '' and  $std ne '' ){
    return "You must provide an Insert Size Average and an Insert Size Standard Deviation together when using a linker other than none.";
  }

  return '';
}

#------------------------------------------------------------------------

=item public string valuesAreEqual(string value, Form form, string caller, string value string value);

Asserts that the input values supplied are the same

=cut
#------------------------------------------------------------------------
sub valuesAreEqual {

  my ($value, $form, $caller, $input1, $input2) = @_;

  my $value1 = $form->get_input($input1);
  my $value2 = $form->get_input($input2);

  if ( $value1 ne $value2 ) {
    return "Values for these inputs must be equal.";
  }

  return '';
}

#------------------------------------------------------------------------

=item public string isTaggedTagDependency(string value, string value, Form form);

Enforces the dependency of Tags being blank if tagged is false.

=cut
#------------------------------------------------------------------------
sub isTaggedTagDependency {

  my ($value, $form) = @_;
  my $tagged = $form->get_input('tagged');

  if ( $tagged eq 'Y' and  $value eq '' ) {
    return "You must provide a value for Forward Tag and Reverse Tag if Tagged Input Reads is true.<br>A default for Forward Tag is TCTGT<br>A default for Reverse Tag is TCCAT";
  }elsif($tagged eq 'N' and  $value ne '' ){
    return "Forward Tag and Reverse Tag should not have values it Tagged Input Reads is false.  Please remove values from these input fields.";
  }

  return '';
}

#------------------------------------------------------------------------

=item public string isDNA(string value, Form form);

String should only match A, T, C, and G.

=cut
#------------------------------------------------------------------------
sub isDNA {

  my ($value, $form) = @_;

  if ( $value =~ /[^ACTG]/g ) {
    return "The value provided must be only nucleotide sequence.  Please use only A, T, C, and G.";
  }

  return '';
}

#------------------------------------------------------------------------

=item public string methylationExclusiveDependency(string value, string value, Form form);

Enforces certain combination of methylation type being exclusive with one another.

=cut
#------------------------------------------------------------------------
sub methylationExclusiveDependency {
  my ($data, $form) = @_;

  ref($data) eq 'ARRAY' or $data = [ $data ];
  my %filter = map { $_ => 1 } @{$data};
  if ( $filter{'H'} and $filter{'G'} ) {
    return "CpH may only be used with CpHpG and CpHpH";
  }

  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('Cluster::extendOrfsOffEndDependency');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::codonCheck');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::codonProbability');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::linkerInsertSizeDependency');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::linkerRequired');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::insertSizeAvgStdDependency');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::valuesAreEqual');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::isTaggedTagDependency');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::isDNA');
ISGA::FormEngine::SkinUniform->_register_check('Cluster::methylationExclusiveDependency');
1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
