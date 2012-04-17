package ISGA::FormEngine::PipelineBuilder;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::PipelineBuilder - provide forms for customizing pipelines.

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

=item public hashref form EditDetails();

Build a FormEngine object for editing the details on customized pipelines.

=cut
#------------------------------------------------------------------------
sub EditDetails {

  my ($class, $args) = @_;

  my $pBuilder = $args->{pipeline_builder};

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
	TITLE => 'Pipeline Name',
	REQUIRED => 1,
	LABEL => 'name',
        MAXLEN => 32,
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
  my $component_builder = $pipeline_builder->getComponentBuilder($component);
  my $form_params = [ $component_builder->getForm() ];

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

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

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');
  
  my $component = $args->{component};

  my $pipeline_builder = $args->{pipeline_builder};
  my $component_builder = $pipeline_builder->getComponentBuilder($component);
  my $parameter_mask = $pipeline_builder->getParameterMask();
  my @form = ({templ => 'fieldset', TITLE => 'Altered Parameters', sub => []});  

  # should check for an empty mask and show something else
  while ( my ($key, $value) = each %{$parameter_mask->{ Component }->{ $component }} ) {

    push(@{${$form[0]}{sub}}, ({'NAME' => $key,
			        'templ' => 'print',
				'TITLE' => $$value{Title},
				'LABEL' => $key,
				'VALUE' => ( defined $value->{Value} ? $value->{Value} : 'Disabled' )},
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
  my $components = ISGA::Component->query( Cluster => $cluster, OrderBy => 'Index', DependsOn => undef, Name => {'NOT NULL' => undef});
  my $wf_mask = $pBuilder->getWorkflowMask();
  
  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinTable');

  my @form;
  my $check_class = $cluster->getName;
  $check_class =~ s/ /_/g;

  foreach my $component ( @{$components} ) {
   
    push @form, $class->_addComponentToForm($check_class, $pBuilder, $component);
    
    foreach ( @{ISGA::Component->query( Cluster => $cluster, DependsOn => $component, OrderBy => 'Index', Name => {'NOT NULL' => undef})} ) {      
      push @form, $class->_addComponentToForm($check_class, $pBuilder, $_);
    }
  }

  my $select_link = "<a onclick=\"\$(\'input[\@type=checkbox].".$check_class."\').attr(\'checked\', \'checked\')\">Select All</a>";
  my $deselect_link = "<a onclick=\"\$(\'input[\@type=checkbox].".$check_class."\').removeAttr(\'checked\')\">Deselect All</a>"; 

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
                 SPECIALCLASS => "left",
                 DIVCLASS => "modaltable",
                 sub => \@form } );

  my $on_off = 'Turn On/Off<br>' . $select_link.' | '.$deselect_link;
  $form->set_main_vars({TITLE => ['Component', 'Edit Parameters', $on_off],
                        CLASS => ['left', 'left', 'centertext'],
                        TITLEALIGN => ['left', 'left', 'center']});


  $form->make;
  return $form;

}

#------------------------------------------------------------------------

=item public hashref form _addComponentToForm(string $check_class, PipelineBuilder $pipeline_builder, Component $component);

Returns a FormEngine row for the component chooser.

=cut
#------------------------------------------------------------------------
sub _addComponentToForm {

  my ($class, $check_class, $pipeline_builder, $component) = @_;

  my $wf_mask = $pipeline_builder->getWorkflowMask();
  my $link = "No Parameters";

  my $b = $pipeline_builder->getComponentBuilder($component);
  $b->{PipelineBuilder} 
    and $link = "<a href=\"/PipelineBuilder/EditComponent?pipeline_builder= $pipeline_builder&component=$component\">Edit</a>";
  
  my $toggle = { templ => 'print', VALUE => ' ', CLASS => 'centertext' };
  my $indentclass = 'indent';
  if ( ! $component->getDependsOn or $component->getDependencyType eq 'Depends On' ) {
    $toggle = { templ => 'check', NAME => 'component', ALIGN => 'right', CLASS => $check_class." centertext", OPT_VAL => $component };
    $wf_mask->isActive($component) and $toggle->{VALUE} = $component;
    $indentclass = undef;
  }
  
  my $entry = {templ => 'data_row',
	       sub => [
		       {templ => 'print',
			ALIGN => 'right',
                        CLASS => $indentclass,
			VALUE => $component->getName},
		       {templ => 'print',
			CLASS => "left",
			VALUE => $link},
                       $toggle,
			]};
  
  return $entry;
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
