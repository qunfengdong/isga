package ISGA::ModuleInstaller::Cluster;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::Cluster> provides methods for
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
sub getYAMLFile { return "cluster.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $tuple) = @_;
  
  return { ErgatisInstall => $ml->getErgatisInstall, Name => $tuple->{Name} };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
  my %args = (Name => $t->{Name},
	      LayoutXML => $t->{LayoutXML},
	      Description => $t->{Description},
	      ErgatisInstall => $ml->getErgatisInstall,
	     );

  exists $t->{SubClass} and $args{SubClass} = $t->{SubClass};
  exists $t->{IteratesOn} and 
    $args{IteratesOn} = ISGA::ClusterInput->new( Name => $t->{IteratesOn}, 
						 ErgatisInstall => $ml->getErgatisInstall);

  ISGA::Cluster->create(%args);
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, Cluster $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $o, $t) = @_;
  
  my %args = (
	      LayoutXML => $t->{LayoutXML},
	      Description => $t->{Description},
	      ErgatisInstall => $ml->getErgatisInstall,
	     );
  
  exists $t->{SubClass} and $args{SubClass} = $t->{SubClass};
  exists $t->{IteratesOn} and 
    $args{IteratesOn} = ISGA::ClusterInput->new( Name => $t->{IteratesOn}, 
						 ErgatisInstall => $ml->getErgatisInstall);

  $o->edit(%args);
}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, Cluster $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied Cluster object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $o, $t) = @_;

  $o->getName ne $t->{Name} and 
    X::API->throw( message => "Name does not match entry for Cluster $t->{Name}\n" );

  $o->getLayoutXML ne $t->{LayoutXML} and 
    X::API->throw( message => "LayoutXML does not match entry for Cluster $t->{Name}\n" );

  $o->getDescription ne $t->{Description} and 
    X::API->throw( message => "FileFormat does not match entry for Cluster $t->{Name}\n" );

  my $SubClass = $o->getSubClass();
  ( defined $SubClass xor exists $t->{SubClass} ) and
    X::API->throw( message => "SubClass does not match entry for Cluster $t->{Name}\n" );   
  defined $SubClass and $SubClass ne $t->{SubClass} and
    X::API->throw( message => "SubClass does not match entry for Cluster $t->{Name}\n" );   

  my $IteratesOn = $o->getIteratesOn();
  ( defined $IteratesOn xor exists $t->{IteratesOn} ) and
    X::API->throw( message => "IteratesOn does not match entry for Cluster $t->{Name}\n" );   
  defined $IteratesOn and 
    ($IteratesOn->getName ne $t->{IteratesOn} or 
     $IteratesOn->getErgatisInstall != $ml->getErgatisInstall) and
    X::API->throw( message => "IteratesOn does not match entry for Cluster $t->{Name}\n" );  

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
