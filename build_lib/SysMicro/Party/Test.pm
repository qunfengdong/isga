package SysMicro::Party::Test;
#------------------------------------------------------------------------
=pod

=head1 NAME

SysMicro::Party::Test - test methods for the account class.

=head1 METHODS

=over 4

=item _0_use

=item _1_methods

=item _2_attributes

=back

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use Test::Deep qw(cmp_deeply bag);
use Test::Exception;
use Test::More;

use SysMicro;

use SysMicro::Test::Transactions;

use base 'Test::Class';

my $class = 'SysMicro::Party';

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void _0_use();

Test use of this class.
 
=cut
#------------------------------------------------------------------------
sub _0_use : Test(1) {

  use_ok( $class );
}

#------------------------------------------------------------------------

=item public void _1_methods();

Test method availability in this class.
 
=cut
#------------------------------------------------------------------------
sub _1_methods : Test(24) {
  
  # methods inherited from indexed
  can_ok( $class, 'new' );
  can_ok( $class, 'getId' );
  can_ok( $class, 'edit' );
  can_ok( $class, '_column' );
  can_ok( $class, '_icmp' );
  can_ok( $class, '_scmp' );
  can_ok( $class, 'delete' );
  can_ok( $class, 'create' );
  can_ok( $class, 'query' );
  can_ok( $class, 'exists' );
  can_ok( $class, '_set_page' );
  can_ok( $class, '__read' );
  can_ok( $class, '__read_cache' );
  can_ok( $class, '__read_and_add_to_cache' );

  # methods inherited from Party.base
  can_ok( $class, 'getPartyPartition' );
  can_ok( $class, 'getName' );
  can_ok( $class, 'getStatus' );
  can_ok( $class, 'getInstitution' );
  can_ok( $class, 'isPrivate' );

  can_ok( $class, '__update' );
  can_ok( $class, '__create' );
  can_ok( $class, '__base_read' );
  can_ok( $class, '_table' );
  can_ok( $class, '_sequence' );
}

#------------------------------------------------------------------------

=item public void _2_attributes();

Test that class can find its attributes.
 
=cut
#------------------------------------------------------------------------
sub _2_attributes : Test(13) {

  is( $class->_table(), 'party' );

  is( $class->_table('Id'), 'party' );
  is( $class->_table('PartyPartition'), 'party' );
  is( $class->_table('Name'), 'party' );
  is( $class->_table('Status'), 'party' );
  is( $class->_table('Institution'), 'party' );
  is( $class->_table('IsPrivate'), 'party' );

  is( $class->_column('Id'), 'party_id' );
  is( $class->_column('PartyPartition'), 'partypartition_id' );
  is( $class->_column('Name'), 'party_name' );
  is( $class->_column('Status'), 'partystatus_id' );
  is( $class->_column('Institution'), 'party_institution' );
  is( $class->_column('IsPrivate'), 'party_isprivate' );


}

1;

__END__

=back

=head1 DIAGNOSTICS

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
