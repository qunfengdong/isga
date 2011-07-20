#! /usr/bin/perl

=head1 NAME

build_run_evidence_download.pl - Assembles a gzipped tar archive of the evidence output for the supplied run.

=head1 SYNOPSIS

USAGE: download_file_to_repository.pl --run_evidence_download=id
       [ --help
       ]

=head1 OPTIONS

B<--run_evidence_download>
    The run_evidence_download to process.

=head1 DESCRIPTION

This creates a new ISGA user.

=head1 INPUT

=head1 OUTPUT

=head1 CONTACT

=cut

use strict;
use warnings;

use ISGA;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

use List::MoreUtils qw(any);

my %options = ();
my $result = GetOptions (\%options,
			 'run_evidence_download=i',
			 'help|h') || pod2usage();

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

&check_parameters(\%options);
my $red = ISGA::RunEvidenceDownload->new( Id => $options{run_evidence_download} );

# register this script
my $running = ISGA::RunningScript->create( PID => $$, Command => "build_run_evidence_download.pl --run_evidence_download=$options{run_evidence_download}" );

# make sure we're in the correct status
any { $red->getStatus eq $_ } qw( Pending Failed )
  or X->throw( message => "Attempted to process  RunEvidenceDownload $red, but the status is not Pending or Failed");

# register the download as working
$red->edit(Status => 'Running');

# start transaction
eval {
  
  ISGA::DB->begin_work();

  my $run = $red->getRun();

  $run->buildEvidenceFile();

  # send email
  ISGA::RunNotification->create( 
      Type => ISGA::NotificationType->new( Name => 'Run Raw Data Download Ready' ),
      Run => $run,
      Party => $run->getCreatedBy );
  
  # mark it as complete
  $red->edit(Status => 'Finished', CreatedAt => ISGA::Timestamp->new() );

  # delete notification request
  ISGA::DB->commit();

};

# if things failed
if ( $@ ) {
  ISGA::DB->rollback();
  
  my $e = $@;

  # clean up
  $red->edit(Status => 'Failed');
  $running->delete();

  X::Dropped->throw( error => $e);
}

# clean up
$running->delete();

sub check_parameters {

  my ($options) = @_;
  
  if ( ! exists $options{run_evidence_download} ) {
    print "--run_evidence_download is a required parameter\n";
    exit(1);
  }

}
