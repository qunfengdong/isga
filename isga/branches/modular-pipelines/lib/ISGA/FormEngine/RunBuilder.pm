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
  my $pipeline_input = $args->{pipeline_input};
  my $pipeline = $run_builder->getPipeline;

  my $type = $pipeline_input->getType;
  my $format = $pipeline_input->getFormat;
  my $account = ISGA::Login->getAccount;
  
  my @files = 
    sort { $a->[0] cmp $b->[0] }
      map { [ $_->getUserName, $_ ] }
	@{ISGA::File->query( CreatedBy => $account, Type => $type, Format => $format )};

  my ( $rbi ) = @{ISGA::RunBuilderInput->query( PipelineInput => $pipeline_input, 
						    RunBuilder => $run_builder)};

  my $selected = [];

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
        HIDEDIV => 1,
       },
       {
        templ   => 'upload',
        NAME    => 'file_name',
        TITLE   => 'File',
        ERROR   => ['Text::checkHTML', 'File::isUniqueName'],
        SHOWDIV => 1,
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
  
  $form->conf( { ACTION => '/submit/RunBuilder/SelectInputList',
		 FORMNAME => 'run_builder_select_input_list',
                 ENCTYPE => 'multipart/form-data',
		 SUBMIT => 'Save',
                 CANCEL => '',
                 TOGGLELINK => 'Select Previously Uploaded File',
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
  my $pipeline_input = $args->{pipeline_input};
  my $pipeline = $run_builder->getPipeline;

  my $type = $pipeline_input->getType;
  my $format = $pipeline_input->getFormat;
  my $account = ISGA::Login->getAccount;
  
  my @files = 
    sort { $a->[0] cmp $b->[0] }
      map { [ $_->getUserName, $_ ] }
	@{ISGA::File->query( CreatedBy => $account, Type => $type, Format => $format )};

  my ( $rbi ) = @{ISGA::RunBuilderInput->query( PipelineInput => $pipeline_input, 
						    RunBuilder => $run_builder)};

  my $selected = [];

  if ( my $current_file = $rbi && $rbi->getFileResource ) {
    $selected = [ $current_file ];
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
       }
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
  
  $form->conf( { ACTION => '/submit/RunBuilder/SelectInputList',
		 FORMNAME => 'run_builder_select_input_list',
		 SUBMIT => 'Save',
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
	ERROR => ['not_null', 'Text::checkHTML', 'RunBuilder::isUniqueName'],
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
  my $id_root = $run_builder->getName;
  $id_root =~ s/\s/_/g;
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
        { templ => 'hidden',
          NAME => 'project_id_root',
          VALUE => $id_root
        };
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
