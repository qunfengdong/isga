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
	ERROR => ['not_null','Text::checkHTML', 'PipelineBuilder::isUniqueName'], 
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

=item public hashref form EditComponent();

Build a FormEngine object for creating customized pipelines.

=cut
#------------------------------------------------------------------------
sub EditComponent {
  my ($class, $args) = @_;
  
  my $pipeline_builder = $args->{pipeline_builder};
  my $component = $args->{component};
  my $parameter_mask = $pipeline_builder->getParameterMask();
  my $component_builder = SysMicro::ComponentBuilder->new($component, $parameter_mask);
  my $form_params = [ $component_builder->getForm() ];

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  push(@{$form_params}, {templ => 'hidden',
                         NAME => 'pipeline_builder',
                         VALUE => $args->{pipeline_builder}});
  push(@{$form_params}, {templ => 'hidden',
                         NAME => 'component',
                         VALUE => $args->{component}});
  
  $form->conf( { ACTION => "/submit/PipelineBuilder/EditComponent",
                 FORMNAME => 'component_configure',
                 SUBMIT => 'Save Parameters',
                 RESET => 'Reset Form',
                 sub => $form_params } );
  $form->make;
  return $form;
}



#------------------------------------------------------------------------

=item public hashref form AnnotateCluster();

Build a FormEngine object for annotating user changed cluster parameters

=cut
#------------------------------------------------------------------------
sub AnnotateCluster {
  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');
  
  my $component = $args->{component};

  my $pipeline_builder = $args->{pipeline_builder};
  my $component_builder = SysMicro::ComponentBuilder->new($component);
  my $parameter_mask = $pipeline_builder->getParameterMask();
  my @form = ({templ => 'fieldset', TITLE => 'Altered Parameters', sub => []});  

  # should check for an empty mask and show something else
  while ( my ($key, $value) = each %{$parameter_mask->{ Component }->{ $component }} ) {

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
				'TITLE' => 'Note',}));
  }
  
  push(@form, ({
                templ => 'hidden',
                NAME => 'pipeline_builder',
                VALUE => $args->{pipeline_builder}
               },
               {
                templ => 'hidden',
                NAME => 'component',
                VALUE => $args->{component}
               }));  


  $form->conf( { ACTION => "/submit/PipelineBuilder/AnnotateCluster",
                 FORMNAME => 'annotate_cluster',
                 SUBMIT => 'Save Notes',
                 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form ChooseComponent();

Build a FormEngine object for choosing optional components.

=cut
#------------------------------------------------------------------------
sub ChooseComponent {
  my ($class, $args) = @_;

  my $pBuilder = $args->{pipeline_builder};
  my $cluster = $args->{cluster};
  my $components = SysMicro::Component->query( Cluster => $cluster );
  my $wf_mask = $pBuilder->getWorkflowMask;
  my $disabled = $wf_mask->getDisabledComponents;
  
  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinTable');

  my @form;
  my $check_class;
  foreach ( @{$components} ) {
    unless( defined $_->getDependsOn ){
      $check_class = $_->getCluster->getName;
      $check_class =~ s/ /_/g;
      my $count = 0;
      my $link = "No Parameters";
      my @dependents = @{SysMicro::Component->query( DependsOn => $_ )};

      foreach my $dep_components (@dependents){
         if (my $builder = SysMicro::ComponentBuilder->new($dep_components)){
           if ( $builder->{PipelineBuilder} ){
               $count++;
               $link = "<a href=\"/PipelineBuilder/EditComponent?pipeline_builder= $pBuilder&component=$dep_components\">Edit</a>";
           }
         }
      }
      my $b = SysMicro::ComponentBuilder->new($_);
      $b->{PipelineBuilder} and $count == 0 and $link = "<a href=\"/PipelineBuilder/EditComponent?pipeline_builder= $pBuilder&component=$_\">Edit</a>";

      if(exists $$disabled{$_->getErgatisName}){
        push(@form,
                    {templ => 'data_row',
                     sub => [
                        {templ => 'print',
                         ALIGN => 'right',
                         VALUE => $_->getName},
                        {templ => 'check',
                         NAME => $_->getErgatisName,
                         ALIGN => 'right',
                         CLASS => $check_class." centertext",
                         OPT_VAL => $_->getErgatisName},
                        {templ => 'print',
                         CLASS => "centertext",
                         VALUE => $link},
                     ]},
                   );
      }else{
        push(@form,
                    {templ => 'data_row',
                     sub => [
                        {templ => 'print',
                         ALIGN => 'right',
                         VALUE => $_->getName},
                        {templ => 'check',
                         NAME => $_->getErgatisName,
                         ALIGN => 'right',
                         CLASS => $check_class." centertext",
                         OPT_VAL => $_->getErgatisName,
                         VALUE => $_->getErgatisName},
                        {templ => 'print',
                         CLASS => "centertext",
                         VALUE => $link},
                     ]},
                   );
      }
    }
  }
  my $select_link = "<a onclick=\"\$(\'input[\@type=checkbox].".$check_class."\').attr(\'checked\', \'checked\')\">Select All</a>";
  my $deselect_link = "<a onclick=\"\$(\'input[\@type=checkbox].".$check_class."\').removeAttr(\'checked\')\">Deselect All</a>"; 

#  push(@form, 
#              {templ => 'data_row',
#               sub => [
#                  {'templ' => 'print',
#                   'VALUE' => ''},
#                  {'NAME' => 'Select All',
#                   'templ' => 'button',
#                   'TYPE' => 'button',
#                   'VALUE' => 'Select All',
#                   'TITLE' => 'Select All',
#                   'ONCLICK' => '$(\'input[@type=checkbox].'.$check_class.'\').attr(\'checked\', \'checked\')',},

#  push(@form,
#              {templ => 'data_row',
#               sub => [
#                  {'NAME' => 'Deselect All',
#                   'templ' => 'button',
#                   'TYPE' => 'button',
#                   'VALUE' => 'Deselect All',
#                   'TITLE' => 'Deselect All',
#                   'ONCLICK' => '$(\'input[@type=checkbox].'.$check_class.'\').removeAttr(\'checked\')',}]});

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
  

  $form->conf( { ACTION => '/submit/PipelineBuilder/ChooseComponent',
                 FORMNAME => $check_class.'_choose_component',
                 SUBMIT => 'Save',
                 CHECKALL => $check_class.'CheckAll',
                 ADDCOLUMN => $select_link.' | '.$deselect_link,
                 SPECIALCLASS => "centertext",
                 DIVCLASS => "modaltable",
                 sub => \@form } );
  $form->set_main_vars({TITLE => ['Component', 'Turn On/Off', 'Edit Parameters'],
                        TITLEALIGN => ['left', 'left', 'left']});


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
