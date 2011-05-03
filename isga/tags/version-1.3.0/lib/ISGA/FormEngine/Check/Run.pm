package ISGA::FormEngine::Check::Run;
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

=item public string isErgatisPipeline(int id, form form);

Checks to make sure the supplied id is an existing ergatis
pipeline. The supplied form object must have the run.

=cut 
#------------------------------------------------------------------------
sub isErgatisPipeline {

  my ($data, $form) = @_;

  $data =~ /^\d+$/ or return "Ergatis Pipeline Id must be integer";

  my $run = $form->get_input('run');

  -d join( '/', $run->getErgatisRuntimeDirectory, $data )
    or return "$data is not a valid Ergatis Pipeline";

  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('Run::isErgatisPipeline');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
