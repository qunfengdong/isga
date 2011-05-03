package SysMicro::FormEngine::PipelineBuilder;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::PipelineBuilder - provide forms for customizing pipelines.

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
	TITLE => 'Pipeline Name',
	REQUIRED => 1,
	LABEL => 'name',
	ERROR => ['not_null','Text::checkHTML'], 
       },
       {
	templ => 'print',
	TITLE => 'Template',
	LABEL => 'pipeline_print',
	HINT  => 'The pipeline yours will be derived from',
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
	HINT  => 'Optional Description to be stored with the pipeline',
       },
      ],
     },

     {
      templ => 'hidden',
      NAME => 'pipeline',
      VALUE => $pipeline,
     },

    );

  $form->conf( { ACTION => '/submit/PipelineBuilder/Create',
		 FORMNAME => 'pipeline_builder_create',
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

  my $pBuilder = $args->{pipeline_builder};

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
	TITLE => 'Pipeline Name',
	REQUIRED => 1,
	LABEL => 'name',
	ERROR => ['not_null', 'Text::checkHTML'],
	VALUE => $pBuilder->getName,
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
	VALUE => $pBuilder->getDescription,
       },
      ],
     },

     {
      templ => 'hidden',
      NAME => 'pipeline_builder',
      VALUE => $pBuilder,
     },

    );

  $form->conf( { ACTION => '/submit/PipelineBuilder/EditDetails',
		 FORMNAME => 'pipeline_builder_edit_details',
		 SUBMIT => 'Save',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form EditCluster();

Build a FormEngine object for creating customized pipelines.

=cut
#------------------------------------------------------------------------
sub EditCluster {
  use Data::Dumper;
  my ($class, $args) = @_;
  
  my $pipeline_builder = $args->{pipeline_builder};
  my $cluster = $args->{cluster};

  my $cluster_builder = SysMicro::ClusterBuilder->new($args->{cluster});
  my $form_params = $cluster_builder->injectMaskValues($pipeline_builder, $cluster);

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  push(@{$form_params}, {templ => 'hidden',
                         NAME => 'pipeline_builder',
                         VALUE => $args->{pipeline_builder}});
  push(@{$form_params}, {templ => 'hidden',
                         NAME => 'cluster',
                         VALUE => $args->{cluster}});
  $form->conf( { ACTION => "/submit/PipelineBuilder/EditCluster",
                 FORMNAME => 'cluster_configure',
                 SUBMIT => 'Save Parameters',
                 sub => $form_params } );
  $form->make;
  return $form;
}

#------------------------------------------------------------------------
#
#=item public hashref form AnnotateCluster();
#
#Build a FormEngine object for annotating user changed cluster parameters
#
#=cut
##------------------------------------------------------------------------
sub AnnotateCluster {
  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');
  
  my $cluster = $args->{cluster};

  my $pipeline_builder = $args->{pipeline_builder};
  my $cluster_builder = SysMicro::ClusterBuilder->new($cluster);
  my $parameter_mask = $pipeline_builder->getParameterMask();
  my @form = ({templ => 'fieldset', TITLE => 'Altered Parameters', sub => []});  

  # should check for an empty mask and show something else
  while ( my ($key, $value) = each %{$parameter_mask->{ Cluster }->{ $cluster }} ) {

    push(@{${$form[0]}{sub}}, ({'NAME' => $key,
			        'templ' => 'print',
				'TITLE' => $$value{Title},
				'LABEL' => $key,
				'VALUE' => $$value{Value}},
			       {'templ' => 'textarea',
				'NAME' => $key."_comment",
				'LABEL' => $key."_comment",
				'VALUE' => $$value{Description},
				ERROR => 'Text::checkHTML',
				'TITLE' => 'Annotation',}));
  }
  
  push(@form, ({
                templ => 'hidden',
                NAME => 'pipeline_builder',
                VALUE => $args->{pipeline_builder}
               },
               {
                templ => 'hidden',
                NAME => 'cluster',
                VALUE => $args->{cluster}
               }));  


  $form->conf( { ACTION => "/submit/PipelineBuilder/AnnotateCluster",
                 FORMNAME => 'annotate_cluster',
                 SUBMIT => 'Annotate Parameters',
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
