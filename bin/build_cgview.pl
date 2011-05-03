#! /usr/bin/perl

use strict;
use warnings;

use ISGA;
use ISGA::X;
use ISGA::Login;
use ISGA::Log;
use ISGA::Site;

# grab run
my ($run_id) = @ARGV0;

my $run = ISGA::Run::ProkaryoticAnnotation->new( Id => $run_id );

# build data

# must be complete
$run->getStatus eq 'Complete' or X::API->throw( message => 'Run is not complte');

# check for complete installation
$run->hasGbrowseInstallation and exit 0;

# check for incomplete installation

# write CGView config
my $zoom = $run->writeCGViewConfig();

# retrieve all the genes
my @genes;
foreach my $contig ( @{ISGA::Contig->query(Run => $run)} ) {
  push @genes [ $contig, $_ ] for @{ISGA::Gene->query( Contig => $contig )};
}

# split the array of commands into 10 SGE jobs
my $jobs = 10;
my @sge_ids;

for ( my $i = 0; $i < $jobs; $i++ ) {

  my $counter = 0;
  my @sge = grep { $counter++ % $jobs == $i } @genes;
  
  push @sge_ids, $run->runCGView($zoom, @sge);
}  

# now wait for the jobs to finish
while ( 1 ) {

  sleep 5;
  my @new_ids;
  
  my $sge=ISGA::SGEScheduler->new(-executable  => { qsub=>'/cluster/sge/bin/sol-amd64/qsub', 
							qstat=>'/cluster/sge/bin/sol-amd64/qstat'});
  
  foreach ( @sge_ids ) {
    
    my $status = $sge->checkStatus($_);

    if ( $status eq 'Pending' or $status eq 'Running' ) {
      push @new_ids, $_;
    } elsif ( $status eq 'Error' or $status eq 'Failed' ) {
      X::SGE::Job->throw ( message => "SGE job failed", id => $i_ );
    }
  }

  # as soon as the last id is done, we are finished
  last unless @new_ids;
  @sge_ids = @new_ids
}

# convert html to image map only
$run->extractImagemap($_->[1]) for @genes;

# send email
ISGA::RunNotification->create( Run => $run,
				   Account => $run->getCreatedBy,
				   Type => ISGA::NotificationType->new( Name = 'Gbrowse Instance Ready' ));
				   
# we made it
exit 0;
