package ISGA::FormEngine::Check::Number;
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

use List::Util qw(first);

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string matches(number value, Form form, string caller, ARRAY number);

Asserts that the value matches one of the provided numbers.

=cut 
#------------------------------------------------------------------------
sub matches {

  my ($value, $form, $caller, @numbers) = @_;

  if (not ($value =~ /^\-?\d*\.?\d+$/o)){
    return 'Input is not a number.';
  }  
  
  my $first = first { $value == $_ } @numbers;

  if ( ! defined $first ) {
    return "Value must match one of " . join (',', @numbers);
  }

  return '';
}

#------------------------------------------------------------------------

=item public string isBetween(string value, Form form, string caller, number min, number max);

Asserts that the number supplied is between min and max, inclusive.

=cut 
#------------------------------------------------------------------------
sub isBetween {

  my ($value, $form, $caller, $min, $max) = @_;

  if (not ($value =~ /^\-?\d*\.?\d+$/o)){
    return 'Input is not a number.';
  }  

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

#------------------------------------------------------------------------

=item public string isGreaterOrEqualFormValue(string value, Form form, string caller, string value, string value);

Asserts that the input values supplied are the same

=cut
#------------------------------------------------------------------------
sub isGreaterOrEqualFormValue {

  my ($value, $form, $caller, $input1, $input2, $title) = @_;

  my $value1 = $form->get_input($input1);
  my $value2 = $form->get_input($input2);

  if ( $value1 < $value2 ) {
    return "Value for this input must be greater than or equal to the value for $title.";
  }

  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('Number::matches');
ISGA::FormEngine::SkinUniform->_register_check('Number::isBetween');
ISGA::FormEngine::SkinUniform->_register_check('Number::isNumber');
ISGA::FormEngine::SkinUniform->_register_check('Number::isPositive');
ISGA::FormEngine::SkinUniform->_register_check('Number::isScientificNotation');
ISGA::FormEngine::SkinUniform->_register_check('Number::isInteger');
ISGA::FormEngine::SkinUniform->_register_check('Number::isGreaterThan');
ISGA::FormEngine::SkinUniform->_register_check('Number::isGreaterOrEqualFormValue');
1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
