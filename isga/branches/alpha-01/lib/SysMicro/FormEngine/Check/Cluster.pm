package SysMicro::FormEngine::Check::Cluster;
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

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================


#------------------------------------------------------------------------

=item public String isValidRange(String value, String name, Form form, Max max, Min min, Input inputname);

Asserts that the name supplied to the form isAvailable for the class

=cut 
#------------------------------------------------------------------------
sub isValidRange {
  use Data::Dumper;
#  my ($data, $form, $min, $max, $inputname) = @_;
   my ($data, $form) = @_;
#  my $min = 0;
#  my $max = 100;
warn "HERE IN CHECK\n";
warn Dumper($data);
#  my $value = $form->get_input($inputname);
#  if ( $value > $max or $value < $min ) {
#    return "Input value must be between $min and $max";
#  }

  return '';
}

sub extendOrfsOffEndDependency {

  my ($data, $form) = @_;
  my $extendorfsoffend = $form->get_input('extendorfsoffend');
  my $lineargenome = $form->get_input('lineargenome');
  if ( $extendorfsoffend and  not($lineargenome) ) {
    return "Extend ORF off end option only works if the Linear Genome option is selected also.";
  }

  return '';
}


SysMicro::FormEngine::SkinUniform->_register_check('Cluster::isValidRange');
SysMicro::FormEngine::SkinUniform->_register_check('Cluster::extendOrfsOffEndDependency');
1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
