## no critic
# we turn off perl critic because we package doesn't match file
package ISGA::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

ISGA::WebApp manages the interface to MASON for ISGA.

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

=item public void Create();

Method to Create a new pipeline builder

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::Create {

  my $self = shift;
  
  # I need this!
  my $pipeline = $self->args->{pipeline};

  # get user
  my $account = ISGA::Login->getAccount;

  $pipeline->hasPipelineBuilder or
    X::User::Denied->throw( error => "This pipeline has no customizable features or parameters.  Please run this pipeline using default settings." );

  # make sure pipeline status is something we can run
  $pipeline->getStatus->isAvailable or
    X::User::Denied->throw( error => "This pipeline is no longer available to be configured. A newer version of the pipeline may be available." );

  # confirm availability
  ISGA::PipelineConfiguration->value('access_permitted', Pipeline => $pipeline->getGlobalTemplate, UserClass => $account->getUserClass) or
      X::User::Denied->throw( error => 'Your user class is not able to configure this pipeline.' );


  if (my @started_builder = @{ISGA::PipelineBuilder->query( Pipeline => $pipeline,
                                                            CreatedBy => $account,
                                                            OrderBy => 'StartedOn' )} ){
    my $sb = pop(@started_builder);
    $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$sb" );
  }

  # count runs
  my $pipelines = ISGA::UserPipeline->exists( CreatedBy => $account );
  $pipelines++;
  my $runs = ISGA::Run->exists( CreatedBy => $account, Type => $pipeline );
  $runs++;

  my $pipeline_name = $account->getEmailUsername;

  my $default_name = length($pipeline_name) > (39 - length(" Pipeline $pipelines Run $runs")) ? substr($pipeline_name, 0, 39 - length(" Pipeline $pipelines Run $runs")) . " Pipeline $pipelines" : $pipeline_name . " Pipeline $pipelines";

  while( ISGA::UserPipeline->exists( Name => $default_name, CreatedBy => ISGA::Login->getAccount ) ||
         ISGA::PipelineBuilder->exists( Name => $default_name, CreatedBy => ISGA::Login->getAccount)){
       $pipelines++;
       $default_name = length($pipeline_name) > (39 - length(" Pipeline $pipelines")) ? substr($pipeline_name, 0, 39 - length(" Pipeline $pipelines")) . " Pipeline $pipelines" : $pipeline_name . " Pipeline $pipelines";

  }

  my $pipeline_template;

  my $parameter_mask;
  if ( $pipeline->isa( 'ISGA::UserPipeline' ) ) {
    $pipeline_template = $pipeline->getGlobalTemplate;
    $parameter_mask = $pipeline->getParameterMask;

  }else{
    $pipeline_template = $pipeline;
    $parameter_mask = '';
  }

  $pipeline_template->getStatus->isAvailable or
    X::User::Denied->throw( error => "This pipeline is no longer available to be run. A newer version of the pipeline may be available." );

  my %form_args =
    (
     Pipeline => $pipeline_template,
     CreatedBy => $account,
     Name => $default_name,
     ParameterMask => $parameter_mask,
     StartedOn => ISGA::Date->new(),
     Description => '',
    );

    if ( my $wf_mask = $pipeline->getRawWorkflowMask ) {
      $form_args{WorkflowMask} = $wf_mask;
    }

    my $builder = ISGA::PipelineBuilder->create(%form_args);
    $self->redirect
      ( uri => "/PipelineBuilder/Overview?pipeline_builder=$builder" );
}

#------------------------------------------------------------------------

=item public void EditDetails();

Method to edit the details for a pipeline builder

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::EditDetails {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::PipelineBuilder->EditDetails($web_args);
  
  my $pipeline_builder = $web_args->{pipeline_builder};

  if ($form->canceled( )) {

    $self->redirect( 
     uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" 
		   );
  }

  if ( $form->ok ) {

    my %form_args =
      ( 
       Name => $form->get_input('name'),
       Description => $form->get_input('description')
      );

    $pipeline_builder->edit( %form_args );

    $self->redirect
      ( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
  }
  
  $self->_save_arg( 'form', $form);
  warn "about to die on redirect";
  $self->redirect( uri => "/PipelineBuilder/EditDetails?pipeline_builder=$pipeline_builder" );
}

sub Exception::PipelineBuilder::EditDetails {

}

#------------------------------------------------------------------------

=item public void Finalize();

Confirms all the settings in a pipelinebuilder, building a pipeline.

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::Finalize {

  my $self = shift;
  my $pipeline_builder = $self->args->{pipeline_builder};

  # figure out our template
  my $template = $pipeline_builder->getPipeline;
  $template->isa('ISGA::GlobalPipeline') or
    $template = $template->getTemplate;

  # 1: create the pipeline
  my $pipeline = ISGA::UserPipeline->create
    (
     Name => $pipeline_builder->getName,
     WorkflowMask => $pipeline_builder->getRawWorkflowMask,
     ParameterMask => $pipeline_builder->getRawParameterMask,
     Status => ISGA::PipelineStatus->new( Name => 'Available' ),
     Template => $template,
     Description => $pipeline_builder->getDescription,
     CreatedBy => $pipeline_builder->getCreatedBy,
     CreatedAt => ISGA::Timestamp->new(),
    );


  # 2: calculate input requirements
  foreach ( grep { $_->getDependency ne 'Internal Only' } @{$pipeline_builder->getInputs} ) {

    ISGA::PipelineInput->create( Pipeline => $pipeline,
				 ClusterInput => $_,
			       );
  }

  # 3: delete the pipeline builder
  $pipeline_builder->delete();

  $self->redirect( uri => "/PipelineBuilder/Success?pipeline=$pipeline" );
}

#------------------------------------------------------------------------

=item public void EditComponent();

Saves component parameter changes

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::EditComponent {

  my $self = shift;
  my $web_args = $self->args;
  my $pipeline_builder = $web_args->{pipeline_builder};
  my $component = $web_args->{component};

  my $form = ISGA::FormEngine::PipelineBuilder->EditComponent($web_args);

  # look into optimizing this to use session
  my $component_builder = $pipeline_builder->getComponentBuilder($component);

  if ($form->canceled( )) {
    $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
  }

  if ( $form->ok ) {

    # load parameter mask and get a link into our cluster
    my $parameter_mask = $pipeline_builder->getParameterMask();
    my $mask_params = exists $parameter_mask->{ Component }->{ $component } ? $parameter_mask->{ Component }->{ $component } : {};

    my %current_values;
    # loop through all parameters
    foreach my $value ( @{$component_builder->getParameters} ) {

      my $key = $value->{NAME};

      # save default value
      $current_values{ $key } = ( exists $value->{VALUE} ? $value->{VALUE} : undef );

      exists $mask_params->{ $key } and $current_values{$key} = $mask_params->{$key}{Value};

      if (! exists $web_args->{$key} and exists $value->{VALUE} ){
        if ( ! exists $mask_params->{$key} ) {
          $mask_params->{$key} = { Description => '' };
        }
        $mask_params->{$key}{Value} = undef;
        $mask_params->{$key}{Title} = "$value->{COMPONENT} $value->{TITLE}";

      # if the value doesn't exist, delete it from the mask
      }elsif ( ! defined $web_args->{$key} or $web_args->{$key} eq '' ){
	exists $mask_params->{$key} and delete $mask_params->{$key};

      # if the supplied value is different then save it in the mask
      } elsif ( ! defined($current_values{$key}) or $current_values{$key} ne $web_args->{$key} ) {
	if ( ! exists $mask_params->{$key} ) {
	  $mask_params->{$key} = { Description => '' };
	}
	$mask_params->{$key}{Value} = $web_args->{$key};
        $mask_params->{$key}{Title} = "$value->{COMPONENT} $value->{TITLE}";
      }

    }
    
    keys %$mask_params and $parameter_mask->{ Component }->{ $component } = $mask_params;

    $pipeline_builder->edit( ParameterMask => $parameter_mask );
    if (keys %$mask_params){
      $self->redirect( uri => "/PipelineBuilder/AnnotateCluster?pipeline_builder=$pipeline_builder&component=$component" );
    } else {
#      my $cluster = $component->getCluster;
      $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
   }

  }
  # bounce!!!!!
     $self->_save_arg( 'form', $form);
     $self->redirect( uri => "/PipelineBuilder/EditComponent?pipeline_builder=$pipeline_builder&component=$component" );

}

#------------------------------------------------------------------------
 
=item public void EditWorkflow();

Method to save changes to a pipeline workflow.

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::EditWorkflow {

  my $self = shift;
  
  my $pipeline_builder = $self->args->{pipeline_builder};
  my $cluster = $self->args->{cluster};

  # make sure this isn't a required cluster
  my $workflow = ISGA::Workflow->new( Pipeline => $pipeline_builder->getPipeline, Cluster => $cluster );
  $workflow->isRequired and X::API->throw( message => "Can not toggle a required cluster" );
  my $wf_mask = $pipeline_builder->getWorkflowMask();

  if ( $wf_mask->isActive($cluster) ) {
    $wf_mask->disableCluster($cluster);
  } else {
    $wf_mask->enableCluster($cluster);
  }
  
  $pipeline_builder->edit( WorkflowMask => $wf_mask );
  $self->redirect( uri => "/Success");
}

#------------------------------------------------------------------------

=item public void AnnotateCluster();

Saves cluster parameter change notes

=cut
#------------------------------------------------------------------------

sub PipelineBuilder::AnnotateCluster {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::PipelineBuilder->AnnotateCluster($web_args);

  my $pipeline_builder = $web_args->{pipeline_builder};
  my $component = $web_args->{component};
  my $cluster = $component->getCluster;
  if ($form->canceled( )) {

    $self->redirect(
     uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder"
                   );
  }

  
  if ( $form->ok ) {

    # load parameter mask and get a link into our cluster
    my $parameter_mask = $pipeline_builder->getParameterMask();
    my $mask_params = $parameter_mask->{ Component }->{ $component };

    # loop through web arguments
    while ( my ($key, $value) = each %$web_args ) {

        if ( $key =~ /(\S+)_comment$/ ) {
          $mask_params->{$1}{Description} = $value;
        }
    }

    keys %$mask_params and $parameter_mask->{ Component }->{ $component } = $mask_params;

    $pipeline_builder->edit( ParameterMask => $parameter_mask );

    $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
#    $self->redirect( uri => "/PipelineBuilder/EditCluster?pipeline_builder=$pipeline_builder&cluster=$cluster" );

  }

  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
}

#------------------------------------------------------------------------

=item public void Remove();

Cancels and removes a PipelineBuilder

=cut

#------------------------------------------------------------------------
sub PipelineBuilder::Remove {
  my $self = shift;
  my $pipeline_builder = $self->args->{pipeline_builder};

  my $template = $pipeline_builder->getPipeline;

  #Remove Pipeline Builder from database
  $pipeline_builder->delete();
  my $redirect;
  if( defined $self->args->{redirect} ){
    $redirect =  $self->args->{redirect};
  } else{
    $redirect =  "/Pipeline/View?pipeline=$template";
  }
  $self->redirect( uri => "$redirect" );

}

#------------------------------------------------------------------------

=item public void ChooseComponent();

Processes optional components so only user selected are run

=cut

#------------------------------------------------------------------------
sub PipelineBuilder::ChooseComponent {

  my $self = shift;

  my $web_args = $self->args;
  my $form = ISGA::FormEngine::PipelineBuilder->ChooseComponent($web_args);

  my $pipeline_builder = $self->args->{pipeline_builder};
  my $cluster = $self->args->{cluster};

  # if the form is canceled return to the overview
  if ($form->canceled( )) {
    $self->redirect(uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder");
  }

  if ( $form->ok ) {
    my $wf_mask = $pipeline_builder->getWorkflowMask;  

    # make a lookup hash of enabled components
    my %enabled;
    if ( exists $web_args->{component} ) {
      ref($web_args->{component}) eq 'ARRAY' or $web_args->{component} = [ $web_args->{component} ];
      $enabled{$_} = $_ for @{$web_args->{component}};
      $wf_mask->enableCluster($cluster);

    # if we don't have any components let's disable the cluster
    } else { $wf_mask->disableCluster($cluster); }

    # cycle through all tier one components in the cluster and look for those whose status has changed
    foreach my $component ( grep { ! defined $_->getDependsOn } @{ISGA::Component->query( Cluster => $cluster )} ) {
      
      my $is_active = $wf_mask->isActive($component);

      if ( $is_active and ! exists $enabled{$component} ) {
	$wf_mask->disableComponent($component);
	
      } elsif ( exists $enabled{$component} and ! $is_active ) {
	$wf_mask->enableComponent($component);
      }
    }

    # success, now we return
    $pipeline_builder->edit( WorkflowMask => $wf_mask );
    $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
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
