package ISGA::ComponentBuilder;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ComponentBuilder> provides convenience methods for
interacting with the component definitions that make up the
ComponentBuilder object.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;
use YAML;
use Kwalify qw(validate);
use ISGA::ComponentTemplate;
use List::MoreUtils qw{any};

use Data::Dumper;

use Clone qw(clone);

{

  # private variable to cache pipelines and component templates
  my %pipelines;
  my %templates;

#========================================================================

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public ISGA::ComponentBuilder new(Component $component, Pipeline $pipeline);

Initialize the Componentbuilder object corresponding to the supplied
Component. If the Component does not have a builder .yaml file, undef
is returned.

=item public ISGA::ComponentBuilder new(Component $component, Pipeline $pipeline, ParameterMask $mask);

Initialize the Componentbuilder object corresponding to the supplied 
Component and parameter mask.

=cut
#------------------------------------------------------------------------
  sub new {

    my ($class, $component, $pipeline, $mask) = @_;

    return undef unless( defined $pipelines{$pipeline}{$component});

    my $self = clone($pipelines{$pipeline}{$component});

    if ( $mask ) {
      $self->injectMaskValues($component, $mask);
    }
    
    return $self;
  }

#------------------------------------------------------------------------

=item PRIVATE void _initialize();

Perform basic initialization of the component template.

=cut
#------------------------------------------------------------------------
  sub _initialize {

    my $self = shift;

    $self->{ParameterLookup} = {};

    exists $self->{Params} or return;

    foreach (@{$self->{Params}}) {
      $self->{ParameterLookup}{$_->{NAME}} = $_;
    }
  }

#------------------------------------------------------------------------

=item PRIVATE void _cloneForPipeline();

Customize the component template parameters by applying any mask or
filter from the pipeline definition.

=cut
#------------------------------------------------------------------------
  sub _cloneForPipeline {

    my ($class, $pipeline, $component, $c_mask) = @_;

    my $template = $component->getTemplate();
    return undef unless exists $templates{$template};
   
    # base our object on the template
    my $self = clone($templates{$template});
    
    my %masked_params;
    $masked_params{$_->{NAME}} = $_ for @$c_mask;

    foreach my $param ( @{$self->{Params}} ) {
      while ( my ($key, $val) = each %{$masked_params{$param->{NAME}}} ) {
	$self->{ParameterLookup}{$param->{NAME}}{$key} = $val;
      }
    }
    
    $pipelines{$pipeline}{$component} = $self;
    return $self;
  }

#------------------------------------------------------------------------

=item PRIVATE void _

Remove a parameter from the builder that has been promoted to a run parameter.

=cut
#------------------------------------------------------------------------

#------------------------------------------------------------------------

=item PRIVATE void _removeParameter(string name);

Removes the supplied parameter from the component.

=cut
#------------------------------------------------------------------------
  sub _removeParameter {

    my ($self, $name) = @_;

    if ( exists $self->{Params} ) {

      $self->{Params} = [grep { $_->{NAME} ne $name } @{$self->{Params}}];
      
      # dont maintain an empty parameter list
      @{$self->{Params}} or delete $self->{Params};

    }

    exists $self->{ParameterLookup}{$name} and delete $self->{ParameterLookup}{$name};
  }

#------------------------------------------------------------------------

=item PRIVATE void _overrideParameter(hashRef $parameter);

Remove a parameter from the builder that has been promoted to a run parameter.

=cut
#------------------------------------------------------------------------
  sub _overrideParameter {

    my ($self, $name, $value) = @_;

    if ( exists $self->{ParameterLookup}{$name} ) {
      $self->{ParameterLookup}{$name}{templ} = 'print';
      $self->{ParameterLookup}{$name}{VALUE} = $value;
    } else {
      $self->{ParameterLookup}{$name} = { NAME => $name, VALUE => $value, templ => 'print' };
    }
  }

#------------------------------------------------------------------------

=item PRIVATE void _initializeForm();

Build the FormBuilder data structure for the component parameters and
save the object to our cache.

=cut
#------------------------------------------------------------------------
  sub _initializeForm {

    my ($self, $pipeline, $component) = @_;

    if ( exists $self->{Params} and @{$self->{Params}} ) {

      my (@required, @optional);
      
      for ( @{$self->{Params}} ) {  
	
	__PACKAGE__->_processParameterForForm($_);
	
	if ( exists $_->{REQUIRED} ) {
	  push @required, $_;
	} else {
	  push @optional, $_;
	}
      }

      # initialize form parameters
      $self->{PipelineBuilder}{FormEngine} = {'templ' => 'fieldset',
					      'OUTER' => '1', 
					      'TITLE' => $component->getName,
					      'sub' => []};
      
      
      if ( @required ) {
	
	push @{$self->{PipelineBuilder}{FormEngine}{sub}},
	  {'templ' => 'fieldset', 
	   'TITLE' => 'Required Parameters',
	   'NESTED' => '1',
	   'sub' => \@required};
	
	if ( @optional ) {
	  push @{$self->{PipelineBuilder}{FormEngine}{sub}},
	    {'templ' => 'fieldset',
	     'TITLE' => 'Optional Parameters',
	     'JSHIDE' => 'optional_hide',
	     'NESTED' => '1',
	     'sub' => \@optional};
	}
      } else {
	
	push @{$self->{PipelineBuilder}{FormEngine}{sub}},
	  {'templ' => 'fieldset',
	   'TITLE' => 'Optional Parameters',
	   'NESTED' => '1',
	   'sub' => \@optional};
      }
      
      foreach my $fieldset ( @{$self->{PipelineBuilder}{FormEngine}{sub}} ) {
	foreach ( @{$fieldset->{sub}} ) {
	  
	  # create shortcut to parameter from name
	  $self->{ParameterLookup}{ $_->{NAME} } = $_;
	  $_->{COMPONENT} = $component->getName;
	  $_->{TIP} = "/Component/GetParameterDescription?component=$component&name=$_->{NAME}&pipeline=$pipeline";
	}
      }      
    }
  }

#========================================================================

=back

=head2 ACCESSORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public HashRef getParameterValues();

Returns a hashref of name => values for all parameters for this component.

=cut
#------------------------------------------------------------------------
  sub getParameterValues {

    my $self = shift;
    my %parameters;

#    warn "looking at $self->{Name}:\n";
    
    foreach ( @{$self->getParameters} ) {
      
      # should this snippet be pulled into a method?
      $parameters{$_->{NAME}} = '';
      if ( defined $_->{VALUE} ) {
	$parameters{$_->{NAME}} = exists $_->{FLAG} ? "$_->{FLAG} $_->{VALUE}" : "$_->{VALUE}";
      }
    }

    return \%parameters;
  }
  
#------------------------------------------------------------------------

=item public string getComponentDescription();

Returns the tip/description associated with the component.

=cut
#------------------------------------------------------------------------
  sub getComponentDescription { return shift->{Description}; }

#------------------------------------------------------------------------

=item public string getParameterDescription( string name );

Returns the tip/description associated with the component.

=cut
#------------------------------------------------------------------------
  sub getParameterDescription {
    
    my ($self, $param) = @_;
    
    return $self->{ParameterLookup}{$param}{DESCRIPTION};
  }

#------------------------------------------------------------------------

=item public [hashref] getRequiredParameters();

Returns the required parameters for this component.

=cut
#------------------------------------------------------------------------
  sub getRequiredParameters { 
    
    my $self = shift;
    
    my ($req) = grep { $_->{TITLE} eq 'Required Parameters' } 
      @{$self->{PipelineBuilder}{FormEngine}{sub}};
    
    return $req ? $req->{sub} : [];
  }
  
#------------------------------------------------------------------------

=item public [hashref] getOptionalParameters();

Returns the optional parameters for this component.

=cut
#------------------------------------------------------------------------
  sub getOptionalParameters { 
    
    my $self = shift;
    
    my ( $opt ) = grep { $_->{TITLE} eq 'Optional Parameters' } 
      @{$self->{PipelineBuilder}{FormEngine}{sub}};
    
    return $opt ? $opt->{sub} : [];
  }
  
#------------------------------------------------------------------------

=item public [hashref] getSetOptionalParameters();

Returns the optional parameters for this component that have a set value.

=cut
#------------------------------------------------------------------------
  sub getSetOptionalParameters { 
    
    my $self = shift;
    
    my ( $opt ) = grep { $_->{TITLE} eq 'Optional Parameters' } 
      @{$self->{PipelineBuilder}{FormEngine}{sub}};
    
    $opt or return [];
    
    return [grep { exists $_->{VALUE} } @{$opt->{sub}}];
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

=item public [hashref] getParameters();

Returns all the parameters for this component builder.

=cut
#------------------------------------------------------------------------
sub getParameters {

  my $self = shift;

  return [values %{$self->{ParameterLookup}}];
}

#------------------------------------------------------------------------

=item public HashRef getForm( );

Returns the FormEngine portion of the ComponentBuilder

=cut

#------------------------------------------------------------------------
sub getForm { return shift->{PipelineBuilder}{FormEngine}; }

#========================================================================

=back

=head2 MUTATORS

=over 4

=cut
#========================================================================
#------------------------------------------------------------------------

=item public void injectMaskValues(ParameterMask $mask);

Injects ParameterMask values into the pipeline definition.

=cut
#------------------------------------------------------------------------
  sub injectMaskValues {

    my ($self, $component, $parameter_mask) = @_;

    my $mask_params = exists $parameter_mask->{Component}{$component} ? $parameter_mask->{Component}{$component} : undef;

    foreach (keys %$mask_params) {

      #$self->{ParameterLookup}{$_}{VALUE} = ref $mask_params->{$_}->{Value} eq 'ARRAY' ? $self->formatArrayParam($mask_params->{$_}->{Value}) : $mask_params->{$_}->{Value};
      $self->{ParameterLookup}{$_}{VALUE} = $mask_params->{$_}{Value};
      $self->{ParameterLookup}{$_}{ANNOTATION} = $mask_params->{$_}{Description};    
    }
  }

#========================================================================

=back

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item PRIVATE hashRef _processParameterForForm(hashRef parameter);

Processes the YAML definition of a parameter to prepare it for FormEngine.

=cut
#------------------------------------------------------------------------
sub _processParameterForForm {

  my $class = shift;
  my $param = shift;

  $param->{LABEL} = $param->{NAME};

  if ( ! exists $param->{templ} || $param->{templ} eq 'text' ) {
    exists $param->{MAXLEN} or $param->{MAXLEN} = 60;
    exists $param->{SIZE} or $param->{SIZE} = 60;
    if ( exists $param->{REQUIRED} ) {
      push @{$param->{ERROR}}, 'not_null', 'Text::checkHTML';
    }
    
  } elsif ( exists $param->{REFERENCEDB} ) {
    foreach my $refdb ( @{ISGA::ReferenceDB->query( Type => ISGA::ReferenceType->new( Name => $param->{REFERENCEDB} ) )} ) {
      my $ref_tag = $refdb->getRelease->getReference->getTag->getName;
      if ( ($ref_tag eq 'Organism' or $ref_tag eq 'OTU') and $refdb->getStatus->isAvailable()) {
	push @{$param->{OPTION}}, $refdb->getName;
	push @{$param->{OPT_VAL}}, $refdb->getFullPath;
      }
    }
  }

  return $param;
}

#------------------------------------------------------------------------

=item Class Initialization

YAML files are loaded and cached at server startup.

=cut

#------------------------------------------------------------------------

  my $schema = YAML::LoadFile('___package_include___/schema/component_definition_kwalify.yaml');

  foreach my $template ( @{ISGA::ComponentTemplate->query()} ) {
    if ( my $form_path = $template->getFormPath ) {
      my $self = YAML::LoadFile($form_path);
      validate($schema,$self);
      $self->_initialize();
      $templates{$template} = $self;
    }
  }
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
