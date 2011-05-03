package SysMicro::ComponentBuilder;

#------------------------------------------------------------------------

=head1 NAME

B<SysMicro::ComponentBuilder> provides convenience methods for
interacting with the component definitions that make up the
ClusterBuilder object.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;


#========================================================================

=head2 ACCESSORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string getName();

Returns the formal name for this component.

=cut
#------------------------------------------------------------------------
sub getName { return shift->{TITLE}; }

#------------------------------------------------------------------------

=item public [hashref] getRequiredParameters();

Returns the required parameters for this component.

=cut
#------------------------------------------------------------------------
sub getRequiredParameters { 

  my $self = shift;

  my ( $req ) = grep { $_->{TITLE} eq 'Required Parameters' } @{$self->{sub}};

  return $req ? $req->{sub} : [];
}

#------------------------------------------------------------------------

=item public [hashref] getOptionalParameters();

Returns the optional parameters for this component.

=cut
#------------------------------------------------------------------------
sub getOptionalParameters { 

  my $self = shift;

  my ( $opt ) = grep { $_->{TITLE} eq 'Optional Parameters' } @{$self->{sub}};

  return $opt ? $opt->{sub} : [];
}

#------------------------------------------------------------------------

=item public [hashref] getSetOptionalParameters();

Returns the optional parameters for this component that have a set value.

=cut
#------------------------------------------------------------------------
sub getSetOptionalParameters { 

  my $self = shift;

  my ( $opt ) = grep { $_->{TITLE} eq 'Optional Parameters' } @{$self->{sub}};

  $opt or return [];

  return [grep { exists $_->{VALUE} } @{$opt->{sub}}];
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
