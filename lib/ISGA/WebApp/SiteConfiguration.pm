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

    # process default_user_class
    my $default_user_class = $form->get_input('default_user_class');

    if ( $default_user_class ne ISGA::SiteConfiguration->value('default_user_class') ) {

      my $var = ISGA::ConfigurationVariable->new( Name => 'default_user_class' );
      my $sc = ISGA::SiteConfiguration->new( Variable => $var );

      $sc->edit( Value => $default_user_class );
    }

    # process support_email
    my $support_email = $form->get_input('support_email');
    
    if ( $support_email ne ISGA::SiteConfiguration->value('support_email') ) {
      my $var = ISGA::ConfigurationVariable->new( Name => 'support_email' );
      my $sc = ISGA::SiteConfiguration->new( Variable => $var );
      $sc->edit( Value => $support_email );
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
