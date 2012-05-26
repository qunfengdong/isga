#! /usr/bin/perl

=head1 NAME

setup_gbrowse_instance.pl - Configures a GBrowse instance and accompanying database for a run.

=head1 SYNOPSIS

USAGE: setup_gbrowse_instance.pl --run=id
       [ --help
       ]

=head1 OPTIONS

B<--run>
    The run to be processed.

=head1 DESCRIPTION

This creats a new GBrowse and gene database instance for the supplied run.

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
			 'run=i',
			 'help|h') || pod2usage();

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

&check_parameters(\%options);
my $run = $options{run};

# register this script
my $running = ISGA::RunningScript->register("setup_gbrowse_instance.pl --run=$run");

# start transaction
eval {
  
  ISGA::DB->begin_work();


  $run->installGBrowseData();

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

  # remove conf
  $run->deleteGBrowseConfigurationFile();

  # remove database dir
  $run->deleteGBrowseDatabase();

  # set email list
  my $email = join (",", @{ISGA::Site->getErrorNotificationEmail});
  my $server = ISGA::Site->getServerName();
  my $support_email = ISGA::SiteConfiguration->value('support_email');
  my $run = $red->getRun();

  my %mail =
    ( To => $email,
      From => $server . " <$support_email>",
      Subject => $server. ' Build Evidence Failure',
      Message => "Build Run Evidence failed for run $run.

$e" );

       Mail::Sendmail::sendmail(%mail)
        or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );


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
  $options->{run}->hasGBrowseData or exit(0);

  # skip if we have the data already
  $options->{run}->hasGBrowseInstallation and exit(0);
}
