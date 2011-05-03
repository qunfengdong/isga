#! /usr/bin/perl

use strict;
use warnings;

use ISGA;
use ISGA::X;
use ISGA::Site;

use HTML::Mason;

my $now = ISGA::Timestamp->new();
my $pidfile = File::Pid->new();

my $out_buffer;

my $interp = HTML::Mason::Interp->new( comp_root  => ISGA::Site->getMasonComponentRoot(),
				       out_method => \$out_buffer );

if ( my $num = $pidfile->running ) {
    ISGA::Log->alert( "send_notifications.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
}

$pidfile->write();


for my $notification ( @{ISGA::Notification->query()} ) {
  
  $out_buffer = '';

  eval {
    
    ISGA::DB->begin_work();

    # get message
    my $comp = $notification->getType->getTemplate();

    $interp->exec("/mail/$comp", notification => $notification);

    my %mail = ( To => $notification->getEmail,
		 From => ISGA::Site->getMailSender,
		 Subject => $notification->getType->getSubject,
		 Message => $out_buffer);

    # send email
    Mail::Sendmail::sendmail(%mail) 
	or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );

    # delete notification
    $notification->delete();

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
