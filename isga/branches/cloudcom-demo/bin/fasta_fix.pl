#! /usr/bin/perl

use strict;
use warnings;

use ISGA;


my $template = ISGA::GlobalPipeline->new( Name => 'Prokaryotic Annotation Pipeline' );

my $asn = ISGA::ClusterOutput->new( FileLocation => 'tbl2asn/___id____default/tbl2asn.gbf.list' );
my $fna = ISGA::ClusterOutput->new( FileLocation => 'asn2all/___id____default/asn2all.fna.list' );
my $fsa = ISGA::ClusterOutput->new( FileLocation => 'asn2all/___id____default/asn2all.fsa.list' );

my $contigs = ISGA::ClusterInput->new( Name => 'Genome_Contigs' );

# cycle through all 
my $runs = ISGA::Run->query( Status => ISGA::RunStatus->new(Name => 'Complete') );

foreach my $run ( @$runs ) {

  next unless $run->getGlobalPipeline() == $template;

  # check to see if they have the runoutput already
  next if ISGA::RunOutput->exists( Run => $run, ClusterOutput => $fna );

  # retrieve the contigs in the input
  my @contigs = @{getContigList($run)};

  my $ekey = $run->getErgatisKey();

  my $list = "/research/projects/isga/dev/project/output_repository/tbl2asn/$ekey\_default/tbl2asn.asn.list";

#  -f $list or die "guess we didn't get the path right; $list\n";
  -f $list or next;
  open my $fh, '<', $list;
  

  # retrieve the asn files
#  my $asn_out = ISGA::RunOutput->new( Run => $run, ClusterOutput => $asn );

  # no we need to glue them together by contig
#  my @input_files;

#  my $fr = $asn_out->getFileResource();

#  push @input_files, ( $fr->isa('ISGA::File') ? $fr : @{$fr->getFlattenedContents} );

  my $i = 0;

  foreach my $asn_file ( <$fh> ) {

    chomp $asn_file;
    
    # run asn2all
    my $asn = '/nfs/bio/sw/bin/asn2all';
    
    my $out_fna = "/tmp/cds-$run-$i.fna";
    
    my $out_fsa = "/tmp/aa-$run-$i.fsa";
    
#    `$asn -i $input -f d -o $out_fna -v $out_fsa`;
 
    print "$asn -i $asn_file -f d -o $out_fna -v $out_fsa\n";

    $i++;
  }

  # add out put to repository
  
  # add runoutput

}

    


sub getContigList {

  my ($run) = @_;

  # retrieve the fasta files
  my $pi = ISGA::PipelineInput->new( Pipeline => $run->getType, ClusterInput => $contigs );
  my $input = ISGA::RunInput->new( Run => $run, PipelineInput => $pi );

  my @contigs;

  foreach ( @{$input->getFileResource->getFlattenedContents} ) {

    my $fh = $_->getFileHandle();
    push @contigs, grep { /^>(\S+)/; $_ = $1 } <$fh>;
  }


  return \@contigs;
}
