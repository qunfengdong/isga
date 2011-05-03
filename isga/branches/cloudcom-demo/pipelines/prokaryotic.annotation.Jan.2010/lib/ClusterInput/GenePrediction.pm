package ISGA::ClusterOutput::GenePrediction;

use warnings;
use strict;

use base 'ISGA::ClusterInput';

#------------------------------------------------------------------------

=item public string getValue(RunBuilder $rb);

Calculates the file name(s) for a component input value.

=cut 
#------------------------------------------------------------------------
sub getValue {
  
  my ($self, $rb) = @_;
  
  my %components = map{ $_->getErgatisName => '1' } @{$rb->getPipeline->getComponents};
  
  if ( exists $components{'bsml2fasta.final_cds'} ){
    return '$;REPOSITORY_ROOT$;/output_repository/bsml2fasta/$;PIPELINEID$;_final_cds/bsml2fasta.fsa.list ';
  }else{
    return '$;REPOSITORY_ROOT$;/output_repository/bsml2fasta/$;PIPELINEID$;_prediction_CDS/bsml2fasta.fsa.list';
  }  
}

1;
