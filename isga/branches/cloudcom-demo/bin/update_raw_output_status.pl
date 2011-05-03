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

# retrieve all runs that aren't expired
foreach my $run ( @{ISGA::Run->query( RawDataStatus => 'Available' )} ) {

  # expire canceled runs imediately
  if ( $run->getStatus eq 'Canceled' ) {

    $run->edit( RawDataStatus => 'Tagged for Deletion' );
    
  } elsif ( $run->getStatus eq 'Complete' ) {

    my $uc = $run->getCreatedBy->getUserClass();
    my $rdp = ISGA::UserClassConfiguration->value('raw_data_retention', UserClass => $uc);
    
    my $expires = $run->getFinishedAt->getDate() + "${rdp}D";

    if ( $expires < $today ) {

      $run->edit( RawDataStatus => 'Tagged for Deletion' );
    }
  }
}
