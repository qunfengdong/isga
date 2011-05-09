package ISGA::ModuleInstaller::ClusterInput;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::ClusterInput> provides methods for
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
sub getYAMLFile { return "clusterinput.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $tuple) = @_;
  
  return { Name => $tuple->{Name}, ErgatisInstall => $ml->getErgatisInstall() };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
   my %args = ( Name => $t->{Name}, 
		DefaultValue => $t->{DefaultValue},
		Dependency => $t->{Dependency},
		Type => ISGA::FileType->new( Name => $t->{Type} ),
		Format => ISGA::FileFormat->new( Name => $t->{Format} ),
		ErgatisFormat => $t->{ErgatisFormat},
		HasParameters => $t->{HasParameters},
		ErgatisInstall => $ml->getErgatisInstall,
		IsIterator => $t->{IsIterator} );

  exists $t->{SubClass} and $args{SubClass} =  $t->{SubClass};

  ISGA::ClusterInput->create( %args );
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, ClusterInput $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $o, $t) = @_;
  
  my %args = ( DefaultValue => $t->{DefaultValue},
	       Dependency => $t->{Dependency},
	       Type => ISGA::FileType->new( Name => $t->{Type} ),
	       Format => ISGA::FileFormat->new( Name => $t->{Format} ),
	       ErgatisFormat => $t->{ErgatisFormat},
	       HasParameters => $t->{HasParameters},
	       IsIterator => $t->{IsIterator} );
  
  exists $t->{SubClass} and $args{SubClass} =  $t->{SubClass};

  $o->edit( %args );
}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, ClusterInput $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied ClusterInput object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $o, $t) = @_;

  $o->getName ne $t->{Name} and 
    X::API->throw( message => "Name does not match entry for ClusterInput $t->{Name}\n" );

  $o->getDefaultValue ne $t->{DefaultValue} and 
    X::API->throw( message => "DefaultValue does not match entry for ClusterInput $t->{Name}\n" );

  $o->getDependency ne $t->{Dependency} and 
    X::API->throw( message => "Dependency does not match entry for ClusterInput $t->{Name}\n" );

  $o->getFormat->getName ne $t->{Format} and 
    X::API->throw( message => "Format does not match entry for ClusterInput $t->{Name}\n" );

  $o->getType->getName ne $t->{Type} and 
    X::API->throw( message => "Type does not match entry for ClusterInput $t->{Name}\n" );

  $o->getErgatisFormat ne $t->{ErgatisFormat} and 
    X::API->throw( message => "ErgatisFormat does not match entry for ClusterInput $t->{Name}\n" );
  
  ($o->hasParameters xor $t->{HasParameters}) and 
    X::API->throw( message => "HasParameters does not match entry for ClusterInput $t->{Name}\n" );

  ($o->isIterator xor $t->{IsIterator}) and 
    X::API->throw( message => "IsIterator does not match entry for ClusterInput $t->{Name}\n" );

  my $SubClass = $o->getSubClass();
  ( defined $SubClass xor exists $t->{SubClass} ) and
    X::API->throw( message => "SubClass does not match entry for ClusterInput $t->{Name}\n" );   
  defined $SubClass and $SubClass ne $t->{SubClass} and
    X::API->throw( message => "SubClass does not match entry for ClusterInput $t->{Name}\n" );   

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
