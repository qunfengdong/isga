package ISGA::ModuleInstaller::FileFormat;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::FileFormat> provides methods for
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
sub getYAMLFile { return "fileformat.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $tuple) = @_;
  
  return { Name => $tuple->{Name} };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $tuple) = @_;
  
  # raw insert
  ISGA::DB->insert(Table => 'fileformat', 
		   Fields => { fileformat_name => $tuple->{Name},
			       fileformat_extension => $tuple->{Extension},
			       fileformat_help => $tuple->{Help},
			       fileformat_isbinary => $tuple->{IsBinary} });
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $obj, $tuple) = @_;
  
  # raw insert
  ISGA::DB->update(Table => 'fileformat', 
		   Fields => { fileformat_name => $tuple->{Name} },
		   Update => { fileformat_extension => $tuple->{Extension},
			       fileformat_help => $tuple->{Help},
			       fileformat_isbinary => $tuple->{IsBinary} });
}

#------------------------------------------------------------------------

=item public boolean checkEquality( ModuleLoader $ml, FileFormat $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied FileFormat object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $obj, $tuple) = @_;

  # we've already checked Name in the key search

  # check extension
  my $ext = $obj->getExtension();
  $ext ne $tuple->{Extension} and 
    $ml->("FileFormat extension for $tuple->{Name} differs from database entry - retaining old version.");

  # check help
  my $help = $obj->getHelp();
  $help ne $tuple->{Help} and 
    $ml->log("FileFormat help for $tuple->{Name} differs from database entry - retaining old version.");

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
