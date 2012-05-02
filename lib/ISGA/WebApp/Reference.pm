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

Method to add a new release for a reference package.

=cut
#------------------------------------------------------------------------
sub Reference::AddRelease {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Reference->AddRelease($web_args);

  my $reference = $web_args->{reference};

  if ($form->canceled()) {
    $self->redirect(uri => "/SoftwareConfiguration/View?reference=$reference" );
  }
  
  if ( $form->ok ) {
    
    my %form_args = 
      (
       Path => $form->get_input('path'),
       Reference => $reference,
       Version => $form->get_input('version'),
       Status => $form->get_input('pipeline_status'),
       Release => ISGA::Date->new($form->get_input('release')),
      );
  
    my $reference_release = ISGA::ReferenceRelease->create(%form_args);

    $self->redirect( uri => "/SoftwareConfiguration/View?reference=$reference" );
  }

  $self->_save_arg('form', $form);
  $self->redirect( uri => "/SoftwareConfiguration/AddRelease?reference=$reference" );
}
       
#------------------------------------------------------------------------

=item public void SetPipelineReference();

Method to set a release as default for a pipeline.

=cut
#------------------------------------------------------------------------
sub Reference::SetPipelineReference {

  my $self = shift;
  my $web_args = $self->args;

  # we need a reference release and pipeline_reference
  exists $web_args->{pipeline_reference} or X::API::Parameter::Missing->throw( parameter => 'PipelineReference' );
  exists $web_args->{reference_release} or X::API::Parameter::Missing->throw( parameter => 'ReferenceRelease' );

  my $pipeline_reference = $web_args->{pipeline_reference};
  my $reference_release = $web_args->{reference_release} || undef;

  # edit the pipeline_reference
  $pipeline_reference->edit( ReferenceRelease => $reference_release );

  # save result
  $self->_save_arg( echo => ( $reference_release ? $reference_release->getVersion : 'Use Ergatis Configuration' ) );
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
