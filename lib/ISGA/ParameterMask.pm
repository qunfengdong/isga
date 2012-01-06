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

use overload
  q{""}  => sub { return YAML::Dump($_[0]); };

#------------------------------------------------------------------------

=item public ParameterMask new(string $yaml);

Creates a new mask object based on the YAML string provided.

=cut
#------------------------------------------------------------------------
sub new {
  my ($class, $yaml) = @_;

  # other wise read string into YAML
  my $self = YAML::Load($yaml);

  exists $self->{Component} or $self->{Component} = {};

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

