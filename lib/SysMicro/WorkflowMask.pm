package SysMicro::WorkflowMask;
#------------------------------------------------------------------------
=pod

=head1 NAME

SysMicro::WorkflowMask is an object wrapper around a YAML piece that
describes which components of a global pipleline a user pipeline
executes.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use YAML;

use overload
  q{""}  => sub { return YAML::Dump($_[0]); };


# need to override string method to save

#------------------------------------------------------------------------

=item public WorkflowMask new(string $yaml);

Creates a new mask object based on the YAML string provided.

=cut
#------------------------------------------------------------------------
sub new {

  my ($class, $yaml) = @_;

  my $self = ( defined $yaml ? YAML::Load($yaml) : bless({}, $class) );

  exists $self->{cluster} or $self->{cluster} = {};
  exists $self->{component} or $self->{component} = {};

  return $self;
}

#------------------------------------------------------------------------

=item public { string => 'Disabled' } getDisabledClusters();

Returns an hash reference mapping cluster names to disabled status.

=cut
#------------------------------------------------------------------------
sub getDisabledClusters { return shift->{cluster}; }

#------------------------------------------------------------------------

=item public { string => 'Disabled' } getDisabledComponents();

Returns an hash reference mapping component names to disabled status.

=cut
#------------------------------------------------------------------------
sub getDisabledComponents {

  my $self = shift;

  my $disabled = {};

  while ( my ($key, $value) = each %{$self->{component}} ) {
    $disabled->{$key} = $value if $value eq 'disabled';    
  }
  
  return $disabled;
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

  my $disabled = $self->getDisabledComponents;

  foreach ( keys %$disabled ) {
    $disabled->{$_} = SysMicro::Component->new( ErgatisName => $_ );
  }

  foreach ( keys %{$self->getDisabledClusters} ) {

    my $cluster = SysMicro::Cluster->new( Name => $_ );

    foreach ( @{$cluster->getComponents} ) {
      $disabled->{ $_->getErgatisName } = $_;
    }
  }

  # now search on components 
  if ( my @values = values %$disabled ) {
    foreach ( @{SysMicro::Component->query( DependsOn => \@values )} ) {
      $self->{component}{ $_->getErgatisName } = 'orphaned';
    }
  }
}  

#------------------------------------------------------------------------

=item public void toggleCluster(Cluster $cluster);

Edits the WorkflowMask so that the supplied cluster will disabled if
it is currently active, and activated if it is currently disabled.

=cut
#------------------------------------------------------------------------
sub toggleCluster {

  my ($self, $cluster) = @_;

  my $name = $cluster->getName;

  if ( exists $self->{cluster}{$name} ) {
    delete $self->{cluster}{$name};
  } else {
    $self->{cluster}{$name} = 'disabled';
  }

  $self->recalculateOrphanedComponents();

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

=item public void toggleComponent(Component $component);

Edits the WorkflowMask so that the supplied component will disabled if
it is currently active, and activated if it is currently disabled.

=cut
#------------------------------------------------------------------------
sub toggleComponent {

 my ($self, $component) = @_;

 my $name = $component->getErgatisName;

 if ( exists $self->{component}{$name} ) {
   delete $self->{component}{$name};
 } else {
   $self->{component}{$name} = 'disabled';
 }

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

