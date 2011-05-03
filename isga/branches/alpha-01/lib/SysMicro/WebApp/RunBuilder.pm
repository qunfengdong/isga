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

use Apache2::Upload;
#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void Create();

Method to Create a new run builder

=cut
#------------------------------------------------------------------------
sub RunBuilder::Create {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::RunBuilder->Create($web_args);

  my $args = $self->args;

  my $account = SysMicro::Login->getAccount;
  my $pipeline = $web_args->{pipeline};

  $pipeline->getStatus eq 'Retired'
    and X::User::Denied->throw( error => 'Pipeline has been retired.' );


  # make sure we have permission to run this
  if ( $pipeline->isa( 'SysMicro::UserPipeline' ) ) {
    
    $pipeline->getCreatedBy == $account or
      X::User::Denied->throw( error => 'You do not have permission to execute this pipeline.' );

    # allow for pipeline sharing in the future
  }


  if ( $form->canceled() ) {
    $self->redirect( uri => "/Pipeline/View?pipeline=$pipeline" );

  } elsif ( $form->ok ) {

    my %form_args =
      ( 
       Pipeline => $pipeline,
       Name => $form->get_input('name'),
       StartedAt => SysMicro::Timestamp->new,
       CreatedBy => $account
      );

    my $description = $form->get_input('description');
    $description and $form_args{Description} = $description;  

    my $builder = SysMicro::RunBuilder->create(%form_args);
    $self->redirect( uri => "/RunBuilder/View?run_builder=$builder" );
  } 

  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/RunBuilder/Create' );
}  

#------------------------------------------------------------------------

=item public void EditDetails();

Method to edit the details for a pipeline builder

=cut
#------------------------------------------------------------------------
sub RunBuilder::EditDetails {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::RunBuilder->EditDetails($web_args);
  
  my $run_builder = $web_args->{run_builder};

  if ($form->canceled( )) {

    $self->redirect( 
     uri => "/RunBuilder/View?run_builder=$run_builder" 
		   );
  }

  if ( $form->ok ) {

    my %form_args =
      ( 
       Name => $form->get_input('name'),
       Description => $form->get_input('description')
      );

    $run_builder->edit( %form_args );

    $self->redirect
      ( uri => "/RunBuilder/View?run_builder=$run_builder" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/RunBuilder/EditDetails?run_builder=$run_builder" );
}

#------------------------------------------------------------------------

=item public void UploadFile();

Method to upload a file for input.

=cut
#------------------------------------------------------------------------
sub RunBuilder::UploadFile {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::RunBuilder->UploadFile($web_args);
  
  my $run_builder = $web_args->{run_builder};

  $form->canceled and $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );

  if ( $form->ok ) {

    my $run_builder = $form->get_input('run_builder');
    my $upload = $self->apache_req->upload('file_name');

    my $pipeline_input = $form->get_input('pipeline_input');
    my $content = $pipeline_input->getType->getContent;
    my $format = $pipeline_input->getFormat;

    SysMicro::File::verifyFileHandle($upload->fh, $content, $format);

    my $file = SysMicro::File->upload( $upload->fh, 
				       $form->get_input( 'file_name' ), 
				       $content, $format);

    # associate the file with the input
    my ($rbi) = @{SysMicro::RunBuilderInput->query( RunBuilder => $run_builder,
						    PipelineInput => $pipeline_input )};

    if ( $rbi ) {
      $rbi->edit( File => $file );
    } else {
      SysMicro::RunBuilderInput->create( RunBuilder => $run_builder, File => $file,
					 PipelineInput => $pipeline_input );
    }
  
    $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );

   } 

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/RunBuilder/UploadFile?run_builder=$run_builder" );
}

#------------------------------------------------------------------------

=item public void RunBuilder::SelectInput();

Saves the selection of a file as input for a RunBuilder.

=cut
#------------------------------------------------------------------------
sub RunBuilder::SelectInput {

  my $self = shift;
  my $args = $self->args;

  my $file = $args->{file};
  my $pi = $args->{pipeline_input};
  my $run_builder = $args->{run_builder};

  # permissions check
  $run_builder->getCreatedBy == SysMicro::Login->getAccount 
    or X::User::Denied->throw;

  $file->getCreatedBy == SysMicro::Login->getAccount
    or X::User::Denied->throw;

  # calculate the rbi
  my ($rbi) = 
    @{SysMicro::RunBuilderInput->query( RunBuilder => $run_builder,
					PipelineInput => $pi )};

  # probably should confirm type/format here
  if ( $rbi ) {
    $rbi->edit( File => $file );
  } else {
    SysMicro::RunBuilderInput->create( RunBuilder => $run_builder,
				       File => $file,
				       PipelineInput => $pi );
  }
  
  $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );
}
  
#------------------------------------------------------------------------

=item public void Cancel();

Removes a RunBuilder object from the system

=cut
#------------------------------------------------------------------------
sub RunBuilder::Cancel {

  my $self = shift;
  my $args = $self->args;

  # make sure they supplied a builder
  my $run_builder = $args->{run_builder};
 
  # make sure they own the runbuilder
  my $account = SysMicro::Login->getAccount;
  $run_builder->getCreatedBy == SysMicro::Login->getAccount
    or X::User::Denied->throw( error => 'You do not own this run builder' );

  # remove the inputs
  foreach ( @{$run_builder->getInputs} ) {
    $_->delete();
  }
  
  my $pipeline = $run_builder->getPipeline;

  # nuke it and redirect
  $run_builder->delete();
  $self->redirect( uri => "/Pipeline/View?pipeline=$pipeline" );
}

sub Exception::RunBuilder::Cancel {

}


1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
