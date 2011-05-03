#! /usr/bin/perl

use strict;
use warnings;

use ISGA;
use File::Basename;

# runs we've seen
my %files;
my %contigs;

foreach my $file ( @ARGV ) {
    
  my ($id, $ext) = ( $file =~ /[a-z]+\-(\d+)\-\d+\.(fna|fsa)/ );
  
  if ( $ext eq 'fna' ) {
    exists $contigs{$id} ? $contigs{$id}++ : ($contigs{$id} = 1);
  }
  
  if ( $files{$id}{$ext} ) {      
    push @{$files{$id}{$ext}}, $file;
  } else {
    $files{$id}{$ext} = [ $file ];
  }
}

my $fna = ISGA::ClusterOutput->new( FileLocation => 'asn2all/___id____default/asn2all.fna.list' );
my $fsa = ISGA::ClusterOutput->new( FileLocation => 'asn2all/___id____default/asn2all.fsa.list' );

print "beginning work\n";

eval {

  ISGA::DB->begin_work();
  
  while ( my ($id, $map) = each %files ) {
    
    my $run = ISGA::Run->new( Id => $id );
    my $run_name = $run->getName();
    my $account = $run->getCreatedBy();
    my $now = ISGA::Timestamp->new();
    
    # do we need collections
    my $in_coll = $contigs{$run} > 1;
    
    # take care of fna
    my $fna_collection;
  
    if ( $in_coll ) {
  
      my $username = $run_name . " " . $fna->getType->getName;
      
      $fna_collection =  ISGA::FileCollection->create
	( Type => ISGA::FileCollectionType->new('File List'),
	  CreatedAt => $now,
	  CreatedBy => $account,
	  Description => "Output from $run_name",
	  IsHidden => 0,
	  ExistsOutsideCollection => 0,
	  UserName => $username
	);    
      
      $run->getFileCollection->addContents($fna_collection);
      
    } else { $fna_collection = $run->getFileCollection() }
    
    my @fna_files = ();
    
    my %fna_args = ( Type => $fna->getType, Format => $fna->getFormat, IsHidden => 0,
		     CreatedAt => $now, CreatedBy => $account, ExistsOutsideCollection => 0,
		     Description => "Output from $run_name" );
    
    foreach ( @{$map->{fna}} ) {
      
      open my $fh, '<', $_ or X::File->throw( error => "Cant open $_ - $!" );
      
      $fna_args{UserName} = basename($_);
      
      my $file = ISGA::File->upload( $fh, %fna_args );
      push @fna_files, $file;
    }
    
    $fna_collection->addContents(\@fna_files);
    
    my $fna_resource = $in_coll ? $fna_collection : $fna_files[0] ;
    
    ISGA::RunOutput->create( Run => $run, ClusterOutput => $fna, FileResource => $fna_resource );
    
    # take care of fsa
    my $fsa_collection;
    
    if ( $in_coll ) {
      
      my $username = $run_name . " " . $fsa->getType->getName;
      
      $fsa_collection =  ISGA::FileCollection->create
	( Type => ISGA::FileCollectionType->new('File List'),
	  CreatedAt => $now,
	  CreatedBy => $account,
	  Description => "Output from $run_name",
	  IsHidden => 0,
	  ExistsOutsideCollection => 0,
	  UserName => $username
	);    
      
      $run->getFileCollection->addContents($fsa_collection);
      
    } else { $fsa_collection = $run->getFileCollection() }
    
    my @fsa_files = ();
    
    my %fsa_args = ( Type => $fsa->getType, Format => $fsa->getFormat, IsHidden => 0,
		     CreatedAt => $now, CreatedBy => $account, ExistsOutsideCollection => 0,
		     Description => "Output from $run_name" );

    foreach ( @{$map->{fsa}} ) {
      
      open my $fh, '<', $_ or X::File->throw( error => "Cant open $_ - $!" );
      
      $fsa_args{UserName} = basename($_);
      
      my $file = ISGA::File->upload( $fh, %fsa_args );
      push @fsa_files, $file;
    }
    
    $fsa_collection->addContents(\@fsa_files);
    
    my $fsa_resource = $in_coll ? $fsa_collection : $fsa_files[0] ;
    
    ISGA::RunOutput->create( Run => $run, ClusterOutput => $fsa, FileResource => $fsa_resource );
    
  }

  # delete notification request
  ISGA::DB->commit();
};
  
if ( $@ ) {
  
  print "didn't work\n";
  warn $@;  
  ISGA::DB->rollback();
  
}
