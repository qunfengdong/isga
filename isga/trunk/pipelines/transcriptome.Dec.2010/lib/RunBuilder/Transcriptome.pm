package ISGA::RunBuilder::Transcriptome;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::RunBuilderTranscriptome provides pipeline-specific
functionality for Transcriptome annotation pipelines.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use warnings;
use strict;

use base 'ISGA::RunBuilder';

#========================================================================

=head2 METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void verifyInputs(RunBuilderInput $rbi);

This method verifies the selected input files.

=cut 
#------------------------------------------------------------------------
sub verifyInputs {

  my ($self, $rbi) = @_;

  my $ci = $rbi->getPipelineInput->getClusterInput;

  my $fr = $rbi->getFileResource;

  my $files = $fr->isa('ISGA::File') ? [ $fr ] : $fr->getFlattenedContents;

  # we know how to verify fasta file inputs
  if ( $ci->getName eq 'EST_Input' ) {

    my %data = ( seq_count => 0, base_count => 0 );

    for my $file ( @$files ) {

      # die if we don't get a FASTA file as expected
      $file->getFormat eq 'FASTA' or 
	X::API->throw( error => 'Expected FASTA file type for run input' );

      my $tmp = ISGA::FileFormat::FASTA->verify( $file, Alphabet => 'nucleotide' );

      # increment our totals
      $data{$_} += $tmp->{$_} for keys %data;
    }

    # if we have limits set for the user, this is where we can look at size and sequence count
  }
}
1;
