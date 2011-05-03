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

  my @sub;

  # should be small enough for a slow sort
  my @sorted = 
    sort { $a->[0]->getName cmp $b->[0]->getName }
      map { [ $_->getVariable, $_ ] } 
	@{ISGA::PipelineConfiguration->query(Pipeline => $pipeline, UserClass => $user_class)};
  
  foreach ( @sorted ) {

    my ($var, $config) = @$_;
    
    my $f = $var->getForm;
    $f->{VALUE} = $config->getValue;
    $f->{HINT} = $var->getDescription;

    push @sub, $f;
  }
    
  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Pipeline Configuration',
      sub => \@sub,
     },
     {
      templ => 'hidden',
      NAME => 'pipeline',
      VALUE => $pipeline,
     }
    );

  if ( $user_class ) {
    push @form,
      {
       templ => 'hidden',
       NAME => 'user_class',
       VALUE => $user_class
      };
  }

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
