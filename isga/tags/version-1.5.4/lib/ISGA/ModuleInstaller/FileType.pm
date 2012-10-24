package ISGA::ModuleInstaller::FileType;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::FileType> provides methods for
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
sub getYAMLFile { return "filetype.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $t );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $t) = @_;
  
  return { Name => $t->{Name} };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $t );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
  # raw insert
  my $id = ISGA::DB->insert(Table => 'filetype', 
			    Sequence => 'filetype_filetype_id_seq',
			    Fields => { filetype_name => $t->{Name},
					filetype_help => $t->{Help} } );
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $t );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $obj, $t) = @_;
  
  # raw insert		    
  ISGA::DB->update(Table => 'filetype', 
		   Fields => { filetype_name => $t->{Name} },
		   Update => { filetype_help => $t->{Help} },
		  );
}

#------------------------------------------------------------------------

=item public boolean checkEquality( ModuleLoader $ml, FileType $ct, HashRef $t );

Returns true if the supplied tuple matches the supplied FileType object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $obj, $t) = @_;

  # we've already checked Name in the key search

  # check help
  my $help = $obj->getHelp();
  $help ne $t->{Help} and X::API->throw(message => "$t->{Help} differs from $help for FileType $t->{Name}");

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
