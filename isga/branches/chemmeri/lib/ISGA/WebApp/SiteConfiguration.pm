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

=item public void AddUnixEnvironment();

Method to add new unix environments to ISGA.

=cut
#------------------------------------------------------------------------
sub SiteConfiguration::AddUnixEnvironment {

  my $self = shift;
  my $args = $self->args;

  my $form = ISGA::FormEngine::SiteConfiguration->AddUnixEnvironment($args);

  if ( $form->canceled ) {
    $self->redirect( uri => '/SiteConfiguration/ListEnvironments' );
  }

  if ($form->ok) {    
    my $env = 
      ISGA::UnixEnvironment->create( Name => $form->get_input('name'),
				     Path => $form->get_input('path'),
				     Shell => $form->get_input('shell'),
				     Nice => $form->get_input('nice') );
    
    $self->redirect( uri => "/SiteConfiguration/ViewEnvironment?job_environment=$env" );
  }

  # bounce!!!!!
  $self->_save_arg('form', $form);
  $self->redirect( uri => '/SiteConfiguration/AddUnixEnvironment' );  
}

#------------------------------------------------------------------------

=item public void AddSGEEnvironment();

Method to add new SGE environments to ISGA.

=cut
#------------------------------------------------------------------------
sub SiteConfiguration::AddSGEEnvironment {

  my $self = shift;
  my $args = $self->args;

  my $form = ISGA::FormEngine::SiteConfiguration->AddSGEEnvironment($args);

  if ( $form->canceled ) {
    $self->redirect( uri => '/SiteConfiguration/ListEnvironments' );
  }

  if ($form->ok) {    
    my $env = 
      ISGA::SGEEnvironment->create( Name => $form->get_input('name'),
				    Path => $form->get_input('path'),
				    Shell => $form->get_input('shell'),
				    ExecutablePath => $form->get_input('executable_path'),
				    Cell => $form->get_input('cell'),
				    ExecdPort => $form->get_input('execd'),
				    QmasterPort => $form->get_input('qmaster'),
				    Root => $form->get_input('root'),
				    Queue => $form->get_input('queue') );

    $self->redirect( uri => "/SiteConfiguration/ViewEnvironment?job_environment=$env" );
  }

  # bounce!!!!!
  $self->_save_arg('form', $form);
  $self->redirect( uri => '/SiteConfiguration/AddSGEEnvironment' );  
}

#------------------------------------------------------------------------

=item public void Edit();

Method to edit the site configuration.

=cut
#------------------------------------------------------------------------
sub SiteConfiguration::Edit {

  my $self = shift;
  my $args = $self->args;

  my $form = ISGA::FormEngine::SiteConfiguration->Edit($args);
  
  if ( $form->canceled()) {
    $self->redirect( uri => '/SiteConfiguration/View' );
    
  } elsif ( $form->ok ) {

    # process allow_sge_requests
    my $allow_sge_requests = $form->get_input('allow_sge_requests');
    
    if ( $allow_sge_requests != ISGA::SiteConfiguration->value('allow_sge_requests') ) {

      my $var = ISGA::ConfigurationVariable->new( Name => 'allow_sge_requests' );
      my $sc = ISGA::SiteConfiguration->new( Variable => $var );

      $sc->edit( Value => $allow_sge_requests );
    }

    # process paths
    foreach ( qw( file_repository gbrowse_directory) ) {
      my $new_value = $form->get_input($_);
      $new_value =~ s{/$}{};
      if ( $new_value ne ISGA::SiteConfiguration->value($_) ) {
	my $var = ISGA::ConfigurationVariable->new( Name => $_ );
	ISGA::SiteConfiguration->new( Variable => $var )->edit( Value => $new_value );
      }
    }

    # process strings
    foreach ( qw( default_user_class support_email ) ) {
      my $new_value = $form->get_input($_);
      if ( $new_value ne ISGA::SiteConfiguration->value($_) ) {
	my $var = ISGA::ConfigurationVariable->new( Name => $_ );
	ISGA::SiteConfiguration->new( Variable => $var )->edit( Value => $new_value );
      }
    }

    # process numbers
    foreach ( qw( upload_size_limit ) ) {
      my $new_value = $form->get_input($_);
      if ( $new_value != ISGA::SiteConfiguration->value($_) ) {
	my $var = ISGA::ConfigurationVariable->new( Name => $_ );
	ISGA::SiteConfiguration->new( Variable => $var )->edit( Value => $new_value );
      }
    }

    $self->redirect( uri => '/SiteConfiguration/View' );
  }
  
  # redirect if we need more from the user
  $self->_save_arg('form', $form);
  $self->redirect( uri => '/SiteConfiguration/Edit' );
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
