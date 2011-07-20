package ISGA::SGEScheduler;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::SGEScheduler contains class methods that are used to submit and 
check the status of SGE jobs.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;
use Schedule::SGE;
use base 'Schedule::SGE';

BEGIN {
 # set some default environment variables. These are default for me, but we'll provide a method to handle them too
 $ENV{'SGE_CELL'}="___SGE_CELL___";
 $ENV{'SGE_EXECD_PORT'}="___SGE_EXECD_PORT___";
 $ENV{'SGE_QMASTER_PORT'}="___SGE_QMASTER_PORT___";
 $ENV{'SGE_ROOT'}="___SGE_ROOT___";
 our $VERSION=0.01;
};



#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string checkStatus(string job_id);

Checks the status of a SGE job.

=cut
#------------------------------------------------------------------------
sub checkStatus {
  my ($self, $job) = @_;
  $self->status();
  my $qstat=$self->executable('qstat');
  my @status = `$qstat -f`;
  my $node;
  my %seenpid;
  while (@status) {
    my $line=shift @status;

    chomp($line);
    next if ($line =~ /^\-/);
    next if ($line =~ /queuename/);
    next if (!$line || $line =~ /^\s*$/);
#    next  if ($line =~ /^\S+/ && $line !~ /^\#/);
    if ($line =~ m#^\s*(\d+)\s+(\d+\.\d+)\s+(\S+.*?)\s+\S+\s+(\S+)\s+(\d+/\d+/\d+\s+\d+\:\d+\:\d+)\s+\S+#) {
      # it is a job
      # something like 
      # 1441 0.56000 testing123 rob          r     03/25/2005 11:59:12     1
      my $pid = $1;
      $seenpid{$pid} = $4;
    } elsif ($line =~ /^\#/ || $line =~ /PENDING/) {
      # at the end of the list there are some pending jobs
      while (@status) {
        my $pend=shift(@status);
        next if ($pend =~ /PENDING/ || $pend =~ /^\#/);
        $pend =~ s/^\s+//; $pend =~ s/\s+$//;
        my @pieces=split /\s+/, $pend;
        next unless (scalar @pieces > 5);
        my $pid = shift @pieces;
        $seenpid{$pid} = $pieces[3];
      }
    } else {
      print STDERR "We don't know how to parse |$line|\n";
    }
  }

  if(defined $self->{'job'}->{$job} && defined $seenpid{$job} && ( $seenpid{$job} eq "r" || $seenpid{$job} eq "Rr" )){
    return "Running";
  }elsif(defined $self->{'job'}->{$job} && defined $seenpid{$job} && ( $seenpid{$job} eq "qw" || $seenpid{$job} eq "hqw" || $seenpid{$job} eq "hRqw" || $seenpid{$job} eq "Rq" )){
    return "Pending";
  }elsif(defined $self->{'job'}->{$job} && defined $seenpid{$job} && ( $seenpid{$job} eq "Eqw" || $seenpid{$job} eq "Ehqw" || $seenpid{$job} eq "EhRqw" )){
    return "Error";
#  }elsif(defined $self->{'job'}->{$job}  && not defined $seenpid{$job}){
  }elsif(not defined $seenpid{$job}){
    return "Finished";
  }else{
    return "Failed";
  }
}


#------------------------------------------------------------------------

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=item X::API::Parameter

=item X::API::Compare

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
