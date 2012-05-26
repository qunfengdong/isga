#! /usr/bin/perl

=head1 NAME

delete_run.pl - Deletes a run from the ISGA system and the underlying
Ergatis installation.

=head1 SYNOPSIS

USAGE: delete_run.pl
         --run=run_id
       [ --help
       ]



=head1 OPTIONS

B<--run>

Remove the specified run from the system.

B<--help,-h> 
    This help message

=head1 DESCRIPTION

Deletes a run from the ISGA system and the underlying
Ergatis installation. Files and database entries ARE NOT backed up, so
use this command carefully and at your own risk.

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

&check_parameters(\%options);

my $run = $options{run};

if ( ISGA::RunNotification->exists( Run => $run ) ) {
  print "There is a pending notification regarding this run. Please try again in 5 minutes.\n";
  exit(-1);
}

# start transaction
eval {
    
  ISGA::DB->begin_work();

  # first purge the run
  $run->purge();

  foreach ( @{ISGA::RunCancelation->query( Run => $run )} ) {
    $_->delete;
  }
  
  foreach ( @{ISGA::RunEvidenceDownload->query( Run => $run )} ) {
    $_->delete;
  }

  foreach ( @{ISGA::RunOutput->query( Run => $run )} ) {
    my $fr = $_->getFileResource;
    $_->delete();
    $fr->delete();
  }

  foreach ( @{$run->getReferenceReleases} ) {
    $run->removeReferenceRelease($_);
  }

  foreach ( @{$run->getSoftwareReleases} ) {
    $run->removeSoftwareRelease($_);
  }

  foreach ( @{ISGA::RunCluster->query( Run => $run )} ) {
    $_->delete;
  }

  foreach ( @{ISGA::RunShare->query( Resource => $run )} ) {
    $_->delete;
  }

  foreach ( @{ISGA::RunInput->query( Run => $run )} ) {
    $_->getFileResource->delete();
    $_->delete;
  }

  # remove GBrowse Data
  $run->deleteGBrowse if $run->hasGBrowseInstallation;

  # remove run and file collection
  my $fc = $run->getFileCollection();
  $run->delete();
  $fc->delete();

  ISGA::DB->commit();
};

# if things failed
if ( $@ ) {
  ISGA::DB->rollback();
  
  my $e = $@;
  
  X::Dropped->throw( error => $e);
}

sub check_parameters {

  my ($options) = @_;

  $options->{run} = ISGA::Run->new( Id => $options->{run} );
}
