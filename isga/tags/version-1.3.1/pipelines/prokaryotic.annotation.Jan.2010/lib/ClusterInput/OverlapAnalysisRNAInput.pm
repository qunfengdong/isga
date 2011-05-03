package ISGA::ClusterInput::OverlapAnalysisRNAInput;

use warnings;
use strict;

use base 'ISGA::ClusterInput';

my %_Overlap_Analysis_RNA_input =
  ( 'tRNAscan-SE.find_tRNA' => '$;REPOSITORY_ROOT$;/output_repository/tRNAscan-SE/$;PIPELINEID$;_find_tRNA/tRNAscan-SE.bsml.list',
    'RNAmmer.default' => '$;REPOSITORY_ROOT$;/output_repository/RNAmmer/$;PIPELINEID$;_default/RNAmmer.bsml.list',
  );

#------------------------------------------------------------------------

=item public string getValue(RunBuilder $rb);

Calculates the file name(s) for a component input value.

=cut 
#------------------------------------------------------------------------
sub getValue {
  
  my ($self, $rb) = @_;
  
  my @input;
  
  my %components;
  
  # retrieve all the components in this pipeline
  foreach ( @{$rb->getPipeline->getComponents} ) {
    $components{ $_->getErgatisName } = 1;
  }
  
  while ( my ($key, $value) = each %_Overlap_Analysis_RNA_input ) {
    exists $components{ $key } and push @input, $value;
  }
  
  return join (',', @input);
}

1;
