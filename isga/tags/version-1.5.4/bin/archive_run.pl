#! /usr/bin/perl

use strict;
use warnings;

#
# This is a utlity to script to help with the migration to 1.5, after which all runs are archived on completion.
# This will save inodes and rows in the file table at the potential cost of some hard disk space.
#

use ISGA;

# pass run as first argument
my $run = ISGA::Run->new( Id => $ARGV[0] );

exit unless $run->getStatus eq 'Complete';

# set login
my $account = $run->getCreatedBy;    
ISGA::Login->switchAccount( $account );

foreach ( @{ISGA::RunOutput->query( Run => $run)} ) {
  
  next unless $_->getClusterOutput->getVisibility eq 'Pipeline';

  if ( my $file = $_->getFileResource ) {

    next if $file->isa('ISGA::File');
    next if $file->getArchive;

    # don't try to archive empty lists
    next unless ISGA::FileCollectionContent->exists( FileCollection => $file );
    $file->archive();
  }
}
