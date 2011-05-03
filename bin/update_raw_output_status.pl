use strict;
use warnings;

#------------------------------------------------------------------------

=head1 NAME

<update_raw_output_status.pl> - monitors the time since completed runs
to notify users when their raw output may be deleted.

=head1 DESRIPTION

This script simply grabs all the runs whose raw data is still
available and checks to see if it has reached the 'Tagged For
Deletion' cutoff.

=head1 FREQUENCY

As the cutoff is defined in days, running this script once per day is
sufficient.

=cut
#------------------------------------------------------------------------

use lib '/data/web/isga.cgb/docs/lib';

use SysMicro;
use SysMicro::X;
use SysMicro::Login;
use SysMicro::Log;
use SysMicro::Site;


