package ISGA::FormEngine::Check::Blast;
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

    my $upload = $ISGA::APR->upload('upload_file');
    return '' if( $upload eq '' );
    my $fh = $upload->fh;
    local ($/);
    $sequence = <$fh>;
    seek($fh,0,0);
    undef $fh;
  }
  $sequence =~ s/>(\S| )*(\n|\r\n)//og;
  $sequence =~ s/\s//og;

  if($sequence =~ /[^ATGCRYSWKMDHBVN]/oig){
     undef $sequence;
     return '<br>'.ucfirst($value).' is not compatible with the provided input sequence type.  '.ucfirst($value).' needs a nucleotide sequence as input.' if($value ne 'blastp' && $value ne 'tblastn');
  } else {
     undef $sequence;
     return '<br>'.ucfirst($value).' is not compatible with the provided input sequence type.  '.ucfirst($value).' needs an amino acid sequence as input.' if($value ne 'blastn' && $value ne 'blastx' && $value ne 'tblastx');
  }
  undef $sequence;
  return ''; 
}

#------------------------------------------------------------------------

=item public String checkBlastProgram(string value);

Checks input sequene to see if it is compatible with selected blast program

=cut
#------------------------------------------------------------------------
sub compatibleBlastProgramAndDB {
  my ($value, $form) = @_;
  my $db = $form->get_input('sequence_database');
  my $program = $form->get_input('blast_program');
  my %compatible = ( 'blastn'  => 'nt',
                     'blastp'  => 'nr',
                     'blastx'  => 'nr',
                     'tblastn' => 'nt',
                     'tblastx' => 'nt',);
  my %dbtype = ( 'blastn'  => 'nucleotide',
                 'blastp'  => 'protein',
                 'blastx'  => 'protein',
                 'tblastn' => 'nucleotide',
                 'tblastx' => 'nucleotide',);
  my $flag = 0;
  if($program eq 'blastn'){
      $flag = 1 if( ($db =~ /nr$/) or ($db =~ /.*run_result_prot_db$/) );
  }elsif($program eq 'blastp'){
      $flag = 1 if( ($db !~ /nr$/) and ($db !~ /tair9_pep$/) and ($db !~ /.*run_result_prot_db$/) );
  }elsif($program eq 'blastx'){
      $flag = 1 if( ($db !~ /nr$/) and ($db !~ /tair9_pep$/) and ($db !~ /.*run_result_prot_db$/) );
  }elsif($program eq 'tblastn'){
      $flag = 1 if( ($db =~ /nr$/) or ($db =~ /.*run_result_prot_db$/) );
  }elsif($program eq 'tblastx'){
      $flag = 1 if( ($db =! /nr$/) or ($db =~ /.*run_result_prot_db$/) );
  }
  if( $flag ){
    return '<br>The BLAST program you have selected is not compatible with your database type.  '.ucfirst($program).' needs to be used with a '.$dbtype{$program}.' database.';
  }

  return '';
}
#------------------------------------------------------------------------

=item public String checkFastaHeader(string value);

Checks input sequene to see if it is compatible with selected blast program

=cut
#------------------------------------------------------------------------
sub checkFastaHeader {
  my ($value, $form) = @_;
  my $sequence = $form->get_input('query_sequence');
  if(not $sequence){

    my $upload = $ISGA::APR->upload('upload_file');
    return '' if( $upload eq '' );
    my $fh = $upload->fh;
    local ($/);
    $sequence = <$fh>;
    seek($fh,0,0);
    undef $fh;
  }
  $sequence =~ s/\s//og;

  if($sequence !~ /^>/o){
     undef $sequence;
     return '<br>You must supply a FASTA header with your sequence';
  }
  undef $sequence; 
  return '';
}


#------------------------------------------------------------------------

=item public String sanityFastaChecks(string value);

Checks input sequene to see if it is compatible with selected blast program 
and has a header.  Combining these checks to reduce the number of file opens 
we must perform.

=cut
#------------------------------------------------------------------------
sub sanityFastaChecks {
  my ($value, $form) = @_;
  my $blast_program = $form->get_input('blast_program');
  my $sequence = $form->get_input('query_sequence');
  if(not $sequence){

    my $upload = $ISGA::APR->upload('upload_file');
    return '' if( $upload eq '' );
    my $fh = $upload->fh;
    local ($/);
    $sequence = <$fh>;
    seek($fh,0,0);
    undef $fh;
  }
#  $sequence =~ s/\s//og;

  if($sequence !~ /^>/o){
     undef $sequence;
     return '<br>You must supply a FASTA header with your sequence';
  }

  $sequence =~ s/>(\S| )*(\n|\r\n)//og;
  $sequence =~ s/\s//og;
  if($sequence =~ /[^ATGCRYSWKMDHBVN]/oig){
     undef $sequence;
     return '<br>'.ucfirst($blast_program).' is not compatible with the provided input sequence type.  '.ucfirst($blast_program).' needs a nucleotide sequence as input.' if($blast_program ne 'blastp' && $blast_program ne 'tblastn');
  } else {
     undef $sequence;
     return '<br>'.ucfirst($blast_program).' is not compatible with the provided input sequence type.  '.ucfirst($blast_program).' needs an amino acid sequence as input.' if($blast_program ne 'blastn' && $blast_program ne 'blastx' && $blast_program ne 'tblastx');
  }
  undef $sequence;
  return '';
}


ISGA::FormEngine::SkinUniform->_register_check('Blast::checkUploadFile');
ISGA::FormEngine::SkinUniform->_register_check('Blast::isDatabaseSelected');
ISGA::FormEngine::SkinUniform->_register_check('Blast::checkBlastProgram');
ISGA::FormEngine::SkinUniform->_register_check('Blast::compatibleBlastProgramAndDB');
ISGA::FormEngine::SkinUniform->_register_check('Blast::checkFastaHeader');
ISGA::FormEngine::SkinUniform->_register_check('Blast::sanityFastaChecks');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
