package ISGA::Test::Transactions;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::Test::Transactions - provides Transaction attribute for test
methods so that tests are performed in a database transaction that is
aborted after completion.

=head1 METHODS

=over 4

=item use

=back

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use Attribute::Handlers;

sub Transaction :ATTR {

  my ($package, $symbol, $referent, $attr, $data) = @_;

  my $subname = $package . '::' . *{$symbol}{NAME};

  no strict 'refs';

  no warnings;

  # rewrite the original subroutine to be performed in a transaction that is rolled back
  *{$subname} = sub {
    eval { ISGA::DB->begin_work(); $referent->(@_); };
    ISGA::DB->rollback();
  }
}

1;

__END__

=back

=head1 DIAGNOSTICS

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
