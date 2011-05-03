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

  # private variable for caching component objects
  my %components;
#========================================================================

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public ISGA::ComponentBuilder new(Component $component);

Initialize the Componentbuilder object corresponding to the supplied 
Component.

=item public ISGA::ComponentBuilder new(Component $component, ParameterMask $mask);

Initialize the Componentbuilder object corresponding to the supplied 
Component and parameter mask.

=cut
#------------------------------------------------------------------------
  sub new {

    my ($class, $component, $mask) = @_;

    return undef unless( defined $components{ $component });

    my $self = clone($components{$component});

    if ( $mask ) {
      return $self->injectMaskValues( $mask, $component );
    }
    
    return $self;
  }

#------------------------------------------------------------------------

=item PRIVATE void _initialize()

Initialize the ComponentBuilder Template object corresponding to
the supplied component template.

=cut
#------------------------------------------------------------------------
  sub _initialize {

    my $self = shift;
    
    my $hideID = "optional_hide";
    
    if ( exists $self->{Params} ) {

      # initialize PiplineBuilder form
      $self->{PipelineBuilder}{FormEngine} = {'templ' => 'fieldset',
					      'OUTER' => '1', 
					      'sub' => []};
      
      my @required = ();
      my @optional = ();
      
      for (@{$self->{Params}}){
      
	$$_{'LABEL'} = $$_{'NAME'};
	
	if (not(exists $$_{'templ'}) || $$_{'templ'} eq 'text'){
	  exists $$_{MAXLEN} or $$_{'MAXLEN'} = 60;
	  exists $$_{SIZE} or $$_{'SIZE'} = 60;
	if (exists $$_{'REQUIRED'}){
	  push(@{$$_{'ERROR'}}, 'not_null', 'Text::checkHTML');
	}
	}
	
	if (exists $$_{'REQUIRED'}){
	  push(@required, $_);
	}else{
          push(@optional, $_);
        }
      }
      
      if (@required) {
	push @{$self->{PipelineBuilder}{FormEngine}{sub}},
	  {'templ' => 'fieldset', 
	   'TITLE' => 'Required Parameters',
	   'NESTED' => '1',
	   'sub' => \@required};
      }
      
      if (@optional and @required){
	push @{$self->{PipelineBuilder}{FormEngine}{sub}},
	     {'templ' => 'fieldset',
	      'TITLE' => 'Optional Parameters',
	      'JSHIDE' => $hideID,
	      'NESTED' => '1',
	      'sub' => \@optional};
      }elsif(@optional and not @required){
        push @{$self->{PipelineBuilder}{FormEngine}{sub}},
             {'templ' => 'fieldset',
              'TITLE' => 'Optional Parameters',
              'NESTED' => '1',
              'sub' => \@optional};
      }
    }

    # handle RBI parameters
    if ( exists $self->{InputParams} ) {

      my %inputs;

      my @all_rbi;

      for ( @{$self->{InputParams}} ) {

	if (not(exists $_->{'templ'}) || $_->{'templ'} eq 'text'){
	  exists $_->{MAXLEN} or $_->{'MAXLEN'} = 60;
	  exists $_->{SIZE} or $_->{'SIZE'} = 60;
	  if (exists $_->{'REQUIRED'}){
	    push(@{$_->{'ERROR'}}, 'not_null', 'Text::checkHTML');
	  }
	}	
	
	my $name = $_->{input};
	push @{$inputs{$name}}, $_;
	push @all_rbi, $_;
      }

      $self->{RunBuilderInput} = \%inputs;
      $self->{AllRunBuilderInput} = { sub => \@all_rbi };
    }
    
    # handle RunBuilder parameters
    if ( exists $self->{RunBuilderParams} ) {
      
      my @runbuilder;

      for ( @{$self->{RunBuilderParams}} ) {
	
	$$_{'LABEL'} = $$_{'NAME'};
	
	if (not(exists $$_{'templ'}) || $$_{'templ'} eq 'text'){
	  exists $$_{MAXLEN} or $$_{'MAXLEN'} = 60;
	  exists $$_{SIZE} or $$_{'SIZE'} = 60;
	  if (exists $$_{'REQUIRED'}){
	    push(@{$$_{'ERROR'}}, 'not_null', 'Text::checkHTML');
	  }
	}
	
	push @runbuilder, $_;
      }
      
      $self->{RunBuilder}{FormEngine} = { templ => 'fieldset',
					   'sub' => \@runbuilder,
                                          'CLASS' => 'runbuilderForm',
					 };
    }

  }

#------------------------------------------------------------------------

=item PRIVATE ComponentBuilder _initializeComponent(Component $component);

Initialize the Component form object corresponding to the supplied component
and component template.

=cut
#------------------------------------------------------------------------
  sub _initializeComponent {
    
    my ($self, $component) = @_;

    my $clone = clone($self);
    $clone->{ParameterLookup} = {};
    
    my @fieldsets;

    if ( exists $clone->{Params} ) {

      delete $clone->{Params};
      $clone->{PipelineBuilder}{FormEngine}{TITLE} = $component->getName;

      push @fieldsets, @{$clone->{PipelineBuilder}{FormEngine}{sub}};
    }

    if ( exists $clone->{RunBuilderParams} ) {

      delete $clone->{RunBuilderParams};
      push @fieldsets, $clone->{RunBuilder}{FormEngine};
    }

    if ( exists $clone->{InputParams} ) {

      delete $clone->{InputParams};

      push @fieldsets, $clone->{AllRunBuilderInput};
    }

    foreach my $fieldset ( @fieldsets ) {
      foreach ( @{$fieldset->{sub}} ) {
	
	# create shortcut to parameter from name
	$clone->{ParameterLookup}{ $_->{NAME} } = $_;
	$$_{'COMPONENT'} = $component->getName;
	$$_{TIP} =
          "/Component/GetParameterDescription?component=$component&name=$_->{NAME}";
      }
    }

    return $clone;
  }
  
#========================================================================

=head2 ACCESSORS

=over 4

=cut
##========================================================================

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

=item public [hashref] getRunBuilderInputParameters(PipelineInput $pi);

Returns the run builder parameters input params for this component and the supplied input.

=cut
#------------------------------------------------------------------------
sub getRunBuilderInputParameters { 

  my ($self, $pi) = @_;
  
  my $name = $pi->getClusterInput->getName();

  if ( exists $self->{RunBuilderInput}{$name} ) {
    return $self->{RunBuilderInput}{$name};
  }

  return [];
}

#------------------------------------------------------------------------

=item public [hashref] getRunBuilderParameters();

Returns the run builder parameters for this component.

=cut
#------------------------------------------------------------------------
sub getRunBuilderParameters { 

  my $self = shift;

  if ( exists $self->{RunBuilder}{FormEngine} ) {
    return $self->{RunBuilder}{FormEngine}{sub};
  }

  return [];
}

#------------------------------------------------------------------------

=item public string getParameterDescription( string name );

Returns the tip/description associated with the supplied parameter name.

=cut
#------------------------------------------------------------------------
sub getParameterDescription {

  my ($self, $param) = @_;

  exists $self->{ParameterLookup}{$param} or return '';
  return $self->{ParameterLookup}{$param}{DESCRIPTION};
}

#------------------------------------------------------------------------

=item public string getComponentDescription( string name );

Returns the tip/description associated with the component.

=cut
#------------------------------------------------------------------------
sub getComponentDescription { return shift->{Description}; }

#------------------------------------------------------------------------

=item public HashRef getForm( );

Returns the FormEngine portion of the ComponentBuilder

=cut

#------------------------------------------------------------------------
sub getForm { return shift->{PipelineBuilder}{FormEngine}; }

#------------------------------------------------------------------------

=item public HashRef getRunBuilderForm( );

Returns the FormEngine portion of the ComponentBuilder

=cut

#------------------------------------------------------------------------
sub getRunBuilderForm { return shift->{RunBuilder}{FormEngine}; }


#------------------------------------------------------------------------

=item public ISGA::ComponentBuilder injectMaskValues(ParameterMask $mask, Component $component);

Returns a cloned ComponentBuilder with ParameterMask values injected in

=cut

#------------------------------------------------------------------------
  sub injectMaskValues{

    my ($self, $parameter_mask, $component) = @_;
    
    my $mask_params = exists $parameter_mask->{Component}->{$component} ?
      $parameter_mask->{Component}->{$component} : undef;
    
    foreach (keys %$mask_params){
      $self->{ParameterLookup}{$_}{VALUE} = $mask_params->{$_}->{Value};
      $self->{ParameterLookup}{$_}{ANNOTATION} = $mask_params->{$_}->{Description};
    }

    return $self;
  }

#------------------------------------------------------------------------

=item Class Initialization

YAML files are loaded and cached at server startup.

=cut

#------------------------------------------------------------------------

  my $schema = YAML::LoadFile('___package_include___/schema/component_definition_kwalify.yaml');

  foreach my $template ( @{ISGA::ComponentTemplate->query()} ) {
    
    my $file = '___package_include___/component_definition/' . $template->getFormPath;

    if ( -f $file ) {
      
      my $self = YAML::LoadFile($file);
      validate( $schema, $self );

      $self->_initialize();
      
      foreach ( @{ISGA::Component->query( Template => $template )} ){
        $components{$_} = $self->_initializeComponent($_);
      }    
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
