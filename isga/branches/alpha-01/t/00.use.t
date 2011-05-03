use Test::More tests => 1;

BEGIN {

# set environment to fake mod_perl
$ENV{MOD_PERL} = '2.0';

use_ok( 'SysMicro' );
}

diag( "SysMicro $SysMicro::VERSION" );
