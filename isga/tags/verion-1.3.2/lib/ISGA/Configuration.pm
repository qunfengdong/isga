package ISGA::Configuration;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::Configuration is a base class for the various configuration parameters.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;


my %getters = ( 'boolean' => '_getBoolean' );

#========================================================================

=head2 ACCESSORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string getFormattedValue();

Returns the formatted value for this object.

=cut 
#------------------------------------------------------------------------
sub getFormattedtValue {

  my $self = shift;

  my $method = $getters{ $self->getVariable->getDataType };

  return $self->$method( $self->getValue() );
}

sub _getBoolean {

  my ($self, $value) = @_;
  return ( $value ? 'TRUE' : 'FALSE' );
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
