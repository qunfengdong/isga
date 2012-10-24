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
sub PipelineConfiguration::Edit {

  my $self = shift;
  my $args = $self->args;

  my $form = ISGA::FormEngine::PipelineConfiguration->Edit($args);
  
  # grab which combination of pipeline and user class we are editing
  my $pipeline = $args->{pipeline};
  my $user_class = ( exists $args->{user_class} ? $args->{user_class} : undef );

  my $varstring = "?pipeline=$pipeline";
  $user_class and $varstring .= "&user_class=$user_class";

  # save the hash used to look up current values
  my %values = ( Pipeline => $pipeline, UserClass => $user_class );

  if ( $form->canceled()) {
    $self->redirect( uri => "/PipelineConfiguration/View$varstring" );
    
  } elsif ( $form->ok ) {

    # process all the paths at once
    foreach ( qw( ergatis_project_directory ergatis_submission_directory ) ) {
      my $new_val = $form->get_input($_);
      
      # strip trailing slash
      $new_val =~ s{/$}{};
      
      if ( $new_val ne ISGA::PipelineConfiguration->value($_, %values) ) {
	my $var = ISGA::ConfigurationVariable->new( Name => $_ );

	if ( ISGA::PipelineConfiguration->exists( Variable => $var, %values) ) {
	  ISGA::PipelineConfiguration->new(Variable => $var, %values)->edit(Value => $new_val);
	} else {
	  ISGA::PipelineConfiguration->create( %values, Variable => $var, Value => $new_val );
	}
      }
    }

    # process accessibility
    my $access_permitted = $form->get_input('access_permitted');
    
    warn "got $access_permitted\n";

    # first see if the value is different from either the global setting or override
    if ( $access_permitted != ISGA::PipelineConfiguration->value('access_permitted', %values) ) {
      my $var = ISGA::ConfigurationVariable->new( Name => 'access_permitted' );
      
      warn "it changed\n";
      
      # if this configuration exists for this user class, edit it directly
      if ( ISGA::PipelineConfiguration->exists(Variable => $var, %values) ) {
	ISGA::PipelineConfiguration->new( Variable => $var, %values )->edit( Value => $access_permitted );

	warn "and here it is!\n";

      # otherwise create it with the new value
      } else {
	ISGA::PipelineConfiguration->create( %values, Variable => $var, Value => $access_permitted );
	
	warn "we tried to create a new one\n";

      }
    }


    # process ergatis_project_name
    my $proj_name = $form->get_input('ergatis_project_name');
    if ( $proj_name ne ISGA::PipelineConfiguration->value( 'ergatis_project_name', %values ) ) {
      my $var = ISGA::ConfigurationVariable->new( Name => 'ergatis_project_name' );

      if ( ISGA::PipelineConfiguration->exists( Variable => $var, %values) ) {
	ISGA::PipelineConfiguration->new(Variable => $var, %values)->edit(Value => $proj_name);
      } else {
	ISGA::PipelineConfiguration->create( %values, Variable => $var, Value => $proj_name );
      }
    }
    
    $self->redirect( uri => "/PipelineConfiguration/View$varstring" );
  }
  
  # redirect if we need more from the user
  $self->_save_arg('form', $form);
  
  $self->redirect( uri => "/PipelineConfiguration/Edit$varstring" );
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
