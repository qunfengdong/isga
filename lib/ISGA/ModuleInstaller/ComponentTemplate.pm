package ISGA::ModuleInstaller::ComponentTemplate;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::ComponentTemplate> provides methods for
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
sub getYAMLFile { return "componenttemplate.yaml"; }

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

  my ($class, $ml, $tuple) = @_;
  
  ISGA::ComponentTemplate->create( Name => $tuple->{Name}, 
				   ErgatisInstall => $ml->getErgatisInstall );
}

#------------------------------------------------------------------------

=item public void update( ModuleLoader $ml, ComponentTemplate $obj, HashRef $tuple );

Updates the supplied tuple into the database. This object contains no values outside of the key.

=cut 
#------------------------------------------------------------------------
sub update { }

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, ComponentTemplate $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied ComponentTemplate object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $obj, $tuple) = @_;

  $obj->getName ne $tuple->{Name} and X::API->throw( message => "$tuple->{Name} does not equal " . $obj->getName . " for ComponentTemplate $tuple->{Name}" );
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
