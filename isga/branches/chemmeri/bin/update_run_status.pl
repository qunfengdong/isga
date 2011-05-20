#! /usr/bin/perl

use strict;
use warnings;

use ISGA;

use File::Pid;
use Getopt::Long;
my $runid;
GetOptions(
        "input:s"               => \$runid,           ## input run id
) || die "\n";

my $now = ISGA::Timestamp->new();

my $pidfile = File::Pid->new() if not defined $runid;

my $base_uri = ISGA::Site->getBaseURI;

my $support_email = ISGA::SiteConfiguration->value('support_email');

if (not defined $runid and my $num = $pidfile->running ) {
    ISGA::Log->warning( "update_run_status.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
}

$pidfile->write() if not defined $runid;


# grab all runs that aren't complete or canceled
my @statuses = map { ISGA::RunStatus->new( Name => $_ ) } 
  qw( Error Failed Held Running Submitting Incomplete Interrupted );

my @runs = defined $runid ? @{ISGA::Run->query( Id => $runid )} : @{ISGA::Run->query( Status => \@statuses )};

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
	  From => "ISGA <$support_email>",
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
        my $ergatis_uri = $run->getErgatisURI;

	# set email lest
	my $email = join (",", @{ISGA::Site->getErrorNotificationEmail});

	my $server = ISGA::Site->getServerName();

	my %mail =
	  ( To => $email,
	    From => $server . " <$support_email>",
	  Subject => $server. ' Ergatis Run Failure',
          Message => "Ergatis Run $id has failed.
Link: $ergatis_uri
" );
	
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
$pidfile->remove if not defined $runid;

my $now2 = ISGA::Timestamp->new();
