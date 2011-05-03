package ISGA::FormEngine::Check::Hawkeye;
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

=item public String checkUploadFile(string value);

Checks to see if an input sequence was supplied.

=cut 
#------------------------------------------------------------------------
sub checkUploadFile {
  my ($value, $form) = @_;
#  my $ace = $form->get_input('upload_ace_file');

  return 'Must provide proper files.' if($value eq '');

  return '';
}


ISGA::FormEngine::SkinUniform->_register_check('Hawkeye::checkUploadFile');
1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
