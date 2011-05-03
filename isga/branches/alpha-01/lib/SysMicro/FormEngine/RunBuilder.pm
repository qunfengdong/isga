package SysMicro::FormEngine::RunBuilder;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::RunBuilder - provide forms for building runs.

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

=item public hashref form Create();

Build a FormEngine object for creating customized pipelines.

=cut
#------------------------------------------------------------------------
sub Create {

  my ($class, $args) = @_;

  my $pipeline = $args->{pipeline};

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub => 
      [
       {
	NAME => 'name',
	TITLE => 'Run Name',
	REQUIRED => 1,
	LABEL => 'name',
	ERROR => ['not_null','Text::checkHTML'], 
       },
       {
	templ => 'print',
	TITLE => 'Pipeline',
	LABEL => 'pipeline_print',
	HINT  => 'The pipeline your are running',
	VALUE => $pipeline->getName,
       },
       {
	templ => 'print',
	TITLE => 'Created By',
	LABEL => 'created_by_print',
	VALUE => SysMicro::Login->getAccount->getName,
       },
      ],
     },
     
     {
      templ => 'fieldset',
      TITLE => 'Optional Parameters',
      sub => 
      [
       {
	templ => 'textarea',
	NAME  => 'description',
	TITLE => 'Description',
	LABEL => 'description',
	ERROR => 'Text::checkHTML',
	HINT  => 'Optional Description to be stored with the run',
       },
      ],
     },

     {
      templ => 'hidden',
      NAME => 'pipeline',
      VALUE => $pipeline,
     },

    );

  $form->conf( { ACTION => '/submit/RunBuilder/Create',
		 FORMNAME => 'run_builder_create',
		 SUBMIT => 'Continue',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form EditDetails();

Build a FormEngine object for editing the details on customized pipelines.

=cut
#------------------------------------------------------------------------
sub EditDetails {

  my ($class, $args) = @_;

  my $rBuilder = $args->{run_builder};

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub => 
      [
       {
	NAME => 'name',
	TITLE => 'Run Name',
	REQUIRED => 1,
	LABEL => 'name',
	ERROR => ['not_null', 'Text::checkHTML'],
	VALUE => $rBuilder->getName,
       },
      ],
     },
     
     {
      templ => 'fieldset',
      TITLE => 'Optional Parameters',
      sub => 
      [
       {
	templ => 'textarea',
	NAME  => 'description',
	TITLE => 'Description',
	LABEL => 'description',
	ERROR => 'Text::checkHTML',
	VALUE => $rBuilder->getDescription,
       },
      ],
     },

     {
      templ => 'hidden',
      NAME => 'run_builder',
      VALUE => $rBuilder,
     },

    );

  $form->conf( { ACTION => '/submit/RunBuilder/EditDetails',
		 FORMNAME => 'run_builder_edit_details',
		 SUBMIT => 'Save',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form UploadFile();

Build a FormEngine object for uploading a file for a run.
pipeline run.

=cut
#------------------------------------------------------------------------
sub UploadFile {

  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  my $run_builder = $args->{run_builder};

  my @files = @{SysMicro::PipelineInput->query( Pipeline => $run_builder->getPipeline )};

  @files = sort { $a->[0] cmp $b->[0] } 
    map {  [ $_->getType->getName . ' - ' . $_->getFormat->getName, $_ ] } @files;

  my @form = 
    (
     { 
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub => 
      [
       {
	templ => 'select',
	NAME => 'pipeline_input',
	TITLE => 'File Type',
	SIZE => 1,
	OPTION => ['Select a file type...', map { $_->[0] } @files ],
	OPT_VAL => [undef, map { $_->[1] } @files ],
	ERROR => 'not_null',
       },
       {
	templ   => 'upload',
	NAME    => 'file_name',
	TITLE   => 'File',
	ERROR   => ['not_null', 'Text::checkHTML'],
       },
      ]
     },
     {
      templ => 'hidden',
      NAME => 'run_builder',
      VALUE => $run_builder,
     },
     
    );
  
  $form->conf( { ACTION => '/submit/RunBuilder/UploadFile',
		 FORMNAME => 'run_builder_upload_file',
                 ENCTYPE => 'multipart/form-data',
		 SUBMIT => 'Upload File',
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
