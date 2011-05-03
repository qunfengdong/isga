#! /usr/bin/perl

use warnings;
use strict;

BEGIN { $ENV{MOD_PERL} = '2.0'; }

use lib 'build_lib';

use SysMicro::WebApp::Account::Test;

Test::Class->runtests;
