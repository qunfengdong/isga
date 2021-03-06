#! /usr/bin/perl

=head1 NAME

script_runner.pl - script to start and monitor other scripts.

=head1 SYNOPSIS

USAGE: download_file_to_repository.pl --run_evidence_download=id
       [ --help
       ]

=head1 OPTIONS

B<--run_evidence_download>
    The run_evidence_download to process.

=head1 DESCRIPTION

This script starts and monitors long-running scripts that are not
appropriate for running within a cron script. This includes the following tasks:

 - Downloading user files from an external URL
 - Assembling a downloadable tar.gz file of run evidence output

=head1 INPUT

=head1 OUTPUT

=head1 CONTACT

=cut

use strict;
use warnings;

use ISGA;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

use POSIX;

my %options = ();
my $result = GetOptions (\%options,
                         'help|h') || pod2usage();

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

# jobs to skip
my %skip;

my $script_dir = ISGA::Site->getBinPath();

# currently running scripts
foreach ( @{ISGA::RunningScript->query( Error => undef)} ) {

  # check on running scripts to make sure they are still running.
  if ( my $pid = $_->getPID ) {

    # test for running
    unless ( kill(SIGCHLD,$pid) ) {
      
      $skip{$_->getCommand} = undef;
      
      # warn - oh crap, the script isn't running
      warn "oh craps, $pid is supposed to be running, but it is not\n";
    }

  # if it's not running, fire it off
  } else {

    system($script_dir . '/' . $_->getCommand . "&");
  }
}

# look for available run_evidence_downloads
foreach ( @{ISGA::RunEvidenceDownload->query( Status => [ 'Pending' ] )} ) {
    
  my $script = "$script_dir/build_run_evidence_download.pl --run_evidence_download=$_";
  
  # don't run the script if it died oddly last time
  next if exists $skip{$script};
  
  # otherwise run it
  system("$script &");
}

# look for available file downloads
foreach ( @{ISGA::UploadRequest->query( Status => ['Pending'] )} ) {

  # build script
  my $script = "$script_dir/download_file_to_repository.pl --upload_request=$_";

  # don't run the script if it died oddly last time
  exists $skip{$script} or system("$script &");
}
