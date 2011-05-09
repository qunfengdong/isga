package ISGA::FormEngine::Check::PipelineBuilder;
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

=item public string isUniqueName(string value);

Enforces rule that pipelinebuilder names must be unique within an account.

=cut 
#------------------------------------------------------------------------
sub isUniqueName {

  my ($data, $form) = @_;

  my $message = 'You have already created a Pipeline with this name.';

  # first check pipeline
  ISGA::UserPipeline->exists( Name => $data, CreatedBy => ISGA::Login->getAccount)
      and return $message;

  ISGA::PipelineBuilder->exists( Name => $data, CreatedBy => ISGA::Login->getAccount)
      and return $message;

  # then check other pipeline builders
  my ($pb) = 
    @{ISGA::PipelineBuilder->query( Name => $data, CreatedBy => ISGA::Login->getAccount)};

  if ( $pb ) {

    if ( $form->get_formname eq 'pipeline_builder_create' ) {
      my $pipeline = $form->get_input('pipeline');
      $pb->getPipeline == $pipeline or return $message;
    } else {
     $form->get_input('pipeline_builder') == $pb or return $message;
   }
  }

  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('PipelineBuilder::isUniqueName');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
