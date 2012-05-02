package ISGA::ModuleInstaller::ReferenceLabel;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::ReferenceLabel> provides methods for
installing reference label inlabelion for a pipeline.

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

=item public void load(ModuleInstaller $mi);

Read in definition file and load entries into database.

=cut 
#------------------------------------------------------------------------
sub load {
    
  my ($class, $ml) = @_;
  
  my $obj_class = $class;
  $obj_class =~ s{ModuleInstaller\:\:}{};

  # read in yaml file
  my $filename = join('/', $ml->getDatabaseSourcePath(), 'referencelabel.yaml');
  $ml->log("Loading $filename");
  -e $filename or return;
  my $file = YAML::LoadFile($filename);
  
  # test each entry
  foreach ( @$file ) {

    my $rows = ISGA::DB->select( Table => 'referencelabel',
				 Select => 'referencelabel_name',
				 Fields => { referencelabel_name => $_->{Name} });

    if ( @$rows == 0 ) {
      ISGA::DB->insert(Table => 'referencelabel', Fields => { referencelabel_name => $_->{Name} });
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
