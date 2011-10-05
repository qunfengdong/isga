#! /usr/bin/perl

use strict;
use warnings;

use ISGA;

my $file_collection = File::Collection->new( Id => $ARGV[0] );

eval { 

  ISGA::DB->begin_work();

  $file_collection->archive();
  $file_collection->deleteContents();

  ISGA::DB->commit();

};


  # if things failed
  if ( $@ ) {
    ISGA::DB->rollback();
    
    my $e = $@;    
    # clean up
    
    X::Dropped->throw( error => $e);
  }
