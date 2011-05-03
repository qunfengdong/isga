package ISGA::Run::ProkaryoticAnnotation::Jan2010;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::Run::ProkaryoticAnnotation::Jan2010> manages runs of the prokaryotic annotation pipeline.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=over

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use base 'ISGA::Run::ProkaryoticAnnotation';

{
  my $component = ISGA::Component->new( ErgatisInstall => ISGA::ErgatisInstall->new( Name => 'ergatis-v2r11-cgbr1' ),
					ErgatisName => 'bsml2gff3.default' );

  my $gff_output = 
    ISGA::ClusterOutput->new( FileLocation => 'bsml2gff3/___id____default/bsml2gff3.gff3.list', Component => $component);

#------------------------------------------------------------------------

=item public ClusterOutput getClusterOutput()

Returns the clusteroutput in which GFF data is contained for this
pipeline.

=cut
#------------------------------------------------------------------------
sub getClusterOutput { return $gff_output; }

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

  
