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


#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void BuildEvidenceDownload

Method to setup gbrowse data.

=cut
#------------------------------------------------------------------------
sub Run::BuildEvidenceDownload {

    my $self = shift;
    my $run = $self->args->{run};

    # create RED object
    my $red = ISGA::RunEvidenceDownload->create( Run => $run,
						 Status => 'Pending' );

    $self->redirect(uri => "/Run/View?run=$run");
}

#------------------------------------------------------------------------

=item public void InstallGbrowseData();

Method to setup gbrowse data.

=cut
#------------------------------------------------------------------------
sub Run::InstallGbrowseData {

  my $self = shift;
  my $run = $self->args->{run};

  $run->hasGBrowseData() or X::User->throw( "Can not install Gbrowse data for non-annotation pipelines" );

  ISGA::RunningScript->schedule("setup_gbrowse_instance.pl --run=$run");

  $self->redirect( uri => "/Run/View?run=$run" );
}

#------------------------------------------------------------------------

=item public void Cancel();

Method to Cancel a run.

=cut
#------------------------------------------------------------------------
sub Run::Cancel {

  my $self = shift;
  my $args = $self->args;

  my $form = ISGA::FormEngine::Run->Cancel($args);
  my $run = $args->{run} or X::API::Parameter::Missing->throw();

  # we already know we are a run administrator through Foundation
 
  if ($form->canceled( )) {
    $self->redirect( uri => "/Run/View?run=$run" );

  } elsif ( $form->ok ) {

    my $comment = $form->get_input('comment');

    # create run cancellation
    my $cancelation = ISGA::RunCancelation->create( Run => $run,
						    CanceledBy => ISGA::Login->getAccount,
						    CanceledAt => ISGA::Timestamp->new(),
						    Comment => $comment );

    # update run status
    $run->edit( Status => ISGA::RunStatus->new( Name => 'Canceled' ) );

    # delete contents of run output collection and hide it
    if ( my $ic = $run->getFileCollection ) {
      $ic->deleteContents();
      $ic->edit( IsHidden => 1 );
    }
    
    # retrieve run outputs that have a file resource, and delete them
    foreach ( @{ISGA::RunOutput->query(Run => $run, FileResource => {'NOT NULL' => undef})} ) {
      my $fr = $_->getFileResource;
      $_->edit( FileResource => undef );
      $fr->delete();
    }
    
    # notify the user their run was canceled
    ISGA::RunNotification->create( Run => $run,
				   Account => $run->getCreatedBy,
				   Type =>  ISGA::NotificationType->new( Name => 'Run Canceled'),
				   Var1 => $comment );
    
    $self->redirect( uri => "/Run/View?run=$run" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/Run/Cancel?run=$run" );
}

#------------------------------------------------------------------------

=item public void Clone();

Method to Clone a run.

=cut
#------------------------------------------------------------------------
sub Run::Clone {

  my $self = shift;
  my $args = $self->args;

  my $form = ISGA::FormEngine::Run->Clone($args);
  my $run = $args->{run} or X::API::Parameter::Missing->throw();

  # we already know we are a run administrator through Foundation
 
  if ($form->canceled( )) {

    $self->redirect( uri => "/Run/View?run=$run" );

  } elsif ( $form->ok ) {

    my $incomplete = ISGA::RunStatus->new( Name => 'Incomplete' );

    my $newid = $form->get_input('newid');

    # update run status
    $run->edit( Status => ISGA::RunStatus->new( Name => 'Running' ),
	        ErgatisKey => $newid );

    # delete contents of run output collection and hide it
    if ( my $ic = $run->getFileCollection ) {
      $ic->deleteContents();
      $ic->edit( IsHidden => 1 );
    }

    # clean up the clusters
    foreach ( @{ISGA::RunCluster->query( Run => $run )} ) {
      $_->edit( Status => $incomplete, StartedAt => undef, FinishedAt => undef,
		FinishedActions => undef, TotalActions => undef );
    }

    # retrieve run outputs that have a file resource, and delete them
    foreach ( @{ISGA::RunOutput->query(Run => $run, FileResource => {'NOT NULL' => undef})} ) {
      my $fr = $_->getFileResource;
      $_->edit( FileResource => undef );
    }
    
    $self->redirect( uri => "/Run/View?run=$run" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/Run/Clone?run=$run" );
}


#------------------------------------------------------------------------

=item public void Submit();

Method to Submit a run.

=cut
#------------------------------------------------------------------------
sub Run::Submit {

  my $self = shift;
  my $args = $self->args;

  my $run_builder = $args->{run_builder} or X::API::Parameter::Missing->throw();

  my $account = ISGA::Login->getAccount;
  my $quota = ISGA::UserClassConfiguration->value('pipeline_quota', 
						  UserClass => $account->getUserClass);
  my $runs = ISGA::Run->getCurrentRunCount($account);

  # make sure this is my run_builder
  $run_builder->getCreatedBy == $account
   or  X::User::Denied->throw( error => 'You do not own this.' );

  # make sure the user isn't over their quota
  $runs >= $quota 
    and X::User::Denied->throw( error => 'You have reached your concurrent pipeline quota.');
  


  my $run = ISGA::Run->submit($run_builder);

  # nuke the builder
  foreach ( @{$run_builder->getInputs} ) {
    $_->delete();
  }

#  X->throw('bam!');
  
  # nuke it and redirect
  $run_builder->delete();

  $self->redirect( uri => "/Run/View?run=$run" );
}

sub Exception::Run::Submit {

  my $self = shift;

  my $run_builder = $self->args->{run_builder};

  my $old = join( '/', $run_builder->getPipeline->getErgatisSubmissionDirectory, $run_builder->getErgatisDirectory );
  my $new = $old . '-save-' . time;

  # send email about error

  # remove any existing files
  rename( $old, $new );
}

#------------------------------------------------------------------------

=item public void Submit();

Method to Submit a run.

=cut
#------------------------------------------------------------------------
sub Run::Hide {

  my $self = shift;
  my $web_args = $self->args;
  my $account = ISGA::Login->getAccount;
  my $runs = $web_args->{'runs'};
  my @run = split(/\|/, $runs);

  map { ISGA::Run->new(Id => $_)->edit( IsHidden => 1 ) } @run;
  $self->redirect( uri => '/Success' );

}

#------------------------------------------------------------------------

=item public void Submit();

Method to Submit a run.

=cut
#------------------------------------------------------------------------
sub Run::Show {

  my $self = shift;
  my $web_args = $self->args;
  my $account = ISGA::Login->getAccount;
  my $runs = $web_args->{'runs'};
  my @run = split(/\|/, $runs);

  map { ISGA::Run->new(Id => $_)->edit( IsHidden => 0 ) } @run;
  $self->redirect( uri => '/Success' );

}

#------------------------------------------------------------------------

=item public void Test();

Method to test setup gbrowse data.

=cut
#------------------------------------------------------------------------
sub Run::Test {

  my $self = shift;
  my $run = $self->args->{run};

  $self->redirect( uri => "/Pipeline/View?pipeline=1" );
}

return 1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
