package ISGA::RunAnalysis;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::RunAnalysis> provides convenience methods for
interacting with the end of Run analysis which make up
the RunAnalysis object.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;
use YAML;
use Kwalify qw(validate);

#========================================================================

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public ISGA::RunAnalysis new(Run $run);

Initialize the RunAnalysis object corresponding to the supplied
Run. If the Run does not have a builder .yaml file, undef
is returned.

=item public ISGA::RunAnalysis new(Run $run);

Initialize the RunAnalysis object corresponding to the supplied 
Run.

=cut
#------------------------------------------------------------------------
sub new {

  my ($class, $run) = @_;

  my $schema = YAML::LoadFile('___package_include___/schema/run_analysis_kwalify.yaml');
  my $collection = $run->getFileCollection;
  my $contents = $collection->getContents;
  my $analysis;
  foreach (@$contents){
      if ($_->getType->getName eq 'Run Analysis'){
           $analysis = $_->getPath;
           last;
      }
  }

  my $self = YAML::LoadFile($analysis);
  validate( $schema, $self );

  # first we initialize the ComponentTemplate loaded from the YAML
#  $self->_initialize();

  return $self;    
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
