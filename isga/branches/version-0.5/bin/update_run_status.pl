
use strict;
use warnings;


use lib '/data/web/sysmicro.cgb/docs/lib';

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
    SysMicro::Log->alert( "update_run_status.pl $$ started at $now and found duplicate script running: $num\n" );
    exit(0);
}

$pidfile->write();


# grab all runs that aren't complete or canceled
my @statuses = map { SysMicro::RunStatus->new( Name => $_ ) } 
  qw( Error Failed Held Running Submitting Incomplete Interrupted );

foreach my $run ( @{SysMicro::Run->query( Status => \@statuses )} ) {

  eval {

    my $account = $run->getCreatedBy;
    
    # set login
    SysMicro::Login->switchAccount( $account );
    
    # update the status
    $run->updateStatus();

    # send mail if run is complete
    if ( $run->getStatus eq 'Complete' ) {

      my $rname = $run->getName;

      my %mail =
	( To => $account->getEmail,
	  From => 'SysMicro System <biohelp@cgb.indiana.edu>',
	  Subject => 'Your SysMicro Run has finished',
          Message => 

"SysMicro Run $rname has completed. You can view your results at:

$base_uri/Run/View?run=$run

" );
#http://sysmicro-dev.cgb.indiana.edu/Run/View?run=$run

    Mail::Sendmail::sendmail(%mail) 
	or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );    

    }
    
  };

  if ( $@ ) {
    SysMicro::Log->alert("Failed to update run $run because: $@");
  }

}

# logging and such
$pidfile->remove;

my $now2 = SysMicro::Timestamp->new();


SysMicro::Log->warning( "update_run_status.pl $$ started at $now and finished at $now2\n" );
