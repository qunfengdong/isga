package ISGA::RunBuilder::ProkaryoticAnnotation;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::RunBuilderProkaryoticAnnotation provides pipeline-specific
functionality for prokaryotic annotation pipelines.

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
  if ( $ci->getName eq 'Genome_Contigs' ) {

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

#------------------------------------------------------------------------

=item public void verifyUpload( string $name, PipelineInput $pi);

This method generates a verification callback to be used on uploaded files.

=cut 
#------------------------------------------------------------------------
sub verifyUpload {

  my ($self, $name, $pi) = @_;

  return sub {

    my $fh = shift;

    my $ci = $pi->getClusterInput->getName;

    # we know how to verify fasta file inputs
    if ( $ci eq 'Genome_Contigs' ) {
      ISGA::FileFormat::FASTA->verify( $fh, UserName => $name, Alphabet => 'nucleotide' );
    }

    # this filter doesn't modify the fh
    seek($fh,0,0);
    return $fh;
  }
}
1;
