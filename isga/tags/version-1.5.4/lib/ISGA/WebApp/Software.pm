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

use Apache2::Upload;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void AddRelease();

Method to add a new release for a software package.

=cut
#------------------------------------------------------------------------
sub Software::AddRelease {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Software->AddRelease($web_args);

  my $software = $web_args->{software};

  if ($form->canceled()) {
    $self->redirect(uri => "/SoftwareConfiguration/View?software=$software" );
  }
  
  if ( $form->ok ) {
    
    my %form_args = 
      (
       Path => $form->get_input('path'),
       Software => $software,
       Version => $form->get_input('version'),
       Status => $form->get_input('pipeline_status'),
       Release => ISGA::Date->new($form->get_input('release')),
      );
  
    my $software_release = ISGA::SoftwareRelease->create(%form_args);

    $self->redirect( uri => "/SoftwareConfiguration/View?software=$software" );
  }

  $self->_save_arg('form', $form);
  $self->redirect( uri => "/SoftwareConfiguration/AddRelease?software=$software" );
}
       
#------------------------------------------------------------------------

=item public void EditRelease();

Method to edit a software package release.

=cut
#------------------------------------------------------------------------
sub Software::EditRelease {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Software->EditRelease($web_args);

  my $release = $web_args->{software_release};
  my $software = $release->getSoftware();

  if ($form->canceled()) {
    $self->redirect(uri => "/SoftwareConfiguration/View?software=$software" );
  }
  
  if ( $form->ok ) {
    
    my %form_args = 
      (
       Path => $form->get_input('path'),
       Version => $form->get_input('version'),
       Status => $form->get_input('pipeline_status'),
       Release => ISGA::Date->new($form->get_input('release')),
      );

    $release->edit(%form_args);

    $self->redirect( uri => "/SoftwareConfiguration/View?software=$software" );
  }

  $self->_save_arg('form', $form);
  $self->redirect( uri => "/SoftwareConfiguration/EditRelease?software_release=$release" );
}

#------------------------------------------------------------------------

=item public void SetPipelineSoftware();

Method to set a release as default for a pipeline.

=cut
#------------------------------------------------------------------------
sub Software::SetPipelineSoftware {

  my $self = shift;
  my $web_args = $self->args;

  # we need a software release and pipeline_software
  exists $web_args->{pipeline_software} or X::API::Parameter::Missing->throw( parameter => 'PipelineSoftware' );
  exists $web_args->{software_release} or X::API::Parameter::Missing->throw( parameter => 'SoftwareRelease' );

  my $pipeline_software = $web_args->{pipeline_software};
  my $software_release = $web_args->{software_release} || undef;

  # edit the pipeline_software
  $pipeline_software->edit( SoftwareRelease => $software_release );

  # save result
  $self->_save_arg( echo => ( $software_release ? $software_release->getVersion : 'Use Ergatis Configuration' ) );
  $self->redirect( uri => '/Echo' );
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
