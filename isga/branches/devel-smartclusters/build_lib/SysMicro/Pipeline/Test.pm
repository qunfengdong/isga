package SysMicro::Pipeline::Test;
#------------------------------------------------------------------------
=pod

=head1 NAME

SysMicro::Pipeline::Test - test methods for the pipeline class.

=head1 METHODS

=over 4

=item use

=back

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use Test::Deep qw(cmp_deeply bag);
use Test::Exception;
use Test::More;

use SysMicro;
use SysMicro::Objects;

use base 'Test::Class';

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void _0_base();

Test object methods and attribute to column mappings.
 
=cut
#------------------------------------------------------------------------
sub _0_base : Test( 47 ) {

  my $class = 'SysMicro::Pipeline';

  use_ok( $class );  # a gimme

  # methods inherited from indexed
  can_ok( $class, 'new' );
  can_ok( $class, 'getId' );
  can_ok( $class, 'edit' );
  can_ok( $class, '_column' );
  can_ok( $class, '_icmp' );
  can_ok( $class, '_scmp' );
  can_ok( $class, 'delete' );
  can_ok( $class, 'create' );
  can_ok( $class, 'query' );
  can_ok( $class, 'exists' );
  can_ok( $class, '_set_page' );
  can_ok( $class, '__read' );
  can_ok( $class, '__read_cache' );
  can_ok( $class, '__read_and_add_to_cache' );

  # methods created from .base
  can_ok( $class, 'getPipelinePartition' );
  can_ok( $class, 'getName' );
  can_ok( $class, 'getStatus' );
  can_ok( $class, 'getDescription' );
  can_ok( $class, 'getParties' );
  can_ok( $class, 'hasParty' );
  can_ok( $class, '__update' );
  can_ok( $class, 'addParty' );
  can_ok( $class, 'removeParty' );
  can_ok( $class, '__create' );
  can_ok( $class, '__base_read' );
  can_ok( $class, '_table' );
  can_ok( $class, '_sequence' );

  # methods defined in .accessor
  can_ok( $class, 'getWorkflowMask' );
  can_ok( $class, 'getRawWorkflowMask' );
  can_ok( $class, 'getClusters' );
  can_ok( $class, 'getComponents' );
  can_ok( $class, 'getPipelineLayoutXML' );
  can_ok( $class, 'getConfigFiles' );
  can_ok( $class, 'getInputs' );
  can_ok( $class, 'getOutputs' );
  can_ok( $class, 'getOutputsByCluster' );

  # methods defined in .method  
  can_ok( $class, 'draw' );
  can_ok( $class, 'writeConfigFiles' );

  # test attributes
  is( $class->_table(), 'pipeline' );
  is( $class->_column('Id'), 'pipeline_id' );
  is( $class->_column('PipelinePartition'), 'pipelinepartition_id' );
  is( $class->_column('Name'), 'pipeline_name' );
  is( $class->_column('WorkflowMask'), 'pipeline_workflowmask' );
  is( $class->_column('Status'), 'pipelinestatus_id' );
  is( $class->_column('Description'), 'pipeline_description' );

}





1;

__END__

=back

=head1 DIAGNOSTICS

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
