package ISGA::FormEngine::Check::Celera;
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

=item public String checkLibraryName(string value);

Checks to see if a library name is unique

=cut 
#------------------------------------------------------------------------
sub checkLibraryName {
  my ($value, $form) = @_;
  my $run_builder = $form->get_input('run_builder');
  my $current_rbi = $form->get_input('run_builder_input');
  my ($pipeline_input) = @{$run_builder->getRequiredInputs};
  my $cluster_input = $pipeline_input->getClusterInput;
  my @rbi = @{ISGA::RunBuilderInput->query( PipelineInput => $pipeline_input,
                                            RunBuilder => $run_builder)};

  foreach my $rbi ( @rbi ) {
    next if(defined $current_rbi and $current_rbi->getId eq $rbi->getId);
    foreach ( @{$rbi->getParameters} ) {
      if($_->{TITLE} eq 'Library Name'){
	return "Library names must be unique. Use the ctrl key to select multiple SFF files for a library." if $_->{VALUE} eq $value;
      }
    }
  }

  return '';
}


ISGA::FormEngine::SkinUniform->_register_check('Celera::checkLibraryName');
1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
