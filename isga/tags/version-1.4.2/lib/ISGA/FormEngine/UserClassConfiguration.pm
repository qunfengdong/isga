package ISGA::FormEngine::UserClassConfiguration;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::UserClassConfiguration - provide user class configuration forms.

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

Build a FormEngine object to edit user class configuration.

=cut
#------------------------------------------------------------------------
sub Edit {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  # grab which user class we are editing
  my $user_class = $args->{user_class};

  my @sub;

  # should be small enough for a slow sort
  my @sorted = 
    sort { $a->[0]->getName cmp $b->[0]->getName }
      map { [ $_->getVariable, $_ ] } 
	@{ISGA::UserClassConfiguration->query(UserClass => $user_class)};
  
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
      TITLE => 'User Class Configuration',
      sub => \@sub,
     },
     {
      templ => 'hidden',
      NAME => 'user_class',
      VALUE => $user_class
     }
    );

  $form->conf( { ACTION => '/submit/UserClassConfiguration/Edit',
		 FORMNAME => 'userclass_configuration_edit',
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
