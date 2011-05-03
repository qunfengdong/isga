package SysMicro::ClusterBuilder;

#------------------------------------------------------------------------

=head1 NAME

B<SysMicro::ClusterBuilder> manages loading YAML definitions for pipeline clusters, and providing FormEngine parameter arrays.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;
use YAML;
use Kwalify qw(validate);
use SysMicro::Cluster;

{

  # private variable for caching form objects
  my %forms;

#========================================================================

=back

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public SysMicro::ClusterBuilder new(Cluster $cluster);

Initialize the ClusterBuilder object corresponding to the supplied cluster.

=cut
#------------------------------------------------------------------------
  sub new { return $forms{ $_[1] }; }

#------------------------------------------------------------------------

=item Class Initialization

YAML files are loaded and cached at server startup.

=cut

#------------------------------------------------------------------------
  
  my $schema = YAML::LoadFile('___package_include___/schema/cluster_definition_kwalify.yaml');
  
  foreach ( @{SysMicro::Cluster->query()} ) {
    
    my $file = '___package_include___/cluster_definition/' . $_->getFormPath;
    
    if ( -f $file ) {
      my $self = YAML::LoadFile($file);
      validate( $schema, $self );
    }

    $forms{ "$_" } = $self;    
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
