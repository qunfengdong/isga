# -*- cperl -*-
package SysMicro::WorkflowBuilder;

use strict;
use warnings;

use GD::Image;
use Graph::Directed;

#------------------------------------------------------------------------

=item public WorkflowBuilder new( PipelineBuilder $pipeline_builder);

Builds a workflow.

=cut
#------------------------------------------------------------------------
sub new {

  my ( $class, $pipeline_builder ) = @_;

  # create ourselves
  my $self = 
    bless { pipeline => $pipeline_builder->getPipeline,
   	    clusters => {},
	    tiedclusters => {},
	    start => {},
	    drawcount => 0,  # need this to make sure browser doesn't cache
	    stop => {} }, $class;
  
  # use the workflow mask to grab our start/stop info
  my $wfMask = $pipeline_builder->getWorkflowMask();

  $self->{start}{$_} = 1 for @{$wfMask->getStart};
  $self->{stop}{$_} = 1 for @{$wfMask->getStop};

  # initialize the graph
  $self->_initializeGraph();
  
  return $self;
}

#------------------------------------------------------------------------

=item public void _initializeGraph();

Create the graph for this workflow.

=cut
#------------------------------------------------------------------------
sub _initializeGraph {

  my $self = shift;

  # create the graph
  my $g = Graph::Directed->new();
  
  my @clusters = @{SysMicro::Workflow->query( Pipeline => $self->{pipeline} )};

  # everything starts as off
  $_->setIsOn(0) for @clusters;

  # add all the nodes
  $g->add_vertex($_) for @clusters;

  # pulling vertices from a Graph breaks refs, so we deal with the original 
  # clusters here
  foreach my $cluster ( @clusters ) {

    # save the cluster for later
    $self->{clusters}{ $cluster } = $cluster;
    
    exists $self->{start}{ $cluster }
      and $self->{clusters}{ $cluster }->setIsStart(1);
    exists $self->{stop}{ $cluster }
      and $self->{clusters}{ $cluster }->setIsStop(1);

    # add edges
    $g->add_edge( $cluster, $_ ) for @{$cluster->getChildren};
  }

  # traverse the little trees
  for my $cluster ( grep { $_->isStart() } values %{$self->{clusters}} ) {
    
    # turn this cluster on
    $cluster->setIsOn(1);

    $self->_setStartingState($g, $_)
      for grep { ! $_->isStop } $g->successors( $cluster );
  }

  $self->{graph} = $g;
}

#------------------------------------------------------------------------

=item PRIVATE void _setStartingState();

Recursive helper for building the starting state of the graph

=cut
#------------------------------------------------------------------------
sub _setStartingState {

  my ($self, $g, $cluster) = @_;

  $cluster->setIsOn(1);

  $self->_setStartingState($g,$_)
    for grep { ! $_->isStop } $g->successors($cluster);
}
  

#------------------------------------------------------------------------

=item public WorkflowBuilder restore();

Restore WorkflowBuilder from the apache session.

=cut
#------------------------------------------------------------------------
sub restore {

  my ($class, $pipeline_builder) = @_;
  
  my $key = "PipelineBuilderWorkflow$pipeline_builder";

  if ( exists $SysMicro::Session->{$key} ) {
    return $SysMicro::Session->{$key};
  } 

  X::Session::Param::Missing->throw( param => $key );
}

#------------------------------------------------------------------------

=item public [int] getStart();

Returns an array reference to start clusters in the workflow.

=cut
#------------------------------------------------------------------------
sub getStart {

  my $self = shift;
  return [map { "$_" } grep { $_->isStart } values %{$self->{clusters}}];
}

#------------------------------------------------------------------------

=item public [int] getStop();

Returns an array reference to stop clusters in the workflow.

=cut
#------------------------------------------------------------------------
sub getStop {

  my $self = shift;
  return [map { "$_" } grep { $_->isStop } values %{$self->{clusters}}];
}

sub getPipeline { return $_[0]->{pipeline}; }
sub getGraph { return $_[0]->{graph}; }
sub getDrawCount { return $_[0]->{drawcount}; }

#------------------------------------------------------------------------

=item public string update(int $click);

Record a click on the workflow.

=cut
#------------------------------------------------------------------------
sub update {

  my ($self, $click) = @_;

  my $cluster = $self->{clusters}{$click};

  if ( $cluster->isStart() ) {

    $cluster->setIsStart();
    $cluster->setIsOn();
    $self->_turnOff($_) for $self->getGraph->successors($cluster);

  } elsif ( $cluster->isStop() ) {

    $cluster->setIsStop();
    $cluster->setIsOn(1);
    $self->_turnOn($_) for $self->getGraph->successors($cluster);

  } elsif ( $cluster->isOn() ) {
  
    $cluster->setIsStop(1);
    $cluster->setIsOn();
    $self->_turnOff($_) for $self->getGraph->successors($cluster);

  } else {

    $cluster->setIsStart(1);
    $cluster->setIsOn(1);
    $self->_turnOn($_) for $self->getGraph->successors($cluster);

  }
}

sub _turnOff {

  my ($self, $v) = @_;

  if ( $v->isOn ) {
    $v->setIsOn();
    $self->_turnOff($_) for $self->getGraph->successors($v);
  } elsif ( $v->isStop ) {
    $v->setIsStop();
  }
}

sub _turnOn {

  my ($self, $v) = @_;

  if ( ! $v->isOn ) {
    $v->setIsOn(1);
    $self->_turnOn($_) for $self->getGraph->successors($v);
  } elsif ( $v->isStart ) {
    $v->setIsStart();
  }
}  


#------------------------------------------------------------------------

=item public [Cluster] getActiveClusters();

Returns a reference to an array of the clusters active in this builder.

=cut
#------------------------------------------------------------------------
sub getActiveClusters {

 my $self = shift;

 return [map { $_->getCluster } grep { $_->isOn } values %{$self->{clusters}}];
}

#------------------------------------------------------------------------

=item public string draw();

Draw a graphic of the users custom pipeline.

=cut
#------------------------------------------------------------------------
sub draw {

  my $self = shift;

  $self->{drawcount}++;

  my $image = GD::Image->new('/data/web/sysmicro.cgb/docs/masoncomp/www' . 
			     $self->getPipeline->getImage );

  my $white = $image->colorClosest(255,255,255);
  my $grey = $image->colorAllocate(227,227,227);
  my $green = $image->colorAllocate(188,243,103);
  
  foreach my $cluster ( values %{$self->{clusters}} ) {

    if ( $cluster->isOn ) {

      my @coords = split ( /,/, $cluster->getCoordinates );
      
      for ( my $i = $coords[0]; $i <= $coords[2]; $i++ ) {
	for ( my $j = $coords[1]; $j <= $coords[3]; $j++ ) {
	  $image->setPixel($i,$j, $green) if $image->getPixel($i,$j) == $white;
	}
      }
    }
  }
  
  print $image->png;
}


1;
