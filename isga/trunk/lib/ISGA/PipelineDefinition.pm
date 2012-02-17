package ISGA::PipelineDefinition;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::PipelineDefinition is an object wrapper around a YAML snippet
that overlays the definitions of component template parameters.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use YAML;

use Data::Dumper;
use List::MoreUtils qw(any);

use overload
  q{""}  => sub { return YAML::Dump($_[0]); };

use Clone qw(clone);

{

  # private variable for caching component objects
  my %pipelines;

#========================================================================

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public ISGA::PipelineDefinition new(Pipeline $pipeline);

Initializes the PipelineDefinition for the supplied Pipeline.

=item public ISGA::PipelineDefinition new(RunBuilder $run_builder);

Initializes the PipelineDefinition for the supplied RunBuilder.

=cut
#------------------------------------------------------------------------
  sub new {

    my ($class, $caller) = @_;
    
    # handle run builder case
    $caller->isa('ISGA::RunBuilder') and return $class->_newByRunBuilder($caller);
    $caller->isa('ISGA::Pipeline') and return $class->_newByPipeline($caller);

    X::API::Parameter::Invalid->throw( value => ref($caller), message => 'Supplied Parameter is not a RunBuilder or Pipeline' );
  }

#------------------------------------------------------------------------

=item PRIVATE PipelineDefinition _newByPipeline(Pipeline $pipeline);

Constructor for special case where the caller of new() is a
Pipeline. 

=cut
#------------------------------------------------------------------------
  sub _newByPipeline {

    my ($class, $pipeline) = @_;

    my $global_template = $pipeline->getGlobalTemplate();
    defined $pipelines{$global_template} or X::API->throw( message => "Unable to find definition for pipeline $global_template" );
    
    my $self = clone($pipelines{$global_template});

    if ( $pipeline->isa('ISGA::UserPipeline') ) {

      # find active components

      # verify
      my %active;

      # grab active components
      foreach ( @{$pipeline->getComponents} ) {
	$active{$_->getErgatisName} = undef;
      }

      # filter form
      $self->{Parameters} = [grep { any { exists $active{$_} } @{$_->{USEDBY}} } @{$self->{Parameters}}];

      # filter lookup
      foreach ( keys %{$self->{ParameterLookup}} ) {
	any { exists $active{$_} } @{$self->{ParameterLookup}{$_}{USEDBY}} or delete $self->{ParameterLookup}{$_};
      }
	
      # filter mapping
      $self->{ParameterMapping} = [grep { exists $active{$_->{Component}} } @{$self->{ParameterMapping}}];

      # bazinga
      $self->injectMaskValues($pipeline->getParameterMask);

      warn Dumper($self);

    }

    return $self;
  }

#------------------------------------------------------------------------

=item PRIVATE PipelineDefinition _newByRunBuilder(RunBuilder $run_builder);

Constructor for special case where the caller of new() is a
RunBuilder. Build the PipelineDefinition for the underlying Pipeline
and then inject the RunBuilder mask.

=cut
#------------------------------------------------------------------------
  sub _newByRunBuilder {
    
    my ($class, $run_builder) = @_;

    # retrieve the global pipeline
    my $pipeline = $run_builder->getPipeline;
    my $self = $class->_newByPipeline($pipeline);
    
    # initialize form

    # inject mask values
    $self->injectMaskValues($run_builder->getParameterMask);
    return $self;
  }

#------------------------------------------------------------------------

=item public void injectMaskValues(ParameterMask $mask);

Injects ParameterMask values into the pipeline definition.

=cut
#------------------------------------------------------------------------
  sub injectMaskValues {

    my ($self, $parameter_mask) = @_;

    my $mask_params = exists $parameter_mask->{Run} ? $parameter_mask->{Run} : undef;

    foreach (keys %$mask_params) {
      $self->{ParameterLookup}{$_}{VALUE} = $mask_params->{$_}{Value};
      $self->{ParameterLookup}{$_}{ANNOTATION} = $mask_params->{$_}{Description};    
    }

    # retain other parameters for if we want to mask components, overwrite any existing mask
    $self->{component_mask}{Component} = exists $parameter_mask->{Component} ? $parameter_mask->{Component} : {};
  }

#------------------------------------------------------------------------

=item PRIVATE void _initialize()

Initialize the PipelineDefinition object.

=cut
#------------------------------------------------------------------------
  sub _initialize {

    my $self = shift;
    my $pipeline = shift;

    $self->{ParameterLookup} = {};
    $self->{pipeline} = $pipeline;

    # retrieve all the components for the pipeline;
    my @components = @{$pipeline->getComponents};

    my %component_map;
    my %component_archive;

    # store components and apply definition mask if it exists
    foreach my $component ( @components ) {

      my $erg_name = $component->getErgatisName;

      # get component
      my $c_mask = ( exists $self->{Components}{$erg_name} ? $self->{Components}{$erg_name} : [] );

      if ( my $cb = ISGA::ComponentBuilder->_cloneForPipeline($pipeline, $component, $c_mask) ) {
	$component_map{$erg_name} = $cb;
	$component_archive{$erg_name} = $component;
      }
    }

    # pull components into Run Parameters
    if ( exists $self->{Parameters} ) {
      for my $param ( @{$self->{Parameters}} ) {

	# make it form-worthy
	ISGA::ComponentBuilder->_processParameterForForm($param);
	$self->{ParameterLookup}{$param->{NAME}} = $param;
      }
    }
   
    # initialize ParameterMapping
    exists $self->{ParameterMapping} or $self->{ParameterMapping} = [];

    foreach ( @{$self->{ParameterMapping}} ) {
      exists $component_map{$_->{Component}} or X::API->throw( message => "Component $_->{Component} not found\n" );

      $component_map{$_->{Component}}->_removeParameter($_->{Name});

      warn "looking at $_->{Name} and $_->{Component}\n";

      # check for a value replacement
#      my $value = exists $_->{Value} ? $_->{Value} : 'Specified at run time';
      
#      $component_map{$_->{Component}}->_overrideParameter($_->{Name}, $value);

#      if ( $_->{Component} eq 'ncbi-blastx_plus.reference_genome' ) {
#	use Data::Dumper;
#	warn Dumper($component_map{$_->{Component}});
#      }

    }

    # check for inputses
    exists $self->{Input} or $self->{Input} = {};

    while ( my ($key, $values) = each %{$self->{Input}} ) {

      foreach ( @$values ) {
	
	# make it form-worthy
	ISGA::ComponentBuilder->_processParameterForForm($_);	
      }      
    }


#139 	# handle RBI parameters
#140 	if ( exists $self->{InputParams} ) {
#141 	
#142 	my %inputs;
#143 	
#144 	my @all_rbi;
#145 	
#146 	for ( @{$self->{InputParams}} ) {
#147 	
#148 	if (not(exists $_->{'templ'}) || $_->{'templ'} eq 'text'){
#149 	exists $_->{MAXLEN} or $_->{'MAXLEN'} = 60;
#150 	exists $_->{SIZE} or $_->{'SIZE'} = 60;
#151 	if (exists $_->{'REQUIRED'}){
#152 	push(@{$_->{'ERROR'}}, 'not_null', 'Text::checkHTML');
#153 	}
#154 	}
#155 	
#156 	my $name = $_->{input};
#157 	push @{$inputs{$name}}, $_;
#158 	push @all_rbi, $_;
#159 	}
#160 	
#161 	$self->{RunBuilderInput} = \%inputs;
#162 	$self->{AllRunBuilderInput} = { sub => \@all_rbi };
#163 	}


#372 	sub getRunBuilderInputParameters {
#373 	
#374 	my ($self, $pi) = @_;
#375 	
#376 	my $name = $pi->getClusterInput->getName();
#377 	
#378 	if ( exists $self->{RunBuilderInput}{$name} ) {
#379 	return $self->{RunBuilderInput}{$name};
#380 	}
#381 	
#382 	return [];
#383 	}




    # save components to ComponentBuilder
    while ( my ($key,$val) = each %component_map ) {
      $val->_initializeForm($pipeline, $component_archive{$key});
    }


  }


#------------------------------------------------------------------------

=item public hashRef getParameterForm();

Returns the FormEngine portion of the RunBuilder parameters.

=cut
#------------------------------------------------------------------------
  sub getParameterForm { 

    my $self = shift;

    return { templ => 'fieldset',
	     sub => $self->{Parameters},
	     CLASS => 'runbuilderForm' };
  }

#========================================================================

=head2 ACCESSORS

=over 4

=cut
#========================================================================


#------------------------------------------------------------------------

=item public HashRef getComponentParameterValues(RunBuilder $run_builder, Component $component);

Returns a hashref of name => values for all parameters to the supplied component.

=cut
#------------------------------------------------------------------------
  sub getComponentParameterValues {

    my ($self, $run_builder, $component) = @_;

    # do we copy our parameter mask from a different component
    my $build_component = $component->getCopyParameterMask || $component;
    my $e_name = $build_component->getErgatisName;

    # start off empty
    my $parameters = {};

    # process anything from the component
    if ( my $builder = $self->getComponentBuilder($build_component) ) {
#      warn "the builder worked\n";
      $parameters = $builder->getParameterValues();
#    } else {
#      warn "the builder did not work\n";
    }

#    warn Dumper($parameters);

    # now process anything from the run parameters
    foreach ( grep { $_->{Component} eq $e_name } @{$self->{ParameterMapping}} ) {
      
      # value
      if ( exists $_->{Value} ) {
	$parameters->{$_->{Name}} = $_->{Value};

      # parameter
      } elsif ( exists $_->{Parameter} ) {

	my $p = $self->{ParameterLookup}{$_->{Parameter}};
	$parameters->{$_->{Name}} = exists $p->{FLAG} ? "$p->{FLAG} $p->{VALUE}" : $p->{VALUE};

      # callback
      } elsif ( exists $_->{Callback} ) {
	my $method = $_->{Callback};
	$parameters->{$_->{Name}} = $run_builder->$method($self, $build_component, $_->{Name});
      }
    }

    return $parameters;
  }

#------------------------------------------------------------------------

=item public ComponentBuilder getComponentBuilder(Component $component);

Returns a component builder with this objects parameter mask applied.

=cut
#------------------------------------------------------------------------
  sub getComponentBuilder {

    my ($self, $component) = @_;

    # retrieve the component

    return ISGA::ComponentBuilder->new($component, $self->{pipeline}, $self->{component_mask} );
  }

#------------------------------------------------------------------------

=item public string getInputParameters( string name );

Returns the parameters for the supplied input

=cut
#------------------------------------------------------------------------
  sub getInputParameters {
    
    my ($self, $param) = @_;
    
    return  exists $self->{Input}{$param} ? $self->{Input}{$param} : [];
  }

#------------------------------------------------------------------------

=item public string getParameter( string name );

Returns the tip/description associated with the supplied parameter name.

=cut
#------------------------------------------------------------------------
  sub getParameter {
    
    my ($self, $param) = @_;
    
    exists $self->{ParameterLookup}{$param} or return '';
    return $self->{ParameterLookup}{$param};
  }
  
#------------------------------------------------------------------------

=item public boolean hasParameters()

Returns true if the Pipeline has parameters.

=cut
#------------------------------------------------------------------------
  sub hasParameters { return scalar keys %{shift->{ParameterLookup}}; }

#------------------------------------------------------------------------

=item public [hashref] getParameters();

Returns the run builder parameters.

=cut
#------------------------------------------------------------------------
  sub getParameters { return [values %{shift->{ParameterLookup}}]; }

#------------------------------------------------------------------------

=item public getComponent(Component $component);

Returns the data structure for the component or undef if the component
has no data structyure.

=cut
#------------------------------------------------------------------------
  sub getComponent {
    
    my ($self, $component) = @_;
    
    if ( exists $self->{Components}{ $component->getErgatisName } ) {
      return $self->{Components}{ $component->getErgatisName };
    } 
    return undef;
  }

#========================================================================

=head2 MUTATORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item Class Initialization

YAML files are loaded and cached at server startup.

=cut

#------------------------------------------------------------------------
  
  foreach my $pipeline ( @{ISGA::GlobalPipeline->query()} ) {

    my $form_path = $pipeline->getFormPath;
    my $self = YAML::LoadFile($form_path);
    $self->_initialize($pipeline);
    
    $pipelines{$pipeline} = $self;
  }

}
1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
