package ISGA::ClusterInput::COGBSML;

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
  
  if ( exists $components{'ncbi-blastp.COGS'} ){
    return '$;REPOSITORY_ROOT$;/output_repository/ncbi-blastp/$;PIPELINEID$;_COGS/ncbi-blastp.bsml.list';
  }else{
    return '';
  }  
}

1;
