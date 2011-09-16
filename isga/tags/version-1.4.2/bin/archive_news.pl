#! /usr/bin/perl

use strict;
use warnings;

use ISGA;
use File::Pid;


use HTML::Mason;

my $now = ISGA::Timestamp->new();
my $today = $now->getDate();
my $pidfile = File::Pid->new();

my $out_buffer;

my $interp = HTML::Mason::Interp->new( comp_root  => ISGA::Site->getMasonComponentRoot(),
				       out_method => \$out_buffer );

if ( my $num = $pidfile->running ) {
    ISGA::Log->alert( "send_notifications.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
}

$pidfile->write();

for my $news ( @{ISGA::News->query( IsArchived => 0 )} ) {

  # skip news items that don't expire or expire in the future
  my $expireson = $news->getArchiveOn or next();
  $expireson < $today or next();
  
  eval {    
    
    ISGA::DB->begin_work();

    $news->edit( IsArchived => 1 );

    # delete notification request
    ISGA::DB->commit();
  };

  if ( $@ ) {
    ISGA::DB->rollback();
    X::Dropped->throw( error => $@);
  }
}

# remove the pid file when we finish
$pidfile->remove;  
