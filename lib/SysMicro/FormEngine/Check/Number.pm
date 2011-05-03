package SysMicro::FormEngine::Check::Number;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::Check provides convenient form verification
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

=item public string isBetween(string value, Form form, string caller, number min, number max);

Asserts that the number supplied is between min and max, inclusive.

=cut 
#------------------------------------------------------------------------
sub isBetween {

  my ($value, $form, $caller, $min, $max) = @_;

  if ( $value > $max or $value < $min ) {
    return "Value must be between $min and $max";
  }

  return '';
}

#------------------------------------------------------------------------

=item public string isNumber(string value, Form form);

Asserts that the number supplied is either an interger or decimal.

=cut

#------------------------------------------------------------------------
sub isNumber {
  my ($value, $form) = @_;
  return '' if($value eq '');
  if (not ($value =~ /^\-?\d*\.?\d+$/o)){
    return 'Input is not a number.';
  }

  return '';
}

#------------------------------------------------------------------------

=item public string isPositive(string value, Form form);

Asserts that the number supplied is positive.

=cut

#------------------------------------------------------------------------
sub isPositive {
  my ($value, $form) = @_;
  return '' if($value eq '');
  if ($value =~ /^\-/o){
    return 'Input must be a positive number.';
  }

  return '';
}

#------------------------------------------------------------------------

=item public string isScientificNotation(string value, Form form);

Asserts that the number supplied is in Scientific Notation

=cut

#------------------------------------------------------------------------
sub isScientificNotation {
  my ($value, $form) = @_;
  return '' if($value eq '');
  if (not ($value =~ /^\d+(e\-?\d+)?$/o)){
    return 'Input is not in proper format. ex: 1e-5';
  }
  return '';
}

#------------------------------------------------------------------------

=item public string isInteger(string value, Form form);

Asserts that the number supplied is an interger.

=cut

#------------------------------------------------------------------------
sub isInteger {
  my ($value, $form) = @_;
  return '' if($value eq '');
  if (not ($value =~ /^-?\d+$/o)){
    return 'Input is not an integer';
  }
  return '';
}

#------------------------------------------------------------------------

=item public string isGreaterThan(string value, Form form, string caller, number min);

Asserts that the number supplied is greater than min, exclusive of min.

=cut
#------------------------------------------------------------------------
sub isGreaterThan {

  my ($value, $form, $caller, $min) = @_;

  if ( $value <= $min ) {
    return "Value must be greater than $min";
  }
  return '';
}


SysMicro::FormEngine::SkinUniform->_register_check('Number::isBetween');
SysMicro::FormEngine::SkinUniform->_register_check('Number::isNumber');
SysMicro::FormEngine::SkinUniform->_register_check('Number::isPositive');
SysMicro::FormEngine::SkinUniform->_register_check('Number::isScientificNotation');
SysMicro::FormEngine::SkinUniform->_register_check('Number::isInteger');
SysMicro::FormEngine::SkinUniform->_register_check('Number::isGreaterThan');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
