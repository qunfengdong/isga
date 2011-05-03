package ISGA::ClusterOutput::OverlapAnalysisEvidenceList;

use warnings;
use strict;

use base 'ISGA::ClusterInput';


my %_Overlap_Analysis_Evidence_input =
  ( 'hmmpfam.pre_overlap_analysis' => '$;REPOSITORY_ROOT$;/output_repository/hmmpfam/$;PIPELINEID$;_pre_overlap_analysis/hmmpfam.bsml.list',
    'ber.pre_overlap_analysis' => '$;REPOSITORY_ROOT$;/output_repository/ber/$;PIPELINEID$;_pre_overlap_analysis/ber.bsml.list',

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
  
  while ( my ($key, $value) = each %_Overlap_Analysis_Evidence_input ) {
    exists $components{ $key } and push @input, $value;
  }
  
  return join (',', @input);
}

1; 
