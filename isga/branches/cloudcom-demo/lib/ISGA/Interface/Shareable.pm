package ISGA::Interface::Shareable;
#------------------------------------------------------------------------

=head1 NAME

ISGA::Interface::Shareable 

=head1 SYNOPSIS

Classes implementing this interface are obliged to provide several
methods for operating on objects that are ownable and by extension
shareable.

=head1 DESCRIPTION

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

=item public boolean isOwnedBy(Account $account);

Returns true if this object is owned by the supplied account, and false otherwise.

=cut
#------------------------------------------------------------------------
  sub isOwnedBy {

    my ($self, $account) = @_;

    # by default a class tests ownership by testing against it's creator
    return $account == $self->getCreatedBy();
  }

#------------------------------------------------------------------------

=item public boolean mayBeReadBy(Account $account);

Returns true if this object is owned by the supplied account, and false otherwise.

=cut
#------------------------------------------------------------------------
  sub mayBeReadBy {

    my ($self, $party) = @_;

    # default implementation

    # first check if the party is our owner
    if ( $party->isa('ISGA::Account') ) {
      $self->isOwnedBy($party) and return 1;
    }

    return ISGA::ResourceShare->query( Party => $party->getParties(),
				       Resource => $self,
				       ResourceClass => $self->class() );
  }

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4   

=item

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
