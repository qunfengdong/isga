#! /usr/bin/perl

use strict;
use warnings;

use ISGA;

use File::Pid;

my $now = ISGA::Timestamp->new();

my $pidfile = File::Pid->new();

my $base_uri = ISGA::Site->getBaseURI;

if ( my $num = $pidfile->running ) {
    ISGA::Log->alert( "update_run_status.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
}

$pidfile->write();


# grab all runs that aren't complete or canceled
my @statuses = map { ISGA::RunStatus->new( Name => $_ ) } 
  qw( Error Failed Held Running Submitting Incomplete Interrupted );

foreach my $run ( @{ISGA::Run->query( Status => \@statuses )} ) {

  eval {

    my $account = $run->getCreatedBy;
    
    # set login
    ISGA::Login->switchAccount( $account );

    my $old_status = $run->getStatus();
    
    # update the status
    $run->updateStatus();
    my $status = $run->getStatus();

    # send mail if run is complete
    if ( $status eq 'Complete' ) {

      my $rname = $run->getName;

      my %mail =
	( To => $account->getEmail,
	  From => 'ISGA <biohelp@cgb.indiana.edu>',
	  Subject => 'Your ISGA pipeline has finished',
          Message => 

"ISGA pipeline submission $rname has completed. You can view your results at:

${base_uri}Run/View?run=$run

" );
      
      Mail::Sendmail::sendmail(%mail) 
	  or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );    

    
    # send email for new error or fail
    } elsif ( $status eq 'Error' or $status eq 'Failed' ) {

      if ( $old_status ne 'Error' and $old_status ne 'Failed' ) {
	
	my $id = $run->getErgatisKey;

	# set email lest
	my $email = join (",", @{ISGA::Site->getErrorNotificationEmail});

	my $server = ISGA::Site->getServerName();

	my %mail =
	  ( To => $email,
	    From => $server . ' <biohelp@cgb.indiana.edu>',
	  Subject => $server. ' Ergatis Run Failure',
          Message => "Ergatis Run $id has failed."
	  );
	
       Mail::Sendmail::sendmail(%mail) 
	or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail ); 

      }
    }
    
  };

  if ( $@ ) {
    ISGA::Log->alert("Failed to update run $run because: $@");
  }

}

# logging and such
$pidfile->remove;

my $now2 = ISGA::Timestamp->new();


ISGA::Log->warning( "update_run_status.pl $$ started at $now and finished at $now2\n" );
