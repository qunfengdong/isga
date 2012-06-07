#! /usr/bin/perl

=head1 NAME

setup_transcriptome_db.pl - Installs transcriptome database for a run.

=head1 SYNOPSIS

USAGE: setup_transcriptome_db.pl --run=id
       [ --help
       ]

=head1 OPTIONS

B<--run>
    The run to be processed.

=head1 DESCRIPTION

This creats a new transcriptome database instance for the supplied run.

=head1 INPUT

=head1 OUTPUT

=head1 CONTACT

=cut

use strict;
use warnings;

use ISGA;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

my %options = ();
my $result = GetOptions (\%options,
			 'run=i',
			 'help|h') || pod2usage();

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

&check_parameters(\%options);
my $run = $options{run};

# register this script
my $running = ISGA::RunningScript->register("setup_transcriptome_db.pl --run=$run");

# start transaction
eval {
  
  ISGA::DB->begin_work();


  $run->installTranscriptomeData();

  # delete notification request
  ISGA::DB->commit();
  $running->delete();

};

# if things failed
if ( $@ ) {
  ISGA::DB->rollback();
  
  my $e = $@;

  # clean up
  $running->fail("$e");

  # remove database dir
  $run->deleteTranscriptomeData();

  X::Dropped->throw( error => $e);
}

sub check_parameters {

  my ($options) = @_;
  
  if ( ! exists $options->{run} ) {
    print "--run is a required parameter\n";
    exit(1);
  }

  $options->{run} = ISGA::Run->new( Id => $options->{run} );
   
  # skip if we can't install GBrowse for this run
  $options->{run}->generatesTranscriptomeData or exit(0);

  # skip if we have the data already
  $options->{run}->hasTranscriptomeData and exit(0);
}
