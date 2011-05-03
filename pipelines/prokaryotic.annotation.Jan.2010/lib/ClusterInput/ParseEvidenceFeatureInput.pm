package ISGA::ClusterOutput::ParseEvidenceFeatureInput;

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
  
  if ( exists $components{'start_site_curation.default'} ){
    return '$;REPOSITORY_ROOT$;/output_repository/start_site_curation/$;PIPELINEID$;_default/start_site_curation.bsml.list';
  }else{
    return '$;REPOSITORY_ROOT$;/output_repository/promote_gene_prediction/$;PIPELINEID$;_promote_prediction/promote_gene_prediction.bsml.list';
  }
  
}

1;
