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

=item public string isPath(string value);

Enforces rules on path names

=cut 
#------------------------------------------------------------------------
sub isPath {
    
  my $data = shift;
  
  my @files = split( /\//, $data );

  foreach ( @files ) {
    if ( $_ !~ /^[-A-Za-z0-9_ \.]+$/ ) {
      return "Must not contain special characters. ($_)";
    }
  }
  return '';
}

#------------------------------------------------------------------------

=item public string isAbsolutePath(string value);

Enforces rules on path names

=cut 
#------------------------------------------------------------------------
sub isAbsolutePath {
    
  my $data = shift;
  
  $data =~ m{^/} or return 'Path must be absolute.';

  # need to check for valid unix filesystem name
  return &isPath($data);
}

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
ISGA::FormEngine::SkinUniform->_register_check('File::isPath');
ISGA::FormEngine::SkinUniform->_register_check('File::isAbsolutePath');


1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
