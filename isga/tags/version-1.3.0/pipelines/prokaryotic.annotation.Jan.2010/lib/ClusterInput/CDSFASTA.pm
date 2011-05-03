package ISGA::ClusterInput::CDSFASTA;

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
  
  if ( exists $components{'glimmer3.iter2'} ){
    return '$;REPOSITORY_ROOT$;/output_repository/glimmer3/$;PIPELINEID$;_iter2/glimmer3.bsml.list';
  }else{
    return '$;REPOSITORY_ROOT$;/output_repository/geneprediction2bsml/$;PIPELINEID$;_default/geneprediction2bsml.bsml.list';
  }  
}

1;
