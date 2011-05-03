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

use ISGA;

my $today = ISGA::Date->new();
my $raw_data_persist = ISGA::Variable->value('raw_data_retention');

# retrieve all runs that aren't expired
foreach my $run ( @{ISGA::Run->query( RawDataStatus => 'Available' )} ) {

  warn "found run $run\n";

  # expire canceled runs imediately
  if ( $run->getStatus eq 'Canceled' ) {

    warn "tagging up canceled run $run\n";

    $run->edit( RawDataStatus => 'Tagged for Deletion' );
    
  } elsif ( $run->getStatus eq 'Complete' ) {
    
    my $expires = $run->getFinishedAt->getDate() + "${raw_data_persist}D";

    if ( $expires < $today ) {

      warn "tagging old run $run\n";

      $run->edit( RawDataStatus => 'Tagged for Deletion' );
    }
  }
}
