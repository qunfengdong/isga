
## no critic
# we turn off perl critic because we package doesn't match file
package ISGA::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

ISGA::WebApp manages the interface to MASON for ISGA.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;
#use CGI;

use Digest::MD5;
use Apache2::Upload;
use File::Copy;
use File::Basename;
#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void Blast();

Run a Workbench Blast job using SGE nodes.

=cut
#------------------------------------------------------------------------
sub WorkBench::RunJob {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->Build($web_args);
    my $job_type = $web_args->{job_type};
    if ( $form->canceled ) {
        $self->redirect( uri => "/WorkBench/Form?job_type=$job_type" );
    }

    if ($form->ok) {
        my $notify = $form->get_input('notify_user');

        my %job_args =
            (
             Pid => 0,
             Status => 'Pending',
             Type => $job_type,
             CreatedBy => ISGA::Login->getAccount,
             CreatedAt => ISGA::Timestamp->new(),
             NotifyUser => $notify
             );

        my $job = ISGA::Job->create(%job_args) or X->throw(message => 'Error submitting job.');

        my $command = $job_type->getClass->buildWebAppCommand($self, $form, $job);

        my $log_name  = $job->getType->getName . "_" .  $job->getId;

#        my $sge=ISGA::SGEScheduler->new(
#                                        -executable  => {qsub=>'___sge_executables___'.'/qsub -q ___SGE_QUEUE___', qstat=>'___sge_executables___'.'/qstat'},
#                                        -output_file => '___tmp_file_directory___'."/workbench/sge_log/".$log_name.".sgeout",
#                                        -error_file => '___tmp_file_directory___'."/workbench/sge_log/".$log_name.".sgeerror",
#                                       );
#        $sge->command($command);

        system("$command &");


#        my $pid = $sge->execute();
        my $pid = "$log_name".time;
#        X->throw(message => 'Error submitting job.') unless($pid);
        $job->edit( Pid => $pid );

        $self->redirect( uri => "/WorkBench/Result?job=$job" );
    }

    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => "/WorkBench/Form?job_type=$job_type" );

}

#------------------------------------------------------------------------

=item public void Notify();

Sets Notify to true for Workbench job 

=cut
#------------------------------------------------------------------------
sub WorkBench::Notify{
  my $self = shift;
  my $web_args = $self->args;
  my $account = ISGA::Login->getAccount;
  my $job = $web_args->{job};
  $job->edit( NotifyUser => 1 );

  $self->redirect( uri => "/WorkBench/Result?job=$job" );
}


1;


__END__
