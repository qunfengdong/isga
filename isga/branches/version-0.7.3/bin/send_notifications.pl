#! /usr/bin/perl

use strict;
use warnings;

use SysMicro;
use SysMicro::X;
use SysMicro::Site;

use HTML::Mason;

my $out_buffer;

my $interp = HTML::Mason::Interp->new( comp_root  => SysMicro::Site->getMasonComponentRoot(),
				       out_method => \$out_buffer );

for my $notification ( @{SysMicro::Notification->query()} ) {
  
  $out_buffer = '';

  eval {
    
    SysMicro::DB->begin_work();

    # get message
    my $comp = $notification->getType->getTemplate();

    $interp->exec("/mail/$comp", notification => $notification);

    my %mail = ( To => $notification->getEmail,
		 From => SysMicro::Site->getMailSender,
		 Subject => $notification->getType->getSubject,
		 Message => $out_buffer);

    # send email
    Mail::Sendmail::sendmail(%mail) 
	or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );

    # delete notification
    $notification->delete();

    # delete notification request
    SysMicro::DB->commit();
  };

  if ( $@ ) {
    SysMicro::DB->rollback();
    X::Dropped->throw( error => $@);
  }
}

  
