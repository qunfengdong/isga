#! /usr/bin/perl

use strict;
use warnings;

use ISGA;

my $file_collection = ISGA::FileCollection->new( Id => $ARGV[0] );

eval { 

  ISGA::DB->begin_work();

  # set login
  my $account = $file_collection->getCreatedBy;    
  ISGA::Login->switchAccount( $account );

  $file_collection->inflate();

  ISGA::DB->commit();
};


  # if things failed
  if ( $@ ) {
    ISGA::DB->rollback();
    
    my $e = $@;    
    # clean up
    
    X::Dropped->throw( error => $e);
  }
