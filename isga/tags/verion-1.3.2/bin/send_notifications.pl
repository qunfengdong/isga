#! /usr/bin/perl

use strict;
use warnings;

use ISGA;
use File::Pid;


use HTML::Mason;


eval { 

  my $now = ISGA::Timestamp->new();
  my $pidfile = File::Pid->new();
  
  my $out_buffer;
  
  my $interp = HTML::Mason::Interp->new( comp_root  => ISGA::Site->getMasonComponentRoot(),
					 out_method => \$out_buffer );
  
  if ( my $num = $pidfile->running ) {
    ISGA::Log->warn( "send_notifications.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
  }
  
  $pidfile->write();
  
  
  for my $notification ( @{ISGA::Notification->query()} ) {
    
    $out_buffer = '';
    
    # hacky way to check if we are sending mail for SGE service
    next if ($notification->getType->getName eq 'Service Outage Restored' and not ISGA::SiteConfiguration->value('allow_sge_requests'));
    
    
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
  

};

if ( $@ ) {

  my $e = ( X->caught() ? $@ : X::Dropped->new(error => $@) ); 

  warn "hey! it died!";
  
  # build message
  my $message  .= "Message: " . $e->full_message . "\n";
  $message .= $e->trace . "\n\n";

  ISGA::Log->alert($message);
}
