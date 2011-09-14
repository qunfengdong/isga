#! /usr/bin/perl

=head1 NAME

purge_run_evidence.pl - Deletes raw data for Ergatis runs.

=head1 SYNOPSIS

USAGE: purge_run_evidence.pl
       [ --all
         --count=number_of_runs
         --cutoff=number_of_days
         --help
       ]

=head1 OPTIONS

B<--all>

Remove data for all runs over the expiration cutoff. You must supply exactly one argument for this command.

B<--count=number_of_runs>

Remove data for supplied number of runs over the expiration cutoff, starting with the oldest. You must supply exactly one argument for this command.

B<--cutoff=number_of_days>

Remove data for all runs older than the value supplied. You must supply exactly one argument for this command.

B<--help,-h> 
    This help message

=head1 DESCRIPTION

This script will delete Ergatis runtime data, raw output, and ISGA 'Evidence Output' for runs that have passed the expiration cutoff.

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
			 'all',
			 'count?i',
			 'cutoff?i',
			 'help|h') || pod2usage();

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

my %user_class_cutoff = &build_cutoff_lookup();

my $purge_count = 0;
my $purge_limit = undef;
my $purge_cutoff = 0;

&check_parameters(\%options);

foreach my $run ( @{ISGA::Run->query( RawDataStatus => 'Available', OrderBy => 'FinishedAt' )} ) {

  # stop if we're over our limit
  last if defined($purge_limit) and $purge_count >= $purge_limit;


  # count purged
  $purge_count++;

}

# start transaction
eval {
  
  ISGA::DB->begin_work();

  # delete notification request
  ISGA::DB->commit();

};

# if things failed
if ( $@ ) {
  ISGA::DB->rollback();
  
  my $e = $@;

  # clean up

  X::Dropped->throw( error => $e);
}

sub check_parameters {

  my ($options) = @_;

  my $opt_count = 0;
  
  exists $options->{all} and $opt_count++;

  if ( exists $options->{count} ) {
    $opt_count++;
    $purge_limit = $options->{count};
  }

  if ( exists $options->{cutoff} ) {
    $opt_count++;
    $purge_cutoff = $options->{cutoff};
  }

  print "You must supply exactly one parameter." if $opt_count != 1;
}


sub build_cutoff_lookup {

  my %lookup;

  foreach ( @{ISGA::UserClass->query()} ) {
    $lookup{$_} = ISGA::UserClassConfiguration->value('raw_data_retention', UserClass => $_);
  }

  return %lookup;
}
