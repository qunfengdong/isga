package ISGA::Component::PairedInput;

use warnings;
use strict;

use base 'ISGA::Component';

#------------------------------------------------------------------------

=item public string getValue(RunBuilder $rb);

Calculates the file name(s) for a component input value.
$self->getDecoratedInputValue($_, $value)
=cut 
#------------------------------------------------------------:------------
sub getDecoratedInputValue {
  my ($self, $ci, $string) = @_;
   # return "-y $string" if $ci->getName eq 'Shore_Input_Pair';
  # add -y to paired input file
   if (  ($ci->getName eq 'Shore_Input_Pair') &&  (length($string)>1) ) { 
      return "-y $string";
    }
    
	 return $string;
}

1;
