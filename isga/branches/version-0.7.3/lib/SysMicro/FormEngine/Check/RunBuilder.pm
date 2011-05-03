package SysMicro::FormEngine::Check::RunBuilder;
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

=item public string isUniqueName(string value);

Enforces rule that runbuilder names must be unique within an account.

=cut 
#------------------------------------------------------------------------
sub isUniqueName {

  my ($data, $form) = @_;

  my $message = 'You have already created a run with this name.';

  # first check runs
  SysMicro::Run->exists( Name => $data, CreatedBy => SysMicro::Login->getAccount)
      and return $message;

  # then check other run builders
  my ($rb) = 
    @{SysMicro::RunBuilder->query( Name => $data, CreatedBy => SysMicro::Login->getAccount)};

  if ( $rb ) {

    if ( $form->get_formname eq 'run_builder_create' ) {
      my $pipeline = $form->get_input('pipeline');
      $rb->getPipeline == $pipeline or return $message;
    } else {
     $form->get_input('run_builder') == $rb or return $message;
   }
  }

  return '';
}

SysMicro::FormEngine::SkinUniform->_register_check('RunBuilder::isUniqueName');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
