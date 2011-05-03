package ISGA::RunBuilder::CeleraAssembly;

use warnings;
use strict;

use base 'ISGA::RunBuilder';

#------------------------------------------------------------------------

=item public bool hasRunParameters();

Returns false since the Celera pipeline has no run parameters.

=cut
#------------------------------------------------------------------------
  sub hasRunParameters { return 0; }

#------------------------------------------------------------------------

=item public bool hasUnconfiguredParameters();

Returns false since the Celera pipeline has no run parameters.

=cut
#------------------------------------------------------------------------
  sub hasUnconfiguredParameters { return 0; }

1;
