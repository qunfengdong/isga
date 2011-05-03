## no critic
# we turn off perl critic because we package doesn't match file
package SysMicro::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

SysMicro::WebApp manages the interface to MASON for SysMicro.

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

=item public void InstallGbrowseData();

Method to setup gbrowse data.

=cut
#------------------------------------------------------------------------
sub Run::InstallGbrowseData {

  my $self = shift;
  my $run = $self->args->{run};
  bless $run, 'SysMicro::Run::ProkaryoticAnnotation';

  $run->installGbrowseData();
  $self->redirect( uri => "/Browser/gbrowse/$run/" );
}

sub Exception::Run::InstallGbrowseData {

  my $self = shift;
  my $run = $self->args->{run};
  bless $run, 'SysMicro::Run::ProkaryoticAnnotation';

  warn "trying to clean up data\n";

  # remove conf
  $run->deleteGbrowseConfigurationFile();

  warn "removed config file\n";

  # remove database dir
  $run->deleteGbrowseDatabase();

  warn "removed db\n";
}

#------------------------------------------------------------------------

=item public void Cancel();

Method to Cancel a run.

=cut
#------------------------------------------------------------------------
sub Run::Cancel {

  my $self = shift;
  my $args = $self->args;

  my $form = SysMicro::FormEngine::Run->Cancel($args);
  my $run = $args->{run} or X::API::Parameter::Missing->throw();

  # we already know we are a run administrator through Foundation
 
  if ($form->canceled( )) {
    $self->redirect( uri => "/Run/View?run=$run" );

  } elsif ( $form->ok ) {

    my $comment = $form->get_input('comment');

    # create run cancellation
    my $cancelation = SysMicro::RunCancelation->create( Run => $run,
							CanceledBy => SysMicro::Login->getAccount,
							CanceledAt => SysMicro::Timestamp->new(),
							Comment => $comment );
    # update run status
    $run->edit( Status => SysMicro::RunStatus->new( Name => 'Canceled' ) );

    # delete contents of run output collection and hide it
    $run->getFileCollection->deleteContents();
    
    # retrieve run outputs that have a file resource, and delete them
    foreach ( @{SysMicro::RunOutput->query(Run => $run, FileResource => {'NOT NULL' => undef})} ) {
      my $fr = $_->getFileResource;
      $_->edit( FileResource => undef );
      $fr->delete();
    }
    
    # notify the user their run was canceled
    SysMicro::RunNotification->create( Run => $run,
				       Account => $run->getCreatedBy,
				       Type =>  SysMicro::NotificationType->new( Name => 'Run Canceled'),
				       Var1 => $comment );
    
    $self->redirect( uri => "/Run/View?run=$run" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/Run/Cancel?run=$run" );
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

  # make sure this is my run_builder
  $run_builder->getCreatedBy == SysMicro::Login->getAccount
   or  X::User::Denied->throw( error => 'You do not own this.' );

  my $run = SysMicro::Run->submit($run_builder);

  # nuke the builder
  foreach ( @{$run_builder->getInputs} ) {
    $_->delete();
  }
  
  my $pipeline = $run_builder->getPipeline;

  # nuke it and redirect
  $run_builder->delete();

  $self->redirect( uri => "/Run/View?run=$run" );
}

sub Exception::Run::Submit {

  my $self = shift;

  my $old = '___ergatis_submit_directory___/' . $self->args->{run_builder}->getErgatisDirectory;
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
  my $account = SysMicro::Login->getAccount;
  my $run = $web_args->{run};

  ref($run) eq 'ARRAY' or $run = [ $run ];
  map { $_->edit( IsHidden => 1 ) } @$run;
  $self->redirect( uri => '/Success' );

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
