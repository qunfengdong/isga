#! /usr/bin/perl

use strict;
use warnings;

use ISGA;

# pass run as first argument
my $run = ISGA::Run->new( Id => $ARGV[0] );

return unless $run->getStatus eq 'Complete';

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
