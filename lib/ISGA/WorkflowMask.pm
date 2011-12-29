package ISGA::WorkflowMask;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::WorkflowMask is an object wrapper around a YAML document that
describes which clusters and components in a pipeline have been
disabled or orphaned by upstream disabled components.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use YAML;

use overload
  q{""}  => sub { return YAML::Dump($_[0]); };

#------------------------------------------------------------------------

=item public WorkflowMask new(string $yaml);

Creates a new mask object based on the YAML string provided.

=item public WorkflowMask new(string $yaml, ErgatisInstall $install);

Creates a new mask object based on the YAML string provided, using the provided ErgatisInstall

=cut
#------------------------------------------------------------------------
sub new {

  my ($class, $yaml, $ergatis_install) = @_;

  my $self = ( defined $yaml ? YAML::Load($yaml) : bless({}, $class) );

  exists $self->{cluster} or $self->{cluster} = {};
  exists $self->{component} or $self->{component} = {};

  if ( ! exists $self->{ergatis_install} ) {
    
    $ergatis_install or X::API->throw( message => "You must supply an Ergatis install for a WorkflowMask" );
    
    $self->{ergatis_install} = $ergatis_install->getName();
  }

  return $self;
}

#------------------------------------------------------------------------

=item public [Cluster] getDisabledClusters();

Returns a reference to an array of disabled clusters in this workflow mask.

=cut
#------------------------------------------------------------------------
sub getDisabledClusters { 

  my $self = shift;

  return ISGA::Cluster->query( Name => [keys %{$self->{cluster}}], ErgatisInstall => $self->getErgatisInstall);
}

#------------------------------------------------------------------------

=item public ErgatisInstall getErgatisInstall();

Returns the Ergatis isntallation this workflow mask is tied to.

=cut
#------------------------------------------------------------------------
sub getErgatisInstall { 

  my $self = shift;
  
  return ISGA::ErgatisInstall->new( Name => $self->{ergatis_install} );
}

#------------------------------------------------------------------------

=item public [Component] getDisabledComponents();

Returns reference to an array of disabled components in the workflow mask.

=cut
#------------------------------------------------------------------------
sub getDisabledComponents {

  my $self = shift;

  my @search;
  
  while ( my ($key, $value) = each %{$self->{component}} ) {
    push @search, $key if $value eq 'disabled';
  }

  return ISGA::Component->query( ErgatisName => \@search, ErgatisInstall => $self->getErgatisInstall);
}

#------------------------------------------------------------------------

=item public bool isActive(Cluster $cluster);

Returns true if the cluster is active in this workflow mask.

=item public bool isActive(Component $component);

Returns true if the component is active in this workflow mask.

=cut
#------------------------------------------------------------------------
sub isActive {

  my ($self, $obj) = @_;

  # TODO: This should make sure the object is a cluster or component
  # TODO: It should also throw an exception if the cluster or component 
  #       isn't tied to the mask.

  # process cluster 
  if ( $obj->isa('ISGA::Cluster') ) {
    return ! exists $self->{cluster}{$obj->getName};
  }

  # process component
  if ( exists $self->{component}{$obj->getErgatisName} ) {
    return 0;
  }
  return ! exists $self->{cluster}{$obj->getCluster->getName};  
}

#------------------------------------------------------------------------

=item public { string => 'Orphaned' } getOrphanedComponents();

Returns an hash reference mapping component names to orphaned status.

=cut
#------------------------------------------------------------------------
sub getOrphanedComponents {

  my $self = shift;

  my $orphaned = {};

  while ( my ($key, $value) = each %{$self->{component}} ) {
    $orphaned->{$key} = $value if $value eq 'orphaned';
  }
  
  return $orphaned;
}

#------------------------------------------------------------------------

=item public void recalculateOrphanedComponents {

Removes all orphaned components from the workflow and calculates them
again based on the currently disabled clusters and components.

=cut
#------------------------------------------------------------------------
sub recalculateOrphanedComponents {

  my $self = shift;

  # remove existing orphaned components
  delete $self->{component}{$_} for keys %{$self->getOrphanedComponents};

  my $disabled = {};

  # retrieve the explicitely disabled components
  foreach ( @{$self->getDisabledComponents} ) {
    $disabled->{ $_->getErgatisName } = $_;
  }

  # this may not be necessary if we limit dependent components to within a cluster
  foreach my $cluster ( @{$self->getDisabledClusters} ) {
    foreach ( @{$cluster->getComponents} ) {
      $disabled->{ $_->getErgatisName } = $_;
    }
  }

  # if there are 
  if ( my @values = values %$disabled ) {
    foreach ( @{ISGA::Component->query( DependsOn => \@values )} ) {
      # use ||= so we don't overwrite any 'disabled' components
      $self->{component}{ $_->getErgatisName } ||= 'orphaned';
    }
  }
}  

#------------------------------------------------------------------------

=item public void disableCluster(Cluster $cluster);

Edits the WorkflowMask so that the supplied cluster will not be
run. This function is idempotent.

=cut
#------------------------------------------------------------------------
sub disableCluster {

  my ($self, $cluster) = @_;

  $self->{cluster}{$cluster->getName} = 'disabled';

  $self->recalculateOrphanedComponents();

}

#------------------------------------------------------------------------

=item public void enableCluster(Cluster $cluster);

Edits the WorkflowMask so that the supplied cluster will be run. This
function is idempotent.

=cut
#------------------------------------------------------------------------
sub enableCluster {

  my ($self, $cluster) = @_;

  my $name = $cluster->getName;

  exists $self->{cluster}{$name} and delete $self->{cluster}{$name};

  $self->recalculateOrphanedComponents();

}

#------------------------------------------------------------------------

=item public void disableComponent(Component $component);

Edits the WorkflowMask so that the supplied component will not be
run. This function is idempotent.

=cut
#------------------------------------------------------------------------
sub disableComponent {

  my ($self, $component) = @_;

  $self->{component}{$component->getErgatisName} = 'disabled';

  $self->recalculateOrphanedComponents();

}

#------------------------------------------------------------------------

=item public void enableComponent(Component $component);

Edits the WorkflowMask so that the supplied component will be run. This
function is idempotent.

=cut
#------------------------------------------------------------------------
sub enableComponent {

  my ($self, $component) = @_;

  my $name = $component->getErgatisName;

  exists $self->{component}{$name} and delete $self->{component}{$name};

  $self->recalculateOrphanedComponents();

}


1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=item X::API::Parameter

=item X::API::Compare

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut

