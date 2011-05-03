package ISGA::ModuleInstaller::Component;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::Component> provides methods for
installing component template information for a pipeline.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use base 'ISGA::ModuleInstaller::Base';

use YAML;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string getYAMLFile();

Returns the name of the yaml file for this class.

=cut 
#------------------------------------------------------------------------
sub getYAMLFile { return "component.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $tuple) = @_;
  
  return { ErgatisInstall => $ml->getErgatisInstall, ErgatisName => $tuple->{ErgatisName} };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
  my $ei = $ml->getErgatisInstall();
  
  my %args = (Name => $t->{Name},
	      ErgatisName => $t->{ErgatisName},
	      Cluster => ISGA::Cluster->new( Name => $t->{Cluster}, ErgatisInstall => $ei ),
	      Template => ISGA::ComponentTemplate->new( Name => $t->{Template}, ErgatisInstall => $ei ),
	      Index => $t->{Index},
	      ErgatisInstall => $ml->getErgatisInstall,
	     );


  exists $t->{SubClass} and $args{SubClass} =  $t->{SubClass};

  exists $t->{Name} and $args{Name} = $t->{Name};

  exists $t->{DependsOn} and 
    $args{DependsOn} = ISGA::Component->new( ErgatisName => $t->{DependsOn}, ErgatisInstall => $ei);

  exists $t->{CopyParameterMask} and 
    $args{CopyParameterMask} = ISGA::Component->new( ErgatisName => $t->{CopyParameterMask}, ErgatisInstall => $ei);

  my $o = ISGA::Component->create(%args);
  
  # check for mapped ClusterInputs
  if ( exists $t->{ClusterInput} ) {
    foreach ( map { ISGA::ClusterInput->new(Name => $_, ErgatisInstall => $ei) } @{$t->{ClusterInput}} ) {
      $o->addClusterInput($_);
    }
  }

}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, Component $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $o, $t) = @_;
  
  my $ei = $ml->getErgatisInstall();
  
  my %args = (
	      ErgatisName => $t->{ErgatisName},
	      Cluster => ISGA::Cluster->new( Name => $t->{Cluster}, ErgatisInstall => $ei ),
	      Template => ISGA::ComponentTemplate->new( Name => $t->{Template}, ErgatisInstall => $ei ),
	      Index => $t->{Index},
	      ErgatisInstall => $ml->getErgatisInstall,
	     );

  exists $t->{SubClass} and $args{SubClass} =  $t->{SubClass};

  exists $t->{Name} and $args{Name} = $t->{Name};

  exists $t->{DependsOn} and 
    $args{DependsOn} = ISGA::Component->new( ErgatisName => $t->{DependsOn}, ErgatisInstall => $ei);

  exists $t->{CopyParameterMask} and 
    $args{CopyParameterMask} = ISGA::Component->new( ErgatisName => $t->{CopyParameterMask}, ErgatisInstall => $ei);

  $o->edit(%args);

  # check for mapped ClusterInputs
  if ( exists $t->{ClusterInput} ) {
    foreach ( map { ISGA::ClusterInput->new(Name => $_, ErgatisInstall => $ei) } @{$t->{ClusterInput}} ) {
      if ( ! $o->hasClusterInput($_) ) {
	$o->addClusterInput($_);
	$ml->log("Added Component to ClusterInput mapping\n");
      }
    }
  }

}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, Component $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied Component object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $o, $t) = @_;

  my $Name = $o->getName();
  ( defined $Name xor exists $t->{Name} ) and
    X::API->throw( message => "Name does not match entry for Component $t->{ErgatisName}\n" );   
  defined $Name and $Name ne $t->{Name} and
    X::API->throw( message => "Name does not match entry for Component $t->{ErgatisName}\n" );   
  
  $o->getCluster->getName ne $t->{Cluster} and
    X::API->throw( message => "Cluster does not match entry for Component $t->{ErgatisName}\n" );

  $o->getTemplate->getName ne $t->{Template} and
    X::API->throw( message => "Cluster does not match entry for Component $t->{ErgatisName}\n" );

  $o->getIndex != $t->{Index} and
    X::API->throw( message => "Index does not match entry for Component $t->{ErgatisName}\n" );

  my $DependsOn = $o->getDependsOn();
  ( defined $DependsOn xor exists $t->{DependsOn} ) and
    X::API->throw( message => "DependsOn does not match entry for Component $t->{ErgatisName}\n" );   
  defined $DependsOn and $DependsOn->getErgatisName ne $t->{DependsOn} and
    X::API->throw( message => "DependsOn does not match entry for Component $t->{ErgatisName}\n" );   
  my $SubClass = $o->getSubClass();
  ( defined $SubClass xor exists $t->{SubClass} ) and
    X::API->throw( message => "SubClass does not match entry for Component $t->{ErgatisName}\n" );   
  defined $SubClass and $SubClass ne $t->{SubClass} and
    X::API->throw( message => "SubClass does not match entry for Component $t->{ErgatisName}\n" ); 

  my $CopyParameterMask = $o->getCopyParameterMask();
  ( defined $CopyParameterMask xor exists $t->{CopyParameterMask} ) and
    X::API->throw( message => "CopyParameterMask does not match entry for Component $t->{ErgatisName}\n" );   
  defined $CopyParameterMask and $CopyParameterMask->getErgatisName ne $t->{CopyParameterMask} and
    X::API->throw( message => "CopyParameterMask does not match entry for Component $t->{ErgatisName}\n" );   
  # check for mapped ClusterInputs
  if ( exists $t->{ClusterInput} ) {
    foreach ( map { ISGA::ClusterInput->new(Name => $_, ErgatisInstall => $ml->getErgatisInstall) } @{$t->{ClusterInput}} ) {
      if ( ! $o->hasClusterInput($_) ) {
	$o->addClusterInput($_);
	$ml->log("Added Component to ClusterInput mapping\n");
      }
    }
  }
  
}

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
