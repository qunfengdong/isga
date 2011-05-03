# -*- cperl -*-
package ISGA::GlobalPipeline::Transcriptome;

use warnings;
use strict;

use base 'ISGA::GlobalPipeline';

#------------------------------------------------------------------------

=item public void verifyUpload( string $name, PipelineInput $pi);

This method generates a verification callback to be used on uploaded files.

=cut 
#------------------------------------------------------------------------
sub verifyUpload {

  my ($self, $name, $pi) = @_;

  my $ci = $pi->getClusterInput->getName;


  my $verify = sub {
    
    my $fh = shift;
    
    # we know how to verify fasta file inputs
    if ( $ci eq 'EST_Input' ) {

      eval { 
	ISGA::FileFormat::FASTA->verify( $fh, UserName => $name, Alphabet => 'nucleotide' );
      };
      
      if ( $@ ) {
	my $e = ( X->caught() ? $@ : X::Dropped->new(error => $@) );    
	
	if ( $e->isa('X::File::FASTA') ) {
	  X::User->throw( error => $e->message );
	} 
	
	$e->rethrow();
      }
    }

    # this filter doesn't modify the fh
    seek($fh,0,0);
    return $fh;
  };

  my $format = sub {

    my $fh = shift;
    
    # we know how to verify fasta file inputs
    if ( $ci eq 'EST_Input' ) {      
      return ISGA::FileFormat::FASTA->format($fh);
    } else {
      return $fh;
    }
  };
  
  return [ $format, $verify ];    



}


1;
