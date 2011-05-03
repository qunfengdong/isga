package ISGA::Component::MethylType;

use warnings;
use strict;

use base 'ISGA::Component';

#------------------------------------------------------------------------

=item public string formatArrayParam(Component $c);

Formats an array of values for a component input value.

=cut 
#------------------------------------------------------------------------
sub formatArrayParam {
  my ($self, $values) = @_;
    my $string = join(':', @{$values});    
    return $string;
}

1;
