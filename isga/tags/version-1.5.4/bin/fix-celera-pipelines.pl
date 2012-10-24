#! /usr/bin/perl

use lib '/data/web/isga.cgb/docs/lib/perl5';

use strict;
use warnings;

#
#
# This is a utility script to fix the duplicate ASM output of Celera pipelines.
#
#

use ISGA;

# pass run as first argument

foreach my $run ( @{ISGA::Run->query(Status => ISGA::RunStatus->new('Complete'))} ) {

  foreach my $ro ( @{ISGA::RunOutput->query( Run => $run)} ) {
    
    next unless $ro->getClusterOutput->getType->getName eq 'Celera Assembler Output';
    
    if ( my $file = $ro->getFileResource ) {
      
      next if $file->isa('ISGA::File');
      next if $file->getArchive;
      
      # don't try to archive empty lists
      next unless ISGA::FileCollectionContent->exists( FileCollection => $file );
      
      # set login
      my $account = $run->getCreatedBy;    
      ISGA::Login->switchAccount( $account );
            
      warn "we founded one! - $run - $file \n";

      my @contents = map { $_->getFileResource } @{ISGA::FileCollectionContent->query( FileCollection => $file )};

      if ( ( @contents != 2 ) or ( $contents[0] != $contents[1] ) ) {
	warn "this this has " . scalar(@contents) . " files in it. If that is two they aren't equal.\n";
	next;
      }
		       
      warn "for run $run, we are removing file_collection $file and replacing it with file $contents[0]\n";

      # take the first
      my $target = ISGA::FileCollectionContent->new( FileCollection => $run->getFileCollection, FileResource => $file );
      $ro->edit( FileResource => $contents[0] );
      $target->edit( FileResource => $contents[0] );

      # remove the old collection
      $file->delete();
    }
  }
}
