package SysMicro::FormEngine::Check::Blast;
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

=item public String checkUploadFile(string value);

Checks to see if an input sequence was supplied.

=cut 
#------------------------------------------------------------------------
sub checkUploadFile {
  my ($value, $form) = @_;
  my $sequence = $form->get_input('query_sequence') || $form->get_input('upload_file');

  return 'Query sequence required.' if($sequence eq '');

  return '';
}

#------------------------------------------------------------------------

=item public String checkUploadFile(string value);

Checks to see if an input sequence was supplied.

=cut
#------------------------------------------------------------------------
sub isDatabaseSelected {
  my ($value, $form) = @_;
  my $pipline_database = $form->get_input('pipeline_database');
  my $sequence_database = $form->get_input('sequence_database');
  return 'Please select at least one database.' if((not defined $pipline_database) && (not defined $sequence_database));

  return '';
}


#------------------------------------------------------------------------

=item public String checkBlastProgram(string value);

Checks input sequene to see if it is compatible with selected blast program

=cut
#------------------------------------------------------------------------
sub checkBlastProgram {
  my ($value, $form) = @_;
  my $sequence = $form->get_input('query_sequence');
  if(not $sequence){

    my $upload = $SysMicro::APR->upload('upload_file');
    return '' if( $upload eq '' );
    my $fh = $upload->fh;
    local ($/);
    $sequence = <$fh>;
    seek($fh,0,0);
  }
  $sequence =~ s/^>(\S| )*(\n|\r\n)//o;
  $sequence =~ s/\s//og;

  if($sequence =~ /[^ATGCRYSWKMDHBVN]/oig){
     return '<br>Program is not compatible with input sequence type' if($value ne 'blastp' && $value ne 'tblastn');
  } else {
     return '<br>Program is not compatible with input sequence type' if($value ne 'blastn' && $value ne 'blastx' && $value ne 'tblastx');
  }
  return ''; 
}

#------------------------------------------------------------------------

=item public String checkBlastProgram(string value);

Returns an error if the supplied text contains html code.

=cut
#------------------------------------------------------------------------
sub readUploadedFile {
	my ($value, $form) = @_;
}


SysMicro::FormEngine::SkinUniform->_register_check('Blast::checkUploadFile');
SysMicro::FormEngine::SkinUniform->_register_check('Blast::isDatabaseSelected');
SysMicro::FormEngine::SkinUniform->_register_check('Blast::checkBlastProgram');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
