use Test::More tests => 2;


BEGIN {

# set environment to fake mod_perl
$ENV{MOD_PERL} = '2.0';

use lib 'build_lib';

use_ok( 'SysMicro' );

use_ok( 'SysMicro::Objects' );
}

diag( "SysMicro $SysMicro::VERSION" );
