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

use Clone qw(clone);

{

  # private variable to cache pipelines and components
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

=item public ISGA::ComponentBuilder new(Component $component, Pipeline, $pipeline, ParameterMask $mask);

Initialize the Componentbuilder object corresponding to the supplied 
Component and parameter mask.

=cut
#------------------------------------------------------------------------
  sub new {

    my ($class, $component, $pipeline, $mask) = @_;

    return undef unless( defined $pipelines{$pipeline}{$component});

    my $self = clone($pipelines{$pipeline}{$component});

    if ( $mask ) {
      return $component->injectMaskValues( $mask, $self );
    }
    
    return $self;
  }

#========================================================================

=back

=head2 ACCESSORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string getComponentDescription( string name );

Returns the tip/description associated with the component.

=cut
#------------------------------------------------------------------------
sub getComponentDescription { return shift->{Description}; }

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

#------------------------------------------------------------------------

=item PRIVATE _initializePipeline(GlobalPipeline $pipeline);

Initializes all the components, parameters, and input parameters for a pipeline.

=cut
#------------------------------------------------------------------------
  sub _initializePipeline {
    
    my ($class, $pipeline) = @_;
    
    # process components
    foreach my $component ( @{$pipeline->getComponents} ) {
      if ( my $template = $templates{ $component->getTemplate } ) {      
	$pipelines{$pipeline}{$component} = $template->_initializeComponent($component, $pipeline);
      }
    }

    # read in components
  }
      
#------------------------------------------------------------------------

=item PRIVATE ComponentBuilder _initializeComponent(Component $component, Pipeline $pipeline);

Initialize the Component form object corresponding to the supplied
component, component template and pipeline.

=cut
#------------------------------------------------------------------------
  sub _initializeComponent {

    my ($self, $component, $pipeline) = @_;

    # read in pipeline YAML file
    my $p_yaml = ISGA::PipelineDefinition->new($pipeline);

    my $clone = clone($self);
    $clone->{ParameterLookup} = {};
    
    my %filtered_params = %{$p_yaml->getFilteredParameters($component)};

    my @fieldsets;

    if ( exists $clone->{Params} ) {
      
      my (@required, @optional);

      for ( @{$self->{Params}} ) {
	
	next if exists $filtered_params{$_->{NAME}};

	$_->{LABEL} = $_->{NAME};

	if ( ! exists $_->{templ} || $_->{templ} eq 'text' ) {
	  exists $_->{MAXLEN} or $_->{MAXLEN} = 60;
	  exists $_->{SIZE} or $_->{SIZE} = 60;
	  if ( exists $_->{REQUIRED} ) {
	    push( @{$_->{ERROR}}, 'not_null', 'Text::checkHTML');
	  }
	}

	if ( exists $_->{REQUIRED} ) {
	  push @required, $_;
	} else {
	  push @optional, $_;
	}
      }

      if ( @required or @optional ) {
	
	# initialize form parameters
	$clone->{PipelineBuilder}{FormEngine} = {'templ' => 'fieldset',
						 'OUTER' => '1', 
						 'TITLE' => $component->getName,
						 'sub' => []};
      
	
	if ( @required ) {

	  push @{$clone->{PipelineBuilder}{FormEngine}{sub}},
	    {'templ' => 'fieldset', 
	     'TITLE' => 'Required Parameters',
	     'NESTED' => '1',
	     'sub' => \@required};

	  if ( @optional ) {
	    push @{$clone->{PipelineBuilder}{FormEngine}{sub}},
	      {'templ' => 'fieldset',
	       'TITLE' => 'Optional Parameters',
	       'JSHIDE' => 'optional_hide',
	       'NESTED' => '1',
	       'sub' => \@optional};
	  }
	} else {

	  push @{$clone->{PipelineBuilder}{FormEngine}{sub}},
	    {'templ' => 'fieldset',
	     'TITLE' => 'Optional Parameters',
	     'NESTED' => '1',
	     'sub' => \@optional};
	}
	
	push @fieldsets, @{$clone->{PipelineBuilder}{FormEngine}{sub}};
      }
      
      delete $clone->{Params};
    }


    foreach my $fieldset ( @fieldsets ) {
      foreach ( @{$fieldset->{sub}} ) {
	
	# create shortcut to parameter from name
	$clone->{ParameterLookup}{ $_->{NAME} } = $_;
	$_->{COMPONENT} = $component->getName;
	$_->{TIP} = "/Component/GetParameterDescription?component=$component&name=$_->{NAME}&pipeline=$pipeline";
      }
    }



    return $clone;
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
      
      $templates{$template} = $self;
    }
  }

  foreach my $pipeline ( @{ISGA::GlobalPipeline->query()} ) {
    __PACKAGE__->_initializePipeline($pipeline);
  }
  
  undef %templates;
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
