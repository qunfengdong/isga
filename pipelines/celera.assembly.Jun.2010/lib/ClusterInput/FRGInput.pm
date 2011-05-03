package ISGA::ClusterInput::FRGInput;

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
  
  # retrieve ergatis install
  my $p = $rb->getPipeline();
  
  my $ci = ISGA::ClusterInput->new( Name => 'Celera_Input', 
				    ErgatisInstall => $p->getErgatisInstall );
  
  my $pi = ISGA::PipelineInput->new( Pipeline => $rb->getPipeline,
				     ClusterInput => $ci );
  
  # retrieve number of pipeline inputs
  my $rbi_count = ISGA::RunBuilderInput->exists( RunBuilder => $rb, PipelineInput => $pi );
  
  my @dirs;

  for ( 1 .. $rbi_count ) {
    push @dirs, '$;REPOSITORY_ROOT$;/output_repository/sff_to_CA/$;PIPELINEID$;_default' . $_ . '/sff_to_CA.frg.list';
  }
  
  my $return =  join(',', @dirs);
  
  return $return;
}

1;
