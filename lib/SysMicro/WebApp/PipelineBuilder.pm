## no critic
# we turn off perl critic because we package doesn't match file
package SysMicro::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

SysMicro::WebApp manages the interface to MASON for SysMicro.

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
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::PipelineBuilder->Create($web_args);
  
  if ($form->canceled( )) {

    $self->redirect( uri => "/Pipeline/Overview" );
  }

  if ( $form->ok ) {

    # I need this!
    my $pipeline = $form->get_input('pipeline');

    my %form_args =
      (
       Pipeline => $pipeline,
       CreatedBy => SysMicro::Login->getAccount,
       Name => $form->get_input('name'),
       WorkflowMask => $pipeline->getRawWorkflowMask,
       StartedOn => SysMicro::Date->new(),
      );

    my $description = $form->get_input('description');
    $description and $form_args{Description} = $description;

    my $builder = SysMicro::PipelineBuilder->create(%form_args);
    $self->redirect
      ( uri => "/PipelineBuilder/Overview?pipeline_builder=$builder" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/PipelineBuilder/Create' );
}


sub Exception::PipelineBuilder::Create {

}


#------------------------------------------------------------------------

=item public void EditDetails();

Method to edit the details for a pipeline builder

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::EditDetails {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::PipelineBuilder->EditDetails($web_args);
  
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

=item public void EditWorkflow();

Method to save changes to a pipeline workflow.

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::EditWorkflow {

  my $self = shift;
  
  my $pipeline_builder = $self->args->{pipeline_builder};
  
  my $builder = SysMicro::WorkflowBuilder->restore( $pipeline_builder );
  
  my $workflow_mask = $pipeline_builder->getWorkflowMask();
  $workflow_mask->setStart( $builder->getStart() );
  $workflow_mask->setStop( $builder->getStop() );

  $pipeline_builder->edit( WorkflowMask => $workflow_mask );

  $self->redirect
    ( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder");
}

sub Exception::PipelineBuilder::EditWorkflow {

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
  $template->isa('SysMicro::GlobalPipeline') or
    $template = $template->getTemplate;

  # 1: create the pipeline
  my $pipeline = SysMicro::UserPipeline->create
    (
     Name => $pipeline_builder->getName,
     WorkflowMask => $pipeline_builder->getRawWorkflowMask,
     ParameterMask => $pipeline_builder->getRawParameterMask,
     Status => SysMicro::PipelineStatus->new( Name => 'Available' ),
     Template => $template,
     Description => $pipeline_builder->getDescription,
     CreatedBy => $pipeline_builder->getCreatedBy,
     CreatedAt => SysMicro::Timestamp->new(),
    );

  # 2: calculate input requirements
  foreach ( @{$pipeline_builder->getInputs} ) {

    SysMicro::PipelineInput->create( Dependency => $_->getDependency,
				     Pipeline => $pipeline,
				     Type => $_->getType,
				     Format => $_->getFormat,
				     ClusterInput => $_,
				     ErgatisFormat => $_->getErgatisFormat
				   );
  }

  # 3: delete the pipeline builder
  $pipeline_builder->delete();

  $self->redirect( uri => "/PipelineBuilder/Success?pipeline=$pipeline" );
}

sub Exception::PipelineBuilder::Finalize {
}


#------------------------------------------------------------------------

=item public void EditCluster();

Saves cluster parameter changes

=cut
#------------------------------------------------------------------------
sub PipelineBuilder::EditCluster {
  use Data::Dumper;
  my $self = shift;
  my $web_args = $self->args;
  my $pipeline_builder = $web_args->{pipeline_builder};
  my $cluster = $web_args->{cluster};

  my $form = SysMicro::FormEngine::PipelineBuilder->EditCluster($web_args);

  # look into optimizing this to use session
  my $cluster_builder = SysMicro::ClusterBuilder->new($cluster);

  if ($form->canceled( )) {
    $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
  }

  if ( $form->ok ) {

    # load parameter mask and get a link into our cluster
    my $parameter_mask = $pipeline_builder->getParameterMask();
    my $mask_params = exists $parameter_mask->{ Cluster }->{ $cluster } ? $parameter_mask->{ Cluster }->{ $cluster } : {};

    my %current_values;
    # loop through all parameters
    while ( my ($key, $value) = each %{$cluster_builder->{ParameterLookup}} ) {
      # save default value
      $current_values{ $key } = ( exists $value->{VALUE} ? $value->{VALUE} : undef );

      exists $mask_params->{ $key } and $current_values{$key} = $mask_params->{$key}{Value};

      if (! exists $web_args->{$key}){
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
    
    keys %$mask_params and $parameter_mask->{ Cluster }->{ $cluster } = $mask_params;

    $pipeline_builder->edit( ParameterMask => $parameter_mask );
    
    $self->redirect( uri => "/PipelineBuilder/AnnotateCluster?pipeline_builder=$pipeline_builder&cluster=$cluster" );

  }
  # bounce!!!!!
     $self->_save_arg( 'form', $form);
     $self->redirect( uri => "/PipelineBuilder/EditCluster?pipeline_builder=$pipeline_builder&cluster=$cluster" );

}

sub Exception::PipelineBuilder::EditCluster {

}


#------------------------------------------------------------------------

=item public void AnnotateCluster();

Saves cluster parameter change notes

=cut
#------------------------------------------------------------------------

sub PipelineBuilder::AnnotateCluster {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::PipelineBuilder->AnnotateCluster($web_args);

  my $pipeline_builder = $web_args->{pipeline_builder};
  my $cluster = $web_args->{cluster};

  if ($form->canceled( )) {

    $self->redirect(
     uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder"
                   );
  }

  
  if ( $form->ok ) {

    # load parameter mask and get a link into our cluster
    my $parameter_mask = $pipeline_builder->getParameterMask();
    my $mask_params = $parameter_mask->{ Cluster }->{ $cluster };

    # loop through web arguments
    while ( my ($key, $value) = each %$web_args ) {

        if ( $key =~ /(\S+)_comment$/ ) {
          $mask_params->{$1}{Description} = $value;
        }
    }

    keys %$mask_params and $parameter_mask->{ Cluster }->{ $cluster } = $mask_params;

    $pipeline_builder->edit( ParameterMask => $parameter_mask );

    $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );

  }

  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/PipelineBuilder/Overview?pipeline_builder=$pipeline_builder" );
}

sub Exception::PipelineBuilder::AnnotateCluster {

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
