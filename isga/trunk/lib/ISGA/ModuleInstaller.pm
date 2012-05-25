package ISGA::ModuleInstaller;

use strict;
use warnings;

use ISGA::ModuleInstaller::ComponentTemplate;
use ISGA::ModuleInstaller::Cluster;
use ISGA::ModuleInstaller::ClusterInput;
use ISGA::ModuleInstaller::ClusterOutput;
use ISGA::ModuleInstaller::Component;
use ISGA::ModuleInstaller::FileFormat;
use ISGA::ModuleInstaller::FileType;
use ISGA::ModuleInstaller::GlobalPipeline;
use ISGA::ModuleInstaller::PipelineInput;
use ISGA::ModuleInstaller::Workflow;
use ISGA::ModuleInstaller::Software;
use ISGA::ModuleInstaller::Reference;
use ISGA::ModuleInstaller::ReferenceLabel;
use ISGA::ModuleInstaller::ReferenceFormat;
use ISGA::ModuleInstaller::ReferenceTemplate;

use File::Copy;
use File::Path;
use File::Find;
use File::Copy::Recursive;

#------------------------------------------------------------------------

=item public void new();

Creates a pipeline installer object. Available named parameters are:

source => string

The path to retrieve the pipeline source from.

force_install => boolean

Will install even if database conflicts are found.

status

=cut 
#------------------------------------------------------------------------
sub new {

  my ($class, %options) = @_;

  my $source_path = $options{source};

  my $self = YAML::LoadFile("$source_path/CONFIG.yaml");
  
  # set source path
  $self->{source_path} = $source_path;

  $self->{force_install} = ( exists $options{force_install} ?  1 : 0 );

  # are we overriding the source
  if ( exists $options{status} ) {
    $self->{status} = $options{status};
  }

  # retrieve Ergatis Install
  $self->{ergatis_install} = ISGA::ErgatisInstall->new( Name => $self->{ergatis_install} );

  # retrieve pipeline version
  $self->loadVersion();
   
  return $self;
}

sub loadVersion {

  my $self = shift;

  my $file = YAML::LoadFile( join('/', $self->getDatabaseSourcePath(), 'pipeline.yaml') );

  $self->{version} = $file->[0]{Version};
}


sub isForced { return shift->{force_install}; }

sub getVersion { return shift->{version}; }
sub getErgatisInstall { return shift->{ergatis_install}; }
sub getSourcePath { return shift->{source_path}; }
sub getClassName { return shift->{pipeline_class}; }

sub isAlreadyInstalled {
  my $self = shift;
  return ISGA::GlobalPipeline->exists( SubClass => $self->getClassName );
}

sub getStatus {
  my $self = shift;
  return exists $self->{status} ? $self->{status} : undef;
}

sub setPipelineName {
  my ($self, $name) = @_;
  $self->{pipeline_name} = $name;
}

sub getPipelineName {
  my $self = shift;
  return exists $self->{pipeline_name} ? $self->{pipeline_name} : undef;
}

sub getClassPath { 

  my $class = shift->{pipeline_class};
  $class =~ s{::}{/}g;
  
  return $class;
}

sub getDatabaseSourcePath {

  my $self = shift;
  return join('/', $self->getSourcePath(), 'database');
}

sub getIncludeSourcePath {

  my $self = shift;
  return join('/', $self->getSourcePath(), 'include');
}

sub getLibrarySourcePath {

  my $self = shift;
  return join('/', $self->getSourcePath(), 'lib');
}

sub getMasonSourcePath {

  my $self = shift;
  return join('/', $self->getSourcePath(), 'masoncomp', $self->getClassPath );
}

sub log {

  my ($self, $string) = @_;

  print "$string\n";
}


#------------------------------------------------------------------------

=item public void install();

Manages the installation of a pipeline

=cut 
#------------------------------------------------------------------------
sub install {

  my $self = shift;

  $self->installIncludeFiles();
  $self->installMasonFiles();
  $self->installLibraryFiles();

  unless ( $self->isAlreadyInstalled ) {

    ISGA::ModuleInstaller::FileFormat->load($self);
    ISGA::ModuleInstaller::FileType->load($self);
    ISGA::ModuleInstaller::ComponentTemplate->load($self);
    ISGA::ModuleInstaller::ClusterInput->load($self);
    ISGA::ModuleInstaller::Cluster->load($self);
    ISGA::ModuleInstaller::Component->load($self);
    ISGA::ModuleInstaller::ClusterOutput->load($self);
    ISGA::ModuleInstaller::GlobalPipeline->load($self);
    ISGA::ModuleInstaller::Workflow->load($self);
    ISGA::ModuleInstaller::PipelineInput->load($self);

  }

  # This is a hack for release 1.5 to force these new tables to be loaded - remove in 1.6
  ISGA::ModuleInstaller::Software->load($self);
  ISGA::ModuleInstaller::Reference->load($self);
  ISGA::ModuleInstaller::ReferenceLabel->load($self);
  ISGA::ModuleInstaller::ReferenceFormat->load($self);
  ISGA::ModuleInstaller::ReferenceTemplate->load($self);
  
}

#------------------------------------------------------------------------

=item public void installLibraryFiles();

Installs the Ergatis .config templates and YAML form definitions for
components.

=cut 
#------------------------------------------------------------------------
sub installLibraryFiles {

  my $self = shift;

  my $lib_dir = join( '/', '___package_lib___', 'ISGA' );

  # we need to change the permission on the directory
  
  #
  # TODO : this needs to diff files and only overwrite if force is set 
  #

#  File::Find::find( sub { return if -d $_;
#			  return unless /\.pm$/;
#			  require($File::Find::name);
#			  copy($File::Find::name, $lib_dir); },
#		    $self->getLibrarySourcePath() );

  File::Copy::Recursive::dircopy( $self->getLibrarySourcePath, $lib_dir );
}
  
#------------------------------------------------------------------------

=item public void installMasonFiles();

Installs the Mason files for this pipeline.

=cut 
#------------------------------------------------------------------------
sub installMasonFiles {

  my $self = shift;

  # determine mason plugin directory
  my $mas_dir = join( '/', '___package_masoncomp___', 'plugin', $self->getClassPath  );

  File::Copy::Recursive::dircopy( $self->getMasonSourcePath,  $mas_dir ) or die $!;  
}

#------------------------------------------------------------------------

=item public void installIncludeFiles();

Installs the Ergatis .config templates and YAML form definitions for
components.

=cut 
#------------------------------------------------------------------------
sub installIncludeFiles {

  my $self = shift;

  # use Ergatis install directive
  my $include_dir = join( '/', '___package_include___', $self->getErgatisInstall->getName() );

  # build the install directory if it doesn't exist
  File::Path::mkpath($include_dir);

  #
  # TODO : this needs to diff files and only overwrite if force is set 
  #
  # grab all of our .config and .yaml files and copy them
  File::Find::find( sub { return if -d $_; 
			  return unless /\.(config|yaml|protocol)$/;
			  copy( $File::Find::name, $include_dir ); },
		    $self->getIncludeSourcePath() );
  
}

1;

