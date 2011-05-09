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
sub UserClassConfiguration::Edit {

  my $self = shift;
  my $args = $self->args;

  my $form = ISGA::FormEngine::UserClassConfiguration->Edit($args);
  
  # grab which user class we are editing
  my $user_class = ( exists $args->{user_class} ? $args->{user_class} : undef );

  my $varstring = "?user_class=$user_class";

  # save the hash used to look up current values
  my %values = ( UserClass => $user_class );

  if ( $form->canceled()) {
    $self->redirect( uri => "/UserClassConfiguration/View$varstring" );
    
  } elsif ( $form->ok ) {

    # raw_data_retention, pipeline_quota
    foreach ( qw( raw_data_retention pipeline_quota ) ) {
      
      my $value = $form->get_input($_);
      if ( $value != ISGA::UserClassConfiguration->value($_, %values) ) {
      
	my $var = ISGA::ConfigurationVariable->new( Name => $_ );
	my $uc = ISGA::UserClassConfiguration->new( Variable => $var, %values );
	$uc->edit( Value => $value );
      }
    }

    $self->redirect( uri => "/UserClassConfiguration/View$varstring" );
  }
  
  # redirect if we need more from the user
  $self->_save_arg('form', $form);

  $self->redirect( uri => "/UserClassConfiguration/Edit$varstring" );
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
