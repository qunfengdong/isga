package SysMicro::ClusterBuilder;

#------------------------------------------------------------------------

=head1 NAME

B<SysMicro::ClusterBuilder> manages loading YAML definitions for pipeline clusters, and providing FormEngine parameter arrays.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;
use YAML;
use Data::Dumper;
use Kwalify qw(validate);
use SysMicro::Cluster;

{

  # private variable for caching form objects
  my %forms;

#========================================================================

=back

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public SysMicro::ClusterBuilder new(Cluster $cluster);

Initialize the ClusterBuilder object corresponding to the supplied cluster.

=cut
#------------------------------------------------------------------------
  sub new { return $forms{ $_[1] }; }


#------------------------------------------------------------------------

=item PRIVATE void _initialize(Cluster $cluster);

Manipulates YAML to create needed FormEngine data structure.

=cut
#------------------------------------------------------------------------
  sub _initialize {
    
    my ($self, $cluster) = @_;

    $self->{FormEngine} = [];

    $self->{ParameterLookup} = {};

    my $i = 0;

    for (@{$self->{Components}}){
      if (exists $_->{'params'}){
	
	my $hideID = $i."_optional_hide";
	push (@{$self->{FormEngine}}, 
	      {'templ' => 'fieldset', 
	       'TITLE' => $_->{'title'},
               'OUTER' => '1', 
	       'sub' => []});

        my $component_title = $_->{'title'};
        my @required = ();
        my @optional = ();

	for (@{$_->{params}}){
	  $$_{'LABEL'} = $$_{'NAME'};
          $$_{'COMPONENT'} = $component_title;
	  # create shortcut to parameter from name
	  $self->{ParameterLookup}{ $_->{NAME} } = $_;

	  # set TIP to Description url 
	  $_->{TIP} = 
	    "/Cluster/GetParameterDescription?cluster=$cluster&name=$_->{NAME}";

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
        if (@required){
          push(@{${@{$self->{FormEngine}}[$i]}{'sub'}}, {'templ' => 'fieldset', 
                                                         'TITLE' => 'Required Parameters',
                                                         'NESTED' => '1',
                                                         'sub' => \@required});
        }
        if (@optional){
          push(@{${@{$self->{FormEngine}}[$i]}{'sub'}}, {'templ' => 'fieldset',
                                                         'TITLE' => 'Optional Parameters',
                                                         'JSHIDE' => $hideID,
                                                         'NESTED' => '1',
                                                         'sub' => \@optional});
        }
	$i++;
      }
    }
  }
#========================================================================

=head2 ACCESSORS

=over 4

=cut
#========================================================================

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

=item public string getClusterDescription( );

Returns the tip/description associated with the supplied parameter name.

=cut
##------------------------------------------------------------------------
sub getClusterDescription { return shift->{Description}; }


#------------------------------------------------------------------------

=item public [ComponentBuilder] getComponents();

Returns a reference to an array of ComponentBuilder objects
representing the components run as part of this cluster.

=cut
##------------------------------------------------------------------------
sub getComponents {

  my $self = shift;

  return [ map { bless $_, 'SysMicro::ComponentBuilder' } @{$self} ];
}

#========================================================================

=head2 METHODS

=over 4

=cut
#========================================================================


#------------------------------------------------------------------------

=item public [parameter] buildForm();

Returns the FormEngine array.

=cut
#------------------------------------------------------------------------
# return reference to array to avoid large copy
# but, in the future we may want a copy to apply user values to array
  sub buildForm{ return shift->{FormEngine}; }


#------------------------------------------------------------------------

=item public SysMicro::ClusterBuilder injectMaskValues(PipelineBuilder $builder, Cluster $cluster);
=item public SysMicro::ClusterBuilder injectMaskValues(Pipeline $pipeline, Cluster $cluster);

Returns a cloned ClusterBuilder with ParameterMask values injected in

=cut
#------------------------------------------------------------------------
sub injectMaskValues{

  use Clone qw(clone);

  my ($self, $pipeline_builder, $cluster) = @_;

  my $cloned = clone($self->{FormEngine});  
  my $parameter_mask = $pipeline_builder->getParameterMask();
  my $mask_params = exists $parameter_mask->{ Cluster }->{ $cluster } ? $parameter_mask->{ Cluster }->{ $cluster } : undef;
  foreach (@{$cloned}){
    foreach (@{$$_{sub}}){
       foreach (@{$$_{sub}}){
         if(defined $mask_params->{$$_{NAME}}){
            $$_{VALUE} = $mask_params->{$$_{NAME}}->{Value};
	    $$_{ANNOTATION} = $mask_params->{$$_{NAME}}->{Description};
         }
       }
    }
  }
  return $cloned;
}

  foreach ( @{SysMicro::Cluster->query()} ) {
    if ( -f ( '___include_root___/cluster_definition/' . $_->getFormPath ) ) {
      validate( 
   YAML::LoadFile('___include_root___/schema/cluster_definition_kwalify.yaml'), 
	       YAML::LoadFile('___include_root___/cluster_definition/' . $_->getFormPath));
      my $self = YAML::LoadFile('___include_root___/cluster_definition/' . $_->getFormPath);
      $self->_initialize($_);
      $forms{ "$_" } = $self;
    }else{
#          warn "Skipping ", $_->getName;
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
