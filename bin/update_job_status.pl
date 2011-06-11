#! /usr/bin/perl
use strict;
use warnings;

use ISGA;
use File::Pid;

my $now = ISGA::Timestamp->new();

my $pidfile = File::Pid->new();

my $base_uri = ISGA::Site->getBaseURI;

my $support_email = ISGA::SiteConfiguration->value('support_email');

if ( my $num = $pidfile->running ) {
    ISGA::Log->alert( "update_job_status.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
}

$pidfile->write();


# grab all jobs that aren't Finished 
my @statuses = ( 'Staging', 'Running', 'Pending' );

foreach my $job ( @{ISGA::Job->query( Status => \@statuses )} ) {

  eval {

    my $account = $job->getCreatedBy;
    
    # set login
    ISGA::Login->switchAccount( $account );

    my $old_status = $job->getStatus();

    $job->submitJob if $old_status eq 'Staging'; 

    # update the status
    $job->updateStatus();
    my $status = $job->getStatus();

    # send mail if job is complete
    if ( $status eq 'Finished' ) {

      my $jobtype = $job->getType->getName;
      my $page = "/WorkBench/Result?job=$job";

      my %mail =
	( To => $account->getEmail,
	  From => "ISGA <$support_email>",
	  Subject => 'Your ISGA Toolbox job has finished',
          Message => 

"Your ISGA WorkBench $jobtype  has completed. You can view your results at:

${base_uri}${page}

" );
    if ($job->notifyUser){
      Mail::Sendmail::sendmail(%mail) 
	or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );    
    }
    
    # send email for new error or fail
    } elsif ( $status eq 'Error' or $status eq 'Failed' ) {
      my $jobtype = $job->getType->getName;

      my %mail =
        ( To => $account->getEmail,
          From => "ISGA <$support_email>",
          Subject => 'Your ISGA Toolbox job has failed',
          Message => "Your ISGA WorkBench $jobtype  has failed.  Please email $support_email with any questions you may have." 
        );
    if ($job->notifyUser){
      Mail::Sendmail::sendmail(%mail) 
        or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );    
    }


    }
    
  };

  if ( $@ ) {
    ISGA::Log->alert("Failed to update job $job because: $@");
  }


}

# logging and such
$pidfile->remove;

my $now2 = ISGA::Timestamp->new();


ISGA::Log->warning( "update_job_status.pl $$ started at $now and finished at $now2\n" );
