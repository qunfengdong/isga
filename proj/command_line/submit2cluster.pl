#!/usr/bin/perl -w

# submit a job using my new method

use strict;
use warnings;
use lib qw( /data/web/sysmicro.cgb/docs/lib );
use SysMicro;

my $usage=<<EOF;

$0 <options> <command>

OPTIONS: 
 -N name    (default = first word of command)
 -P project (default = redwards)
 
 -n notify  		(notify is not set unless -n is included. The default email address is redwards\@salmonella.org, but is unaffected unless you set notify).
 -e email address
 
EOF

my ($name, $project, $command, $notify, $email)=('', '', '', 1, "abuechle\@cgb.indiana.edu");
while (@ARGV) {
 my $test=shift @ARGV;
 if ($test eq "-N") {$name=shift @ARGV}
 elsif ($test eq "-P") {$project=shift @ARGV}
 elsif ($test eq "-n") {$notify=1}
 elsif ($test eq "-e") {$email=shift @ARGV}
 else {$command .= " ". $test}
}

unless ($name) { 
 $command =~ m/^(\S+)/; $name=$1;
}
 

my $sge=SysMicro::SGEScheduler->new(
 -project   	=> $project,
 -executable 	=> {qsub=>'/cluster/sge/bin/sol-amd64/qsub', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
 -name		=> $name,
 -verbose   	=> 1,
 -notify 	=> $notify,
 -mailto	=> $email,
);
 
$sge->command($command);
my $pid=$sge->execute();
print "$pid\n";

my $job_status = '';
until ($job_status eq 'Finished' || $job_status eq 'Error'){
  $job_status = $sge->checkStatus($pid);
  print "$job_status\n";
  sleep(5);
}
exit(0);
