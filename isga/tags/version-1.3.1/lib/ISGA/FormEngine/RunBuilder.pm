package ISGA::FormEngine::RunBuilder;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::RunBuilder - provide forms for building runs.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use List::Util qw(min);

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public hashref form SelectInputList();

Build a FormEngine object for editing the run builder parameters on customized pipelines.

=cut
#------------------------------------------------------------------------
sub SelectInputList {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $run_builder = $args->{run_builder};
  my $rbi = exists $args->{run_builder_input} ? $args->{run_builder_input} : undef;
  my $pipeline_input = ( $rbi ? $rbi->getPipelineInput : $args->{pipeline_input} );
  my $pipeline = $run_builder->getPipeline;

  my $type = $pipeline_input->getType;
  my $format = $pipeline_input->getFormat;
  my $account = ISGA::Login->getAccount;
  
  # retrieve user files of this type and format
  my @files = 
    sort { $a->[0] cmp $b->[0] }
      map { [ $_->getUserName, $_ ] }
	@{ISGA::File->query( CreatedBy => $account, Type => $type, Format => $format, IsHidden => 0 )};

  my $selected = [];

  # check to see if there is a defined rbi and use it's resource as the currently selected files.
  if ( my $current_file = $rbi && $rbi->getFileResource ) {
    $selected = $current_file->getFlattenedContents;
  }

  my @form = 
    (
     {
      templ => 'fieldset',
      TITLE => 'Select Input',
      sub => 
      [
       {
	templ => 'print',
	TITLE => 'File Type',
	VALUE => $type->getName,
       },
       {
	templ => 'print',
	TITLE => 'File Format',
	VALUE => $format->getName,
       },
       {
	templ => 'select',
	NAME => 'file',
	MULTIPLE => 1,
	TITLE => 'Compatible Files',
	SIZE  => min( scalar(@files), 8),
	OPTION => [map { $_->[0] } @files ],
	OPT_VAL => [map { $_->[1] } @files ],	
	VALUE => $selected,
	HINT => 'Hold the ctrl key to select multiple files.',
	ERROR => ['RunBuilder::isFileProvided'],
       },
      ],
     },
     {
      templ => 'hidden',
      NAME => 'run_builder',
      VALUE => $run_builder,
     },
     {
      templ => 'hidden',
      NAME => 'pipeline_input',
      VALUE => $pipeline_input,
     },

    );

  if ( $rbi ) {
    push @form, {templ => 'hidden', NAME => 'run_builder_input', VALUE => $rbi};
  }


  # check for parameters
  if ( $pipeline_input->hasParameters ) {
    push @form, ( $rbi ? $rbi->getForm : $pipeline_input->getForm );

    for ( @{$pipeline_input->getComponents} ) {
      push @form, { templ => 'hidden', NAME => 'component', VALUE => $_ };
    }
  }
  
  $form->conf( { ACTION => '/submit/RunBuilder/SelectInputList',
		 FORMNAME => 'run_builder_select_input_list',
		 SUBMIT => 'Save',
                 CANCEL => '',
                 UPLOADBUTTON => 'Upload File',
		 sub => \@form } );
  $form->make;
  return $form;
} 

#------------------------------------------------------------------------

=item public hashref form SelectInputList();

Build a FormEngine object for editing the run builder parameters on customized pipelines.

=cut
#------------------------------------------------------------------------
sub UploadInput {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $run_builder = $args->{run_builder};
  my $pipeline_input = ( $args->{pipeline_input} );
  my $pipeline = $run_builder->getPipeline;

  my $type = $pipeline_input->getType;
  my $format = $pipeline_input->getFormat;
  my $account = ISGA::Login->getAccount;
  
  my %sample_link = ( 'User ORF Prediction Raw Evidence' => 'Please be sure your ORF Prediciton Input has the same header as your FASTA input.<br><a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/sample_data.predict">Download Sample Data</a>',
                      'Genome Sequence' => '<a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/sample_data.fna">Download Sample Data</a>',
                      'Native 454 format' => '<a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/Typhi_E017866_454_1.sff">Download Sample Data</a>');

  my $sample_data = $sample_link{$type->getName};
  my $selected = [];

  my @form = 
    (
     {
      templ => 'fieldset',
      TITLE => 'Upload File',
      sub => 
      [

       {
	templ => 'print',
	TITLE => 'File Type',
	VALUE => $type->getName,
       },
       {
	templ => 'print',
	TITLE => 'File Format',
	VALUE => $format->getName,
       },
       {
        templ   => 'upload',
        NAME    => 'file_name',
        TITLE   => 'Upload File',
        HINT    => "Files larger than ". ISGA::SiteConfiguration->value('upload_size_limit'). "MB must be supplied via URL.<br>$sample_data",
        ERROR   => ['Text::checkHTML', 'File::isUniqueName', 'RunBuilder::isFileProvided'],
        SHOWDIV => 1,
       },

       {
	NAME  => 'upload_url',
	TITLE => 'File URL',
	HINT  => 'For large files you can supply a URL where the file is available and ISGA will dowload the file.',
	ERROR => ['Text::checkHTML', 'RunBuilder::isValidUploadURL'],
       },

       {
	NAME  => 'new_file_name',
	TITLE => 'New File Name',
	HINT  => '(Optional) Specify a different name for the file you are uploading',
	ERROR => ['Text::checkHTML'],
       },

       {
        templ => 'textarea',
        NAME  => 'description',
        TITLE => 'Description',
        LABEL => 'description',
        ROWS => ' " style="height: 3em;"',
        ERROR => 'Text::checkHTML',
       },
      ],
     },
     {
      templ => 'hidden',
      NAME => 'run_builder',
      VALUE => $run_builder,
     },
     {
      templ => 'hidden',
      NAME => 'pipeline_input',
      VALUE => $pipeline_input,
     },

    );

  $form->conf( { ACTION => '/submit/RunBuilder/UploadInput',
		 FORMNAME => 'run_builder_upload_input',
		 FORMATTR => [ 'onsubmit="return startEmbeddedProgressBar(this)"' ],
                 ENCTYPE => 'multipart/form-data',
		 SUBMIT => 'Save',
                 CANCEL => '',
		 sub => \@form } );


  $form->make;

  return $form;
} 

#------------------------------------------------------------------------

=item public hashref form SelectInput();

Build a FormEngine object for editing the run builder parameters on customized pipelines.

=cut
#------------------------------------------------------------------------
sub SelectInput {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $run_builder = $args->{run_builder};
  my $rbi = exists $args->{run_builder_input} ? $args->{run_builder_input} : undef;
  my $pipeline_input = ( $rbi ? $rbi->getPipelineInput : $args->{pipeline_input} );
  my $pipeline = $run_builder->getPipeline;
  
  my $type = $pipeline_input->getType;
  my $format = $pipeline_input->getFormat;
  my $account = ISGA::Login->getAccount;
  
  # retrieve user files of this type and format
  my @files = 
    sort { $a->[0] cmp $b->[0] }
      map { [ $_->getUserName, $_ ] }
	@{ISGA::File->query( CreatedBy => $account, Type => $type, Format => $format, IsHidden => 0 )}; 

  my $selected = undef;

  # check to see if there is a defined rbi and use it's resource as the currently selected files.
  if ( my $current_file = $rbi && $rbi->getFileResource ) {
    $selected = $current_file;
  }

  my @form = 
    (
     {
      templ => 'fieldset',
      TITLE => 'Select Input',
      sub => 
      [
       {
	templ => 'print',
	TITLE => 'File Type',
	VALUE => $type->getName,
       },
       {
	templ => 'print',
	TITLE => 'File Format',
	VALUE => $format->getName,
       },
       {
        templ => 'select',
        NAME => 'file',
        TITLE => 'Compatible Files',
        SIZE  => min( scalar(@files), 8),
        OPTION => [map { $_->[0] } @files ],
        OPT_VAL => [map { $_->[1] } @files ],
        VALUE => $selected,
        HINT => 'Hold the ctrl key to select multiple files.',
        ERROR => ['RunBuilder::isFileProvided'],
       },
      ],
     },
     {
      templ => 'hidden',
      NAME => 'run_builder',
      VALUE => $run_builder,
     },
     {
      templ => 'hidden',
      NAME => 'pipeline_input',
      VALUE => $pipeline_input,
     },

    );
  
  if ( $rbi ) {
    push @form, { templ => 'hidden',  NAME => 'run_builder_input', VALUE => $rbi };
  }

  # check for parameters
  if ( $pipeline_input->hasParameters ) {
    push @form, ( $rbi ? $rbi->getForm : $pipeline_input->getForm );

    for ( @{$pipeline_input->getComponents} ) {
      push @form, { templ => 'hidden', NAME => 'component', VALUE => $_ };
    }
  }

  $form->conf( { ACTION => '/submit/RunBuilder/SelectInput',
                 FORMNAME => 'run_builder_select_input',
                 SUBMIT => 'Save',
                 CANCEL => '',
                 UPLOADBUTTON => 'Upload File',
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

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

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
	ERROR => ['not_null', 'Text::checkHTML', 'Text::checkUnixFileName',
		  'RunBuilder::isUniqueName'],
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

=item public hashref form EditParameters();

Build a FormEngine object for editing the run builder parameters on customized pipelines.

=cut
#------------------------------------------------------------------------
sub EditParameters {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $run_builder = $args->{run_builder};
  my $pipeline = $run_builder->getPipeline;
  my $components = $pipeline->getComponents;
  my $parameter_mask = $run_builder->getParameterMask;
  
  my @form;

  my @hidden;

  for ( grep { $pipeline->getComponentBuilder($_) } @$components ) {
    
    my $run_builder_form = $pipeline->getComponentBuilder($_, $parameter_mask)->getRunBuilderForm();

    if ( $run_builder_form ) {
      push @form, $run_builder_form;
      push @hidden, 
	{ templ => 'hidden',
	  NAME => 'component',
	  VALUE => $_
	},
      }
  }

  push @form, @hidden, 
    {
     templ => 'hidden',
     NAME => 'run_builder',
     VALUE => $run_builder,
    };

  $form->conf( { ACTION => '/submit/RunBuilder/EditParameters',
		 FORMNAME => 'run_builder_edit_parameters',
		 SUBMIT => 'Save',
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
