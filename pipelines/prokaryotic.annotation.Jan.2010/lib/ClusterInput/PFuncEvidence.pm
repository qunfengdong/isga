package ISGA::ClusterOutput::PFuncEvidence;

use warnings;
use strict;

use base 'ISGA::ClusterInput';

my %_p_func_input = 
  ( 'parse_evidence.hmmpfam_pre' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_hmmpfam_pre/parse_evidence.tab.list',
    
    'parse_evidence.hmmpfam_post' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_hmmpfam_post/parse_evidence.tab.list',
    
    'parse_evidence.ber_pre' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_ber_pre/parse_evidence.tab.list',
    
    'parse_evidence.ber_post' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_ber_post/parse_evidence.tab.list',
    
    'parse_evidence.tmhmm' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_tmhmm/parse_evidence.tab.list',
    
    'parse_evidence.lipoprotein' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_lipoprotein/parse_evidence.tab.list',

    'parse_evidence.priam_ec' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_priam_ec/parse_evidence.tab.list',

    'parse_evidence.hypothetical' => '$;REPOSITORY_ROOT$;/output_repository/parse_evidence/$;PIPELINEID$;_hypothetical/parse_evidence.tab.list',
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
  
  while ( my ($key, $value) = each %_p_func_input ) {
    exists $components{ $key } and push @input, $value;
  }
  
  return join (',', @input);
}

1;
