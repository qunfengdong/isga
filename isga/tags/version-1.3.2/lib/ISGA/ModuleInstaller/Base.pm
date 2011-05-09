package ISGA::ModuleInstaller::Base;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::Base> provides common methods for installing
pipelines.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use YAML;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void load(ModuleInstaller $mi);

Read in definition file and load entries into database.

=cut 
#------------------------------------------------------------------------
sub load {
    
  my ($class, $ml) = @_;
  
  my $obj_class = $class;
  $obj_class =~ s{ModuleInstaller\:\:}{};

  # read in yaml file
  my $filename = join('/', $ml->getDatabaseSourcePath(), $class->getYAMLFile());
  $ml->log("Loading $filename");
  my $file = YAML::LoadFile($filename);
  
  # test each entry
  foreach ( @$file ) {
    
    # check for a subclass
    if ( exists $_->{SubClass} ) {
      eval "require $obj_class\:\:$_->{SubClass}";
    }

    # attempt to retrieve this item from the database by key
    my @results = @{$obj_class->query(%{$class->extractKey($ml, $_)})};
    
    # if there is no result we just insert it
    if ( @results == 0 ) {
      $class->insert($ml, $_);
      $ml->log("Inserted $obj_class Object");
      
    } elsif ( @results == 1 and $ml->isForced ) {
      $class->update($ml, $results[0], $_);

    } elsif ( @results == 1 ) {
      $class->checkEquality( $ml, $results[0], $_ );
      $ml->log("Ignoring $obj_class Object that exists in database");

      # if there are more than one result, something is very wrong
    } else {
      X::API->throw( message => "Invalid key for XXX returned multiple objects" );
    }    
  }  
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
