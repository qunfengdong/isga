package SysMicro::WebApp::Account::Test;
#------------------------------------------------------------------------
=pod

=head1 NAME

SysMicro::WebApp::Account::Test - test methods for account use cases.

=head1 METHODS

=over 4

=item _methods()

=back

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use Test::Deep qw(cmp_deeply bag);
use Test::Exception;
use Test::More;

use SysMicro;
use SysMicro::Objects;

use SysMicro::Test::Transactions;

use base 'Test::Class';

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void _methods();

Test availability of class methods.
 
=cut
#------------------------------------------------------------------------
sub _methods : Test( 7 ) {

  my $class = 'SysMicro::WebApp';

  use_ok( $class );  # a gimme

  can_ok( $class, 'Account::EditMyDetails' );
  can_ok( $class, 'Account::ChangeMyPassword' );
  can_ok( $class, 'Account::ResetPassword' );
  can_ok( $class, 'Account::LostPassword' );
  can_ok( $class, 'Account::Request' );
  can_ok( $class, 'Account::Confirm' );
}

#------------------------------------------------------------------------

=item public void create();

Test availability of class methods.
 
=cut
#------------------------------------------------------------------------
#sub create : Test( 2 ) {

#  my $class = 'SysMicro::WebApp';
  
  

#}

1;

__END__

=back

=head1 DIAGNOSTICS

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
