package ISGA::FormEngine::Check::PhyloEGGS;
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

=item public String checkGenomeFile(string value);

Checks to see if an input sequence was supplied.

=cut 
#------------------------------------------------------------------------
sub checkGenomeFile{
	my ($value, $form) = @_;
    my $sequence = $form->get_input('genome_seq_file');
    

  if($sequence ne ''){
  	  if ($sequence !~ /\.faa$/ ){
  	  	 return 'Genome protein file name must have faa as the file extension.';
  	  }
  	  if ($sequence !~ /^NC_.*/ ){
  	  	return  'please use NC_xxxxx.faa format (like NCBI accession format) as the file name.';
  	  }
  }

  return '';
}

#------------------------------------------------------------------------

=item public String checkPttFile(string value);

Checks to see if an input sequence was supplied.

=cut
#------------------------------------------------------------------------

sub checkPttFile{
	my ($value, $form) = @_;
	my $genome = $form->get_input('genome_seq_file');
    my $ptt    = $form->get_input('ptt_file');
    
    if (($genome eq '') && ($ptt eq '')){
    	return '';
    }
    
    if(($genome ne '') &&( $ptt ne '')){
    	return '';
    }
    
    if(($genome ne '') && ($ptt eq '')){
    	return "<br />You must upload a ptt file if you provide a genome protein sequence file.";
    }
    return '';
}

#------------------------------------------------------------------------

=item public String checkSRNAFile(string value);

Checks to see if an input sequence was supplied.

=cut
#------------------------------------------------------------------------

sub checkSRNAFile{
	my ($value, $form) = @_;
	my $genome = $form->get_input('genome_seq_file');
	my $tree   = $form->get_input('upload_newick_file');
	my $sRNA   = $form->get_input('16sRNA_file');
	
	return '' if ($genome eq '');
	
	if( ($tree eq '') && ($genome ne '') && ($sRNA eq '')){
		return '<br />You must upload a 16sRNA file if you provide a genome protein sequence.';
	}
	
	if(($tree eq '') && ($genome ne '') && ($sRNA ne '')){
		my 	$genome_name=$genome;
			$genome_name=~ s/\.faa$//;
		
	
		my $RNA_upload = $ISGA::APR->upload('16sRNA_file');
   
  	  my $fh = $RNA_upload->fh;
  	  local ($/);
  	  my $sequence = <$fh>;
  	  seek($fh,0,0);
  	  undef $fh;
	
		$sequence =~ s/^>//;
		my $seqname= (split(" ",$sequence))[0];	
	
		if($seqname eq $genome_name){
			return '';
		}else{
			return '<br />The header for the 16sRNA sequence must be same as for the genome sequence.';
		}
		
	}
	
	return '';
	
	
}



ISGA::FormEngine::SkinUniform->_register_check('PhyloEGGS::checkGenomeFile');
ISGA::FormEngine::SkinUniform->_register_check('PhyloEGGS::checkPttFile');
ISGA::FormEngine::SkinUniform->_register_check('PhyloEGGS::checkSRNAFile');



1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
