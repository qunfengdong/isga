package ISGA::FormEngine::Check::File;
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

Enforces rule that file names must be unique within an account.

=cut 
#------------------------------------------------------------------------
sub isUniqueName {

  my ($data, $form) = @_;

  my $message = 'You have already uploaded a file with this name.';

  # first check runs
  ISGA::File->exists( UserName => $data, CreatedBy => ISGA::Login->getAccount)
      and return $message;

  return '';
}


ISGA::FormEngine::SkinUniform->_register_check('File::isUniqueName');
ISGA::FormEngine::SkinUniform->_register_check('File::isFileHandle');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
