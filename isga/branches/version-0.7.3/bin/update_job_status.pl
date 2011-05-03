#! /usr/bin/perl
use strict;
use warnings;

use SysMicro;
use SysMicro::X;
use SysMicro::Login;
use SysMicro::Log;
use SysMicro::Site;
use File::Pid;

my $now = SysMicro::Timestamp->new();

my $pidfile = File::Pid->new();

my $base_uri = SysMicro::Site->getBaseURI;

if ( my $num = $pidfile->running ) {
    SysMicro::Log->alert( "update_job_status.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
}

$pidfile->write();


# grab all jobs that aren't Finished 
my @statuses = ( 'Running', 'Pending' );

foreach my $job ( @{SysMicro::Job->query( Status => \@statuses )} ) {

  eval {

    my $account = $job->getCreatedBy;
    
    # set login
    SysMicro::Login->switchAccount( $account );

    my $old_status = $job->getStatus();
    
    # update the status
    $job->updateStatus();
    my $status = $job->getStatus();

    # send mail if job is complete
    if ( $status eq 'Finished' ) {

      my $jobtype = $job->getType->getName;

      my %mail =
	( To => $account->getEmail,
	  From => 'ISGA <biohelp@cgb.indiana.edu>',
	  Subject => 'Your ISGA Toolbox job has finished',
          Message => 

"Your Sysmicro WorkBench $jobtype  has completed. You can view your results at:

${base_uri}WorkBench/Results/Blast?job=$job

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
          From => 'ISGA <biohelp@cgb.indiana.edu>',
          Subject => 'Your ISGA Toolbox job has failed',
          Message => "Your Sysmicro WorkBench $jobtype  has failed.  Please email biohelp\@cgb.indiana.edu with any questions you may have." 
        );
    if ($job->notifyUser){
      Mail::Sendmail::sendmail(%mail) 
        or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );    
    }


    }
    
  };

  if ( $@ ) {
    SysMicro::Log->alert("Failed to update job $job because: $@");
  }


}

# logging and such
$pidfile->remove;

my $now2 = SysMicro::Timestamp->new();


SysMicro::Log->warning( "update_job_status.pl $$ started at $now and finished at $now2\n" );
