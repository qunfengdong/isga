package ISGA::FormEngine::PipelineConfiguration;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::PipelineConfiguration - provide pipeline configuration forms.

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

=item public hashref form Edit();

Build a FormEngine object to edit pipeline configuration.

=cut
#------------------------------------------------------------------------
sub Edit {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  # grab which combination of pipeline and user class we are editing
  my $pipeline = $args->{pipeline};
  my $user_class = ( exists $args->{user_class} ? $args->{user_class} : undef );

  my $form_title = 'Global Pipeline Configuration';


  my @sub;
  my @global;

  # start from the bottom
  my @form = 
    (
     {
      templ => 'hidden',
      NAME => 'pipeline',
      VALUE => $pipeline,
     }
    );

  # should be small enough for a slow sort
  my $sorted = $pipeline->getConfiguration($user_class);
  
  foreach ( @$sorted ) {
    
    my $var = $_->getVariable;
    
    my $f = $var->getForm;
    $f->{VALUE} = $_->getValue;
    $f->{HINT} = $var->getDescription;

    if ( $user_class and ! $_->getUserClass ) {
      push @global, $f;
    } else {
      push @sub, $f;
    }
  }
    
 
  if ( $user_class ) {
    $form_title = 'Pipeline Configuration for ' . $user_class->getName . ' Users';
    unshift @form,
      {
       templ => 'fieldset',
       TITLE => 'Inherited Global Configuration',
       DESCRIPTION => 'Edit these values to override the global configuration for this user class only. To edit the settings for all users, change the User Class to \'Global Settings\'',
       sub => \@global,
	 };
    push @form,
      {
       templ => 'hidden',
       NAME => 'user_class',
       VALUE => $user_class
      };    
  }

  # push the main variables
  unshift @form,
     {
      templ => 'fieldset',
      TITLE => $form_title,
      sub => \@sub,
     };
       

  $form->conf( { ACTION => '/submit/PipelineConfiguration/Edit',
		 FORMNAME => 'pipeline_configuration_edit',
		 SUBMIT => 'Save Changes',
		 sub => \@form } );

  $form->make;
  return $form;
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
