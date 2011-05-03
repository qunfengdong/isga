package ISGA::GlobalPipeline::ProkaryoticAnnotation;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::RunBuilderProkaryoticAnnotation provides functionality shared
across versions of the prokaryotic annotation pipeline.

=head1 SYNOPSIS

=head1 DESCRIPTION

ISGA::RunBuilderProkaryoticAnnotation provides functionality shared
across versions of the prokaryotic annotation pipeline. This class
does not provide full pipeline functionality and should only be used
by a release of the prokaryotic annotation pipeline.

=head1 METHODS

=cut
#------------------------------------------------------------------------
use warnings;
use strict;

use base 'ISGA::GlobalPipeline';


#------------------------------------------------------------------------

=item public boolean hasGBrowseData();

Returns true if the pipeline generates data for display in GBrowse

=cut
#------------------------------------------------------------------------
  sub hasGBrowseData { return 1; }

#------------------------------------------------------------------------

=item public boolean hasBlastDatabase();

Returns true if the pipeline provides a Blast database.

=cut
#------------------------------------------------------------------------
  sub hasBlastDatabase { return 1; }

#------------------------------------------------------------------------

=item public void verifyUpload( string $name, PipelineInput $pi);

This method generates a verification callback to be used on uploaded files.

=cut 
#------------------------------------------------------------------------
sub verifyUpload {

  my ($self, $name, $pi) = @_;
  my $ci = $pi->getClusterInput->getName;

  my $verify =  sub {
    
    my $fh = shift;

    # we know how to verify fasta file inputs
    if ( $ci eq 'Genome_Contigs' ) {

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
    if ( $ci eq 'Genome_Contigs' ) {      
      return ISGA::FileFormat::FASTA->format($fh);
    } else {
      return $fh;
    }
  };

  return [ $format, $verify ];    
}


1;
