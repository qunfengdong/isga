package ISGA::ParameterMask;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::ParameterMask is an object wrapper around a YAML piece that
describes which parameters of a global pipleline a user edits.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use YAML;
use Scalar::Util qw( reftype );


use overload
  q{""}  => sub { return YAML::Dump($_[0]); };

#========================================================================

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public ParameterMask new(string $yaml);

Creates a new mask object based on the YAML string provided.

=cut
#------------------------------------------------------------------------
sub new {
  my ($class, $yaml) = @_;

  # other wise read string into YAML
  my $self = YAML::Load($yaml);

  (reftype($self) and reftype($self) eq 'HASH') or $self = {};

  # if we had an empty parameter mask we need to force the class
  if (  ref($self) ne $class ) {
    bless $self, $class;
  }

  return $self;
}

#========================================================================

=head2 ACCESSORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public HashRef getComponent(Component $component);

Returns the portion of the mask for the supplied component.

=cut
#------------------------------------------------------------------------
sub getComponent {

  my ($self, $component) = @_;

  exists $self->{Component} or return {};

  return exists $self->{Component}{$component} ? $self->{Component}{$component} : {};
}

#========================================================================

=head2 MUTATORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void injectMaskValues(ParameterMask $mask);

Inject values of the supplied ParameterMask over the current object.

=cut
#------------------------------------------------------------------------
sub injectMaskValues {

  my ($self, $mask) = @_;

  # process all the components in the  new mask
  while ( my ($component, $mask_params) = each %{$mask->{Component}} ) {
    while ( my ($var, $value) = each %$mask_params ) {
      $self->{Component}{$component}{$var} = $value;
    }  
  }
}

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=item X::API::Parameter

=item X::API::Compare

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut

