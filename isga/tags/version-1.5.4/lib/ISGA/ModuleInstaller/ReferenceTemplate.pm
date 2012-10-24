package ISGA::ModuleInstaller::ReferenceTemplate;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::Component> provides methods for
installing reference template information for a pipeline.

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
sub getYAMLFile { return "referencetemplate.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $tuple) = @_;
  
  my %keys = ( Reference => ISGA::Reference->new( Name => $tuple->{Reference}), Format => $tuple->{Format});
  $keys{Label} = exists $tuple->{Label} ? $tuple->{Label} : undef;

  return \%keys;
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
  my %args = ( Format => $t->{Format}, Reference => ISGA::Reference->new( Name => $t->{Reference} ) );
  exists $t->{Label} and $args{Label} = $t->{Label};

  ISGA::ReferenceTemplate->create(%args);
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, Component $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {
  # since we're keyed on all fields, there is no update.
}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, Component $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied Component object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  # since we're keyed on all fields, they are equal
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
