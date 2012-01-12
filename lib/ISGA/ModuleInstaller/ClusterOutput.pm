package ISGA::ModuleInstaller::ClusterOutput;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::ClusterOutput> provides methods for
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
sub getYAMLFile { return "clusteroutput.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $t );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $t) = @_;
  
  return { Component => ISGA::Component->new( ErgatisName => $t->{Component},
					      ErgatisInstall => $ml->getErgatisInstall ),
	   FileLocation => $t->{FileLocation} };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
  my $ei = $ml->getErgatisInstall();
  
  my %args = 
    ( Component => ISGA::Component->new( ErgatisName => $t->{Component},
					      ErgatisInstall => $ei ),
      Type => ISGA::FileType->new( Name => $t->{Type} ),
      Format => ISGA::FileFormat->new( Name => $t->{Format} ),
      ErgatisFormat => $t->{ErgatisFormat},
      Visibility => $t->{Visibility},
      FileLocation => $t->{FileLocation},
      BaseName => $t->{BaseName}
    );

  ISGA::ClusterOutput->create(%args);
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, ClusterOutput $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $o, $t) = @_;
  
  my $ei = $ml->getErgatisInstall();
  
  my %args = 
    ( Type => ISGA::FileType->new( Name => $t->{Type} ),
      Format => ISGA::FileFormat->new( Name => $t->{Format} ),
      ErgatisFormat => $t->{ErgatisFormat},
      Visibility => $t->{Visibility},
    );

  $o->edit(%args);
}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, ClusterOutput $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied ClusterOutput object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $o, $t) = @_;

  $o->getType->getName ne $t->{Type} and 
    X::API->throw( message => "Type does not match entry for ClusterOutput $t->{Name}\n" );

  $o->getFormat->getName ne $t->{Format} and 
    X::API->throw( message => "Format does not match entry for ClusterOutput $t->{Name}\n" );

  $o->getErgatisFormat ne $t->{ErgatisFormat} and 
    X::API->throw( message => "ErgatisFormat does not match entry for ClusterOutput $t->{Name}\n" );

  $o->getVisibility ne $t->{Visibility} and
    X::API->throw( message => "Visibility does not match entry for ClusterOutput $t->{Name}\n" );
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
