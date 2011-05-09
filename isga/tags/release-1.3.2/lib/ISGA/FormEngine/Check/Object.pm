package ISGA::FormEngine::Check::Object;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::Check provides convenient form verification
methods tied to the FormEngine system.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string existsByName(string value, Form form, string caller, string class);

Asserts that an opject of class exists with the provided value as a name.

=cut
#------------------------------------------------------------------------
sub existsByName {

  my ($value, $form, $caller, $class) = @_;

  if ( ! $class->exists( Name => $value ) ) {

    $class =~ s/ISGA:://;
    return "$value is not a valid $class";
  }

  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('Object::existsByName');

  
1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
