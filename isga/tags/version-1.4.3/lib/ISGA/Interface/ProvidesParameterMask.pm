package ISGA::Interface::ProvidesParameterMask;
#------------------------------------------------------------------------

=head1 NAME

ISGA::Interface::ProvidesParameterMask 

=head1 SYNOPSIS

Classes implementing this interface are obliged to provide several
methods for operating on parameter masks.

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

=item ABSTRACT public ComponentBuilder getComponentBuilder(Component $component);

Returns a component builder with this objects parameter mask applied.

=cut
#------------------------------------------------------------------------
  sub getComponentBuilder {

    my $class = shift;
    X::API::UnrealizedMethod->throw( class => $class, method => 'getComponentBuilder' );
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
