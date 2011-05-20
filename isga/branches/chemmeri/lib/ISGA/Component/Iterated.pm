package ISGA::Component::Iterated;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::Component::Iterated> subclass for components created through
iteration that exist in Ergatis, but not the ISGA database.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use base 'ISGA::Component';

#========================================================================

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public ISGA::Component new(integer $id, integer $iteration);

Initializes the Component object with the supplied iteration.

=cut
#------------------------------------------------------------------------
  sub new {

    my ($class, $id, $iteration) = @_;

    my $self = $class->NEXT::new(Id => $id);

    $self->{iteration} = $iteration;

    return $self;
  }

#========================================================================

=back

=head2 ACCESSORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public int getIteration();

Returns the name of this components config file.

=cut 
#------------------------------------------------------------------------
  sub getIteration { return shift->{iteration}; }

#------------------------------------------------------------------------

=item public string getConfigFileName();

Returns the name of this components config file.

=cut 
#------------------------------------------------------------------------
   sub getConfigFileName {

     my $self = shift;

     return $self->SUPER::getErgatisName() . '.config';
   }

#------------------------------------------------------------------------

=item public string getBaseErgatisName();

Returns the ergatis name for this component without an iterator

=cut
#------------------------------------------------------------------------
  sub getBaseErgatisName {

    my $self = shift;

    return $self->SUPER::getErgatisName();
  }

#------------------------------------------------------------------------

=item public string getErgatisName();

Returns the ergatis name for this component.

=cut
#------------------------------------------------------------------------
  sub getErgatisName {

    my $self = shift;

    return $self->NEXT::getErgatisName() . $self->{iteration};
  }


1;
