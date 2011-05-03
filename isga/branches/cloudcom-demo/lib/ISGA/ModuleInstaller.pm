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

use File::Copy;
use File::Path;
use File::Find;
use File::Copy::Recursive;


sub new {

  my ($class, %options) = @_;

  my $source_path = $options{source};

  my $self = YAML::LoadFile("$source_path/CONFIG.yaml");
  
  # set source path
  $self->{source_path} = $source_path;

  $self->{force_install} = ( exists $options{force_install} ?  1 : 0 );

  # retrieve Ergatis Install
  $self->{ergatis_install} = ISGA::ErgatisInstall->new( Name => $self->{ergatis_install} );
    
  return $self;
}


sub isForced { return shift->{force_install}; }

sub getErgatisInstall { return shift->{ergatis_install}; }
sub getSourcePath { return shift->{source_path}; }
sub getClassName { return shift->{pipeline_class}; }

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
  return join('/', $self->getSourcePath(), 'masoncomp', $self->getClassName );
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
  my $mas_dir = join( '/', '___package_masoncomp___', 'plugin', $self->getClassName  );

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
			  return unless /\.(config|yaml)$/;
			  copy( $File::Find::name, $include_dir ); },
		    $self->getIncludeSourcePath() );
  
}




1;

