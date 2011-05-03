package ISGA::ModuleInstaller::PipelineInput;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::PipelineInput> provides methods for
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
sub getYAMLFile { return 'pipelineinput.yaml'; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $t) = @_;
  
  my $ei = $ml->getErgatisInstall();

  return { Pipeline => ISGA::GlobalPipeline->new( Name => $t->{Pipeline}, ErgatisInstall => $ei),
	   ClusterInput => ISGA::ClusterInput->new( Name => $t->{ClusterInput}, 
						    ErgatisInstall => $ei) };
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
	      Pipeline => ISGA::GlobalPipeline->new( Name => $t->{Pipeline}, ErgatisInstall => $ei),
	      ClusterInput => ISGA::ClusterInput->new( Name => $t->{ClusterInput}, ErgatisInstall => $ei),
	     );

  ISGA::PipelineInput->create(%args);
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, Pipeline $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update { }

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, Pipeline $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied Pipeline object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {}

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
