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

  # make sure we have permission to run this
  if ( $pipeline->isa( 'ISGA::UserPipeline' ) ) {
    
    $pipeline->getCreatedBy == $account or
      X::User::Denied->throw( error => 'You do not have permission to execute this pipeline.' );

    # allow for pipeline sharing in the future
  }
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


  use Data::Dumper;

  warn Dumper($form);
  
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


  use Data::Dumper;

  warn Dumper($form);

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


#  my $file = $args->{file};
  my $pi = $args->{pipeline_input};
  my $run_builder = $args->{run_builder};


  # permissions check
  $run_builder->getCreatedBy == ISGA::Login->getAccount 
    or X::User::Denied->throw;


  $form->canceled and $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );

  if ( $form->ok ){

    my $file = $args->{file};

    my $run_builder = $form->get_input('run_builder');
    my $upload = $self->apache_req->upload('file_name');


    if ( defined $upload && $form->get_input('file_name') ne '' ){

      my %args = ( UserName => $args->{file_name},
		   Type => $pi->getType,
		   Format => $pi->getFormat,
		   Description => $args->{description},
		   CreatedBy => ISGA::Login->getAccount,
		   CreatedAt => ISGA::Timestamp->new,
		   IsHidden => 0 );
      
      my $uploaded_file = ISGA::FileResource->upload( $upload->fh, %args );
      
      # if there is no file, then we proceed with upload
      if (! defined $file){
	$file = $uploaded_file;
	      
      # if there are more than one files selected, add new file to the list
      } elsif ( ref($file) eq 'ARRAY' ) {
	push @$file, $uploaded_file;

      # if there is one file, we make a list of it and our upload
      } else {	
	$file = [ $file, $uploaded_file ];
      }
    }

    my $collection;
    
    if ( UNIVERSAL::isa($file, 'ISGA::FileCollection') ) {
      
      $file->getCreatedBy == ISGA::Login->getAccount
	or X::User::Denied->throw;
      
      $collection = $file;
      
    } else {
      
      # promote single file to array for consistency
      ref($file) eq 'ARRAY' or $file = [ $file ];
      
      # build collection for files
      $collection = 
	ISGA::FileCollection->create( Type => ISGA::FileCollectionType->new('File List'),
					  CreatedAt => ISGA::Timestamp->new(),
					  CreatedBy => ISGA::Login->getAccount,
					  Description => 'Collection Created for Run input',
					  IsHidden => 1,
					  ExistsOutsideCollection => 1,
					  UserName => "test" . $$ . $pi,
					);
      
      my $index = 0;
      
      foreach  ( @$file ) {
	$_->getCreatedBy == ISGA::Login->getAccount
	  or X::User::Denied->throw;
	
	ISGA::FileCollectionContent->create( FileCollection => $collection,
						 FileResource => $_,
						 Index => $index++ );
      }
    }
    
    # Check to see if there was already a defined input
    my ($rbi) = 
      @{ISGA::RunBuilderInput->query( RunBuilder => $run_builder,
					  PipelineInput => $pi )};
    
    # TODO - probably should confirm type/format here
    # replace old contents of the rbi with the new collection
    if ( $rbi ) {
      if ( $collection ) {
	$rbi->edit( FileResource => $collection );
	# TODO - delete old_file if it was a pipeline input collection
      } else {
	X::API->throw( message => "Pre-existing runbuilderinput was not a collection");
      }
    } else {
      ISGA::RunBuilderInput->create( RunBuilder => $run_builder,
					 FileResource => $collection,
					 PipelineInput => $pi );
    }
    
    
    $self->redirect( uri => "/RunBuilder/View?run_builder=$run_builder" );
  }
  
  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/RunBuilder/SelectInputList?run_builder=$run_builder" );

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
#  $self->redirect( uri => "/Pipeline/View?pipeline=$pipeline" );
  $self->redirect( uri => "/RunBuilder/ListMy" );
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
