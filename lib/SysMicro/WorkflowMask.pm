package SysMicro::WorkflowMask;
#------------------------------------------------------------------------
=pod

=head1 NAME

SysMicro::WorkflowMask is an object wrapper around a YAML piece that
describes which components of a global pipleline a user pipeline
executes.

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


# need to override string method to save

#------------------------------------------------------------------------

=item public WorkflowMask new(string $yaml);

Creates a new mask object based on the YAML string provided.

=cut
#------------------------------------------------------------------------
sub new {

  my ($class, $yaml) = @_;

  my $self = YAML::Load($yaml);

  exists $self->{stop} or $self->{stop} = [];
  exists $self->{start} or $self->{start} = [];

  return $self;
}

#------------------------------------------------------------------------

=item public [int] getStart();

Returns an array reference to start clusters in the workflow.

=cut
#------------------------------------------------------------------------
sub getStart { return $_[0]->{start}; }

#------------------------------------------------------------------------

=item public [int] getStop();

Returns an array reference to stop clusters in the workflow.

=cut
#------------------------------------------------------------------------
sub getStop { return $_[0]->{stop}; }

#------------------------------------------------------------------------

=item public void setStart([int] $start);

Returns an array reference to start clusters in the workflow.

=cut
#------------------------------------------------------------------------
sub setStart { $_[0]->{start} = $_[1]; }

#------------------------------------------------------------------------

=item public void setStop([int] $stop);

Returns an array reference to stop clusters in the workflow.

=cut
#------------------------------------------------------------------------
sub setStop { $_[0]->{stop} = $_[1]; }

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

