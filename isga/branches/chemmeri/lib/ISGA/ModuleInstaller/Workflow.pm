package ISGA::ModuleInstaller::Workflow;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::Workflow> provides methods for
installing workflow information for a pipeline.

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
sub getYAMLFile { return 'workflow.yaml'; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $t) = @_;
  
  return { Pipeline => ISGA::GlobalPipeline->new( Name => $ml->getPipelineName(), Version => $ml->getVersion()),
	   Cluster => ISGA::Cluster->new( Name => $t->{Cluster}, ErgatisInstall => $ml->getErgatisInstall()) };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $t );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
  my $ei = $ml->getErgatisInstall();
  
  my %args = ( 
	      Pipeline => ISGA::GlobalPipeline->new( Name => $ml->getPipelineName(), Version => $ml->getVersion()),
	      Cluster => ISGA::Cluster->new( Name => $t->{Cluster}, ErgatisInstall => $ml->getErgatisInstall()),
	      IsRequired => $t->{IsRequired},
	      Customization => $t->{Customization},
	     );
  if ( exists $t->{AlternateCluster} ){
    $args{AltCluster} = ISGA::Cluster->new( Name => $t->{AlternateCluster}, ErgatisInstall => $ml->getErgatisInstall());
  }
  if ( exists $t->{Coordinates} ) {
    $args{Coordinates} = $t->{Coordinates};
  }

  ISGA::Workflow->create(%args);
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, Pipeline $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $o, $t) = @_;
  
  my $ei = $ml->getErgatisInstall();

  my %args = ( 
	      Pipeline => ISGA::GlobalPipeline->new( Name => $ml->getPipelineName(), Version => $ml->getVersion()),
	      Cluster => ISGA::Cluster->new( Name => $t->{Cluster}, ErgatisInstall => $ml->getErgatisInstall()),
	      IsRequired => $t->{IsRequired},
	      Customization => $t->{Customization},
	     );

  if ( exists $t->{Coordinates} ) {
    $args{Coordinates} = $t->{Coordinates};
  } else {
    $args{Coordinates} = undef;
  }

  $o->edit(%args);
}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, Pipeline $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied Pipeline object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $o, $t) = @_;

  my $pipeline_name = $ml->getPipelineName();

  my $Coordinates = $o->getCoordinates();
  ( defined $Coordinates xor exists $t->{Coordinates} ) and
    X::API->throw( message => "Coordinates do not match entry for Workflow $pipeline_name $t->{Cluster}\n" );
  defined $Coordinates and $Coordinates ne $t->{Coordinates} and
    X::API->throw( message => "Coordinates does not match entry for Workflow $pipeline_name $t->{Cluster}\n" );

  ( $o->getCustomization ne $t->{Customization} ) and
    X::API->throw( message => "Customization does not match entry for Workflow $pipeline_name $t->{Cluster}\n" );

  ( $o->isRequired xor $t->{IsRequired} ) and
    X::API->throw( message => "IsRequired does not match entry for Workflow $pipeline_name $t->{Cluster}\n" );

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
