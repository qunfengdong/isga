package ISGA::ModuleInstaller::GlobalPipeline;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::Pipeline> provides methods for
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
sub getYAMLFile { return "pipeline.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $t) = @_;
  
  return { Version => $t->{Version}, Name => $t->{Name} };
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
	      Name => $t->{Name},
	      Description => $t->{Description},
	      Image => $t->{Image},
	      Version => $t->{Version},
	      Release => $t->{Release},
	      Status => ISGA::PipelineStatus->new( Name => $t->{Status} ),
	      Layout => $t->{Layout},
	      ErgatisInstall => $ei,
	     );

  exists $t->{SubClass} and $args{SubClass} =  $t->{SubClass};

  # check for overridden status
  if ( my $status = $ml->getStatus ) {
    $args{Status} = ISGA::PipelineStatus->new( Name => $status );
  }

  my $o = ISGA::GlobalPipeline->create(%args);

  $class->initializePipelineConfiguration($o);

  # save the pipeline name
  $ml->setPipelineName($t->{Name});  
}

#------------------------------------------------------------------------

=item public void initializePipelineConfiguration(GlobalPipeline $o);

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub initializePipelineConfiguration {

  my ($class, $o) = @_;

  ISGA::PipelineConfiguration->create( 
				      Pipeline => $o, Value => '',
				      Variable => ISGA::ConfigurationVariable->new( Name => 'ergatis_project_directory' ));

  ISGA::PipelineConfiguration->create( 
				      Pipeline => $o, Value => '',
				      Variable => ISGA::ConfigurationVariable->new( Name => 'ergatis_submission_directory' ));

  ISGA::PipelineConfiguration->create( 
				      Pipeline => $o, Value => '',
				      Variable => ISGA::ConfigurationVariable->new( Name => 'ergatis_project_name' ));

  ISGA::PipelineConfiguration->create( 
				      Pipeline => $o, Value => 1,
				      Variable => ISGA::ConfigurationVariable->new( Name => 'access_permitted' ));
  
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
	      Description => $t->{Description},
	      Image => $t->{Image},
	      Version => $t->{Version},
	      Release => $t->{Release},
	      Status => ISGA::PipelineStatus->new( Name => $t->{Status} ),
	      Layout => $t->{Layout},
	     );

  exists $t->{SubClass} and $args{SubClass} =  $t->{SubClass};

  # check for overridden status
  if ( my $status = $ml->getStatus ) {
    $args{Status} = ISGA::PipelineStatus->new( Name => $status );
  }

  $o->edit(%args);
  
  $class->initializePipelineConfiguration($o);

  # save the pipeline name
  $ml->setPipelineName($t->{Name});  

}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, Pipeline $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied Pipeline object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $o, $t) = @_;

  $o->getDescription ne $t->{Description} and
    X::API->throw( message => "Description does not match entry for Pipeline $t->{Name}\n" );

  $o->getImage ne $t->{Image} and
    X::API->throw( message => "Image does not match entry for Pipeline $t->{Name}\n" );

  $o->getRelease ne $t->{Release} and
    X::API->throw( message => "Release does not match entry for Pipeline $t->{Name}\n" );

  $o->getStatus->getName ne $t->{Status} and
    X::API->throw( message => "Status does not match entry for Pipeline $t->{Name}\n" );

  $o->getLayout ne $t->{Layout} and
    X::API->throw( message => "Layout does not match entry for Pipeline $t->{Name}\n" );

  my $SubClass = $o->getSubClass();
  ( defined $SubClass xor exists $t->{SubClass} ) and
    X::API->throw( message => "SubClass does not match entry for Pipeline $t->{Name}\n" );   
  defined $SubClass and $SubClass ne $t->{SubClass} and
    X::API->throw( message => "SubClass does not match entry for Pipeline $t->{Name}\n" );   

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
