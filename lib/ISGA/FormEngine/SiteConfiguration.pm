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

=item public hashref form AddUnixEnvironment();

Build a FormEngine object for adding a new unix environment.

=cut
#------------------------------------------------------------------------
sub AddUnixEnvironment {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form = 
    (
     {
      templ => 'fieldset',
      TITLE => 'Common Environment Parameters',
      sub =>
      [
       { 
	NAME => 'name',
	TITLE => 'Name',
	SIZE => 20,
	MAXLEN => 20,
	REQUIRED => 1,
	HINT => 'A unique name to identify the environment',
	ERROR => ['not_null', 'Text::checkHTML'],
       },
       { 
	NAME => 'path',
	TITLE => 'Working Directory',
	SIZE => 60,
	MAXLEN => 100,
	REQUIRED => 1,
	HINT => 'The base working directory for jobs executed in this environment',
	ERROR => ['not_null', 'Text::checkUnixFilePath'],
       },
       { 
	NAME => 'shell',
	TITLE => 'Shell',
	SIZE => 60,
	MAXLEN => 60,
	VALUE => '/bin/bash',
	REQUIRED => 1,
	HINT => 'The shell used to execute jobs in this environment',
	ERROR => ['not_null', 'Text::checkUnixFilePath'],
       },
      ],
     },
     {
      templ => 'fieldset',
      TITLE => 'Unix Environment Parameters',
      sub =>
      [
       {
	NAME => 'nice',
	TITLE => 'Nice Level',
	SIZE => 3,
	MAXLEN => 3,
	REQUIRED => 1,
	HINT => 'Nice level at which jobs are executed',
	ERROR => ['not_null', 'Number::isNumber'],
       }
      ],
     }
    );
  
  $form->conf( { ACTION => '/submit/SiteConfiguration/AddUnixEnvironment',
		 FORMNAME => 'site_configuration_add_unix_environment',
		 SUBMIT => 'Save Changes',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form AddSGEEnvironment();

Build a FormEngine object for adding a new unix environment.

=cut
#------------------------------------------------------------------------
sub AddSGEEnvironment {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form = 
    (
     {
      templ => 'fieldset',
      TITLE => 'Common Environment Parameters',
      sub =>
      [
       { 
	NAME => 'name',
	TITLE => 'Name',
	SIZE => 20,
	MAXLEN => 20,
	REQUIRED => 1,
	HINT => 'A unique name to identify the environment',
	ERROR => ['not_null', 'Text::checkHTML'],
       },
       { 
	NAME => 'path',
	TITLE => 'Working Directory',
	SIZE => 60,
	MAXLEN => 100,
	REQUIRED => 1,
	HINT => 'The base working directory for jobs executed in this environment',
	ERROR => ['not_null', 'Text::checkUnixFilePath'],
       },
       { 
	NAME => 'shell',
	TITLE => 'Shell',
	SIZE => 60,
	MAXLEN => 60,
	VALUE => '/bin/bash',
	REQUIRED => 1,
	HINT => 'The shell used to execute jobs in this environment',
	ERROR => ['not_null', 'Text::checkUnixFilePath'],
       },
      ],
     },
     {
      templ => 'fieldset',
      TITLE => 'SGE Environment Parameters',
      sub =>
      [
       { 
	NAME => 'executable_path',
	TITLE => 'SGE Executable Path',
	SIZE => 60,
	MAXLEN => 100,
	REQUIRED => 1,
	HINT => 'The path to SGE executables',
	ERROR => ['not_null', 'Text::checkUnixFilePath'],
       },
       { 
	NAME => 'root',
	TITLE => 'SGE Root Directory',
	SIZE => 60,
	MAXLEN => 100,
	REQUIRED => 1,
	HINT => 'The path to SGE root',
	ERROR => ['not_null', 'Text::checkUnixFilePath'],
       },
       { 
	NAME => 'cell',
	TITLE => 'Cell',
	SIZE => 20,
	MAXLEN => 20,
	REQUIRED => 1,
	HINT => 'The SGE cell name',
	ERROR => ['not_null', 'Text::checkHTML'],
       },
       {
	NAME => 'queue',
	TITLE => 'Queue',
	SIZE => 20,
	MAXLEN => 20,
	REQUIRED => 1,
	HINT => 'The SGE queue name',
	ERROR => ['not_null', 'Text::checkHTML'],
       },
       {
	NAME => 'execd',
	TITLE => 'Execd Port',
	SIZE => 5,
	MAXLEN => 5,
	REQUIRED => 1,
	HINT => 'The SGE execd port number',
	ERROR => ['not_null', 'digitonly'],
       },
       {
	NAME => 'qmaster',
	TITLE => 'Qmaster Port',
	SIZE => 5,
	MAXLEN => 5,
	REQUIRED => 1,
	HINT => 'The SGE qmaster port number',
	ERROR => ['not_null', 'digitonly'],
       },
      ],
     }
    );
  
  $form->conf( { ACTION => '/submit/SiteConfiguration/AddSGEEnvironment',
		 FORMNAME => 'site_configuration_add_sge_environment',
		 SUBMIT => 'Save Changes',
		 sub => \@form } );

  $form->make;
  return $form;
}

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
