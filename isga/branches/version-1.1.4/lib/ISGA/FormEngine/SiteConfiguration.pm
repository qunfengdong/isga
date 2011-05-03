package ISGA::FormEngine::SiteConfiguration;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::SiteConfiguration - provide site configuration forms.

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

Build a FormEngine object to edit site configuration.

=cut
#------------------------------------------------------------------------
sub Edit {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @sub;

  # should be small enough for a slow sort
  my @sorted = 
    sort { $a->[0]->getName cmp $b->[0]->getName }
      map { [ $_->getVariable, $_ ] } @{ISGA::SiteConfiguration->query()};
  
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
      TITLE => 'Site Configuration',
      sub => \@sub,
     }
    );

  $form->conf( { ACTION => '/submit/SiteConfiguration/Edit',
		 FORMNAME => 'site_configuration_edit',
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
