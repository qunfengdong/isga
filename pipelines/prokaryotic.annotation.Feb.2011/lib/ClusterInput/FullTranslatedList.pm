package ISGA::ClusterInput::FullTranslatedList;

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
    return '$;REPOSITORY_ROOT$;/output_repository/translate_sequence/$;PIPELINEID$;_final_polypeptides/translate_sequence.fsa.list';
  }else{
    return '$;REPOSITORY_ROOT$;/output_repository/translate_sequence/$;PIPELINEID$;_translate/translate_sequence.fsa.list';
  }
}

1;
