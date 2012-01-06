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

=item public ISGA::PipelineDefinition new(Run $run);

Initializes the PipelineDefinition for the supplied Run.

=cut
#------------------------------------------------------------------------
  sub new {

    my ($class, $pipeline, $mask) = @_;
    
    # make sure we have a global pipeline and it is defined
    $pipeline = $pipeline->getGlobalTemplate();
    defined $pipelines{$pipeline} or X::API->throw( message => "Unable to find definition for pipeline $pipeline" );
    
    my $self = clone($pipelines{$pipeline});
    
    if ( $mask ) {
      #    return $pipeline->injectMaskValues($mask, $self);
    }
    
    return $self;  
  }

  sub newByPipeline {

    my ($class, $pipeline) = @_;
    
    my $global_template = $pipeline->getGlobalTemplate();
    defined $pipelines{$global_template} or X::API->throw( message => "Unable to find definition for pipeline $global_template" );
    
    my $self = clone($pipelines{$global_template});

    if ( $pipeline->isa('ISGA::UserPipeline') ) {

      # process the WorkflowMask

    }

    return $self;
  }

  sub newByRunBuilder {
    
    my ($class, $run_builder) = @_;

    # retrieve the global pipeline
    my $pipeline = $run_builder->getPipeline;
    
    my $self = $class->newByPipeline($pipeline);
    
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
  }

#------------------------------------------------------------------------

=item PRIVATE void _initialize()

Initialize the PipelineDefinition object.

=cut
#------------------------------------------------------------------------
  sub _initialize {

    my $self = shift;

    $self->{ParameterLookup} = {};

    # handle RunBuilder parameters
    if ( exists $self->{Params} ) {
      
      my @runbuilder;

      for ( @{$self->{Params}} ) {
	$self->_processParameterForForm($_);
	push @runbuilder, $_;
	$self->{ParameterLookup}{$_->{NAME}} = $_;
      }
      
      $self->{RunBuilder}{FormEngine} = { templ => 'fieldset',
					  'sub' => \@runbuilder,
                                          'CLASS' => 'runbuilderForm',
					};
    }
  }

#========================================================================

=head2 ACCESSORS

=over 4

=cut
#========================================================================

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

=item public hashRef getParameterForm();

Returns the FormEngine portion of the RunBuilder parameters.

=cut
#------------------------------------------------------------------------
  sub getParameterForm { return shift->{RunBuilder}{FormEngine}; }

#------------------------------------------------------------------------

=item public hashRef getFilteredParameters(Component $component);

Returns a hash ref containing any filtered component parameters as keys.

=cut
#------------------------------------------------------------------------
  sub getFilteredParameters {
    
    my ($self, $component) = @_;
    
    my %filtered = ();
    
    my $erg = $component->getErgatisName;
    
    if ( exists $self->{Components}{$erg} and exists $self->{Components}{$erg}{FilteredParams} ) {
      foreach ( @{$self->{Components}{$erg}{FilteredParams}} ) {
	$filtered{$_} = undef;
      }
    }

    return \%filtered;
  }

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

=item PRIVATE hashRef _processParameterForForm(hashRef parameter);

Processes the YAML definition of a parameter to prepare it for FormEngine.

=cut
#------------------------------------------------------------------------
sub _processParameterForForm {

  my $self = shift;
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
  
  foreach my $pipeline ( @{ISGA::GlobalPipeline->query()} ) {

    my $form_path = $pipeline->getFormPath;
    my $self = YAML::LoadFile($form_path);
    $self->_initialize();
    
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
