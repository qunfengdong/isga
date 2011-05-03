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

use Apache2::Upload;
#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void Create();

Method to Create a new run builder

=cut
#------------------------------------------------------------------------
sub RunBuilder::Create {

  my $self = shift;

  my $account = ISGA::Login->getAccount;
  my $pipeline = $self->args->{pipeline};

  $pipeline->getStatus eq 'Retired'
    and X::User::Denied->throw( error => 'Pipeline has been retired.' );

  my $is_installed;

  # make sure we have permission to run this
  if ( $pipeline->isa( 'ISGA::UserPipeline' ) ) {
    
    $pipeline->getCreatedBy == $account or
      X::User::Denied->throw( error => 'You do not have permission to execute this pipeline.' );
      $is_installed = $pipeline->getTemplate->isInstalled->getValue;
    # allow for pipeline sharing in the future
  } else {
      $is_installed = $pipeline->isInstalled->getValue;
  }

  not $is_installed and X::User::Denied->throw( error => 'This pipeline is not currently installed.  You may have navigated to this page by mistake.  You will not be able to customize or run this pipeline. Please use the navigation menu to select a pipeline.' );

  if (my ($started_builder) = @{ISGA::RunBuilder->query( Pipeline => $pipeline, 
							     CreatedBy => $account )} ){
    $self->redirect( uri => "/RunBuilder/View?run_builder=$started_builder" );
  }

  # count runs
  my $runs = ISGA::Run->exists( CreatedBy => $account, Type => $pipeline );
  $runs++;

  my $default_name = $pipeline->getName . " Run $runs";

  while( ISGA::Run->exists( Name => $default_name, CreatedBy => ISGA::Login->getAccount) ||
         ISGA::RunBuilder->exists( Name => $default_name, CreatedBy => ISGA::Login->getAccount)){
    $runs++;
    $default_name = $pipeline->getName . " Run $runs";
  }

  my %form_args =
    ( 
     Pipeline => $pipeline,
     ErgatisDirectory => time . $$,
     Name => $default_name,
     StartedAt => ISGA::Timestamp->new,
     CreatedBy => $account,
     ParameterMask => $pipeline->getRawParameterMask,
     Description => ''
    );

  my $builder = ISGA::RunBuilder->create(%form_args);
  $self->redirect( uri => "/RunBuilder/View?run_builder=$builder" );

}  

#------------------------------------------------------------------------

=item public void EditDetails();

Method to edit the details for a pipeline builder

=cut
#------------------------------------------------------------------------
sub RunBuilder::EditDetails {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::RunBuilder->EditDetails($web_args);
  
  my $run_builder = $web_args->{run_builder};

  if ($form->canceled( )) {

    $self->redirect( 
     uri => "/RunBuilder/View?run_builder=$run_builder" 
		   );
  }

  if ( $form->ok ) {

    my %form_args =
      ( 
       Name => $form->get_input('name'),
       Description => $form->get_input('description')
      );

    $run_builder->edit( %form_args );

    $self->redirect
      ( uri => "/RunBuilder/View?run_builder=$run_builder" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/RunBuilder/EditDetails?run_builder=$run_builder" );
}

#------------------------------------------------------------------------

=item public void EditParameters();

Method to edit the parameters for a run builder.

=cut
#------------------------------------------------------------------------
sub RunBuilder::EditParameters {

  my $self = shift;
  my $web_args = $self->args;
  my $run_builder = $web_args->{run_builder};

  my $form = ISGA::FormEngine::RunBuilder->EditParameters($web_args);
  
  if ( $form->canceled() ) {
  }

  if ( $form->ok ) {

    my $parameter_mask = $run_builder->getParameterMask();

    # cache all the values in case there are name duplicates
    my %inputs;

    # loop through components
    for my $component ( @{$form->get_inputs('component')} ) {
      
      # grab component builder
      my $component_builder = ISGA::ComponentBuilder->new($component, $parameter_mask);
      
      foreach my $parameter ( @{$component_builder->getRunBuilderParameters} ) {
	
	my $name = $parameter->{NAME};

	my $value = $form->get_input($name);

	# parameter names may have conflicts, so save arrays
	if ( ref $value eq 'ARRAY' ) {
	  exists $inputs{$name} or $inputs{$name} = $value;
	  $value = shift @{$inputs{$name}};
	}

	my $title = "$parameter->{COMPONENT} $parameter->{TITLE}";

	$parameter_mask->{Component}{$component}{$name} = { Description => 'Run Parameter',
							    Title => $title,
							    Value => $value };
      }
    }

    $run_builder->edit( ParameterMask => $parameter_mask );
    $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );
  }


  # bounce them back to finish the page
  $self->_save_arg( 'form', $form );
  $self->redirect( uri => "/RunBuilder/EditParameters?run_builder=$run_builder" );
}

#------------------------------------------------------------------------

=item public void RunBuilder::SelectInput();

Saves the selection of a file as input for a RunBuilder.

=cut
#------------------------------------------------------------------------
sub RunBuilder::SelectInput {

  my $self = shift;
  my $args = $self->args;

  my $file = $args->{file};
  my $pi = $args->{pipeline_input};
  my $run_builder = $args->{run_builder};

  # permissions check
  $run_builder->getCreatedBy == ISGA::Login->getAccount 
    or X::User::Denied->throw;

  # make sure there is only one file
  ref($file) eq 'ARRAY' and X->throw( Error => 'Only Single Files are Supported' );

  if ( $file ) {
    $file->getCreatedBy == ISGA::Login->getAccount
      or X::User::Denied->throw;
  }

  # calculate the rbi
  my ($rbi) = 
    @{ISGA::RunBuilderInput->query( RunBuilder => $run_builder,
					PipelineInput => $pi )};

  # probably should confirm type/format here
  if ( $rbi ) {
    if ( $file ) {
      $rbi->edit( FileResource => $file );
    } else {
      $rbi->delete();
    }
  } else {
    ISGA::RunBuilderInput->create( RunBuilder => $run_builder,
				       FileResource => $file,
				       PipelineInput => $pi );
  }
  
  $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );
}

#------------------------------------------------------------------------

=item public void RunBuilder::SelectInputList();

Saves the selection of a file as input for a RunBuilder.

=cut
#------------------------------------------------------------------------
sub RunBuilder::SelectInputList {

  my $self = shift;
  my $args = $self->args;
  my $form = ISGA::FormEngine::RunBuilder->SelectInputList($args);

  my $pi = $args->{pipeline_input};
  my $run_builder = $args->{run_builder};

  # permissions check
  $run_builder->getCreatedBy == ISGA::Login->getAccount 
    or X::User::Denied->throw;

  $form->canceled and $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );

  # do we have an rbi
  my $rbi = exists $args->{run_builder_input} ? $args->{run_builder_input} : undef;

  if ( $form->ok ){

    my $file = $args->{file};
    my $file_name = $args->{file_name};

    my $upload = $self->apache_req->upload('file_name');

    # if there is an upload, process it
    if ( defined $upload && $file_name ne '' ){
      $file = $run_builder->resolveUploadAndInputList($upload, $args, $pi);
    }
        
    # build collection and save it as the input
    my $collection = $run_builder->assembleInputList($file);

    # Check to see if there was already a defined input
    $rbi = $run_builder->setInputList($collection, $rbi || $pi);

    if ( $pi->hasParameters ) {
      
      my %inputs;

      my $mask = $rbi->getParameterMask();

      # loop through components
      for my $component ( @{$form->get_inputs('component')} ) {
      
	# grab component builder
	my $component_builder = ISGA::ComponentBuilder->new($component, $mask);

	foreach my $parameter ( @{$component_builder->getRunBuilderInputParameters($pi)} ) {
	
	  my $name = $parameter->{NAME};

	  my $value = $form->get_input($name);

	  # parameter names may have conflicts, so save arrays
	  if ( ref $value eq 'ARRAY' ) {
	    exists $inputs{$name} or $inputs{$name} = $value;
	    $value = shift @{$inputs{$name}};
	  }

	  $mask->{Component}{$component}{$name} = { Value => $value };
	}
      }
      
      $rbi->edit( ParameterMask => $mask );
    }
    
    $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );
  }
  
  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/RunBuilder/SelectInputList?run_builder=$run_builder" );
}

#------------------------------------------------------------------------

=item public void RemoveInputList();

Removes an entry from an iterative input list from a run builder.

=cut
#------------------------------------------------------------------------
sub RunBuilder::RemoveInputList {

  my $self = shift;
  my $args = $self->args;
 
  my $rb = $args->{run_builder};
  my $rbi = $args->{run_builder_input};

  my $pi = $rbi->getPipelineInput();
  $pi->isIterator or X->throw("Expected Iterator Input");

  my $fc = $rbi->getFileResource();

  $fc->isa('ISGA::FileCollection') or X->throw("Expected File Collection");

  # remove the run builder input and file collection
  $rbi->delete();
  $fc->delete();
  
  $self->redirect( uri => "/RunBuilder/View?run_builder=$rb" );
}
  
#------------------------------------------------------------------------

=item public void RemoveInput();

Removes an entry from an iterative input from a run builder.

=cut
#------------------------------------------------------------------------
sub RunBuilder::RemoveInput {

  my $self = shift;
  my $args = $self->args;
 
  my $rb = $args->{run_builder};
  my $rbi = $args->{run_builder_input};

  my $pi = $rbi->getPipelineInput();
  $pi->isIterator or X->throw("Expected Iterator Input");

  $rbi->delete();

  $self->redirect( uri => "/RunBuilder/View?run_builder=$rb" );
}

#------------------------------------------------------------------------

=item public void Cancel();

Removes a RunBuilder object from the system

=cut
#------------------------------------------------------------------------
sub RunBuilder::Cancel {

  my $self = shift;
  my $args = $self->args;

  # make sure they supplied a builder
  my $run_builder = $args->{run_builder};
  my $redirect =  $args->{redirect}; 
  # make sure they own the runbuilder
  my $account = ISGA::Login->getAccount;
  $run_builder->getCreatedBy == ISGA::Login->getAccount
    or X::User::Denied->throw( error => 'You do not own this run builder' );

  # remove the inputs
  foreach ( @{$run_builder->getInputs} ) {
    $_->delete();
  }
  
  my $pipeline = $run_builder->getPipeline;

  # nuke it and redirect
  $run_builder->delete();
#  $self->redirect( uri => "/RunBuilder/ListMy" );
  $self->redirect( uri => "$redirect" );
}

sub Exception::RunBuilder::Cancel {

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
