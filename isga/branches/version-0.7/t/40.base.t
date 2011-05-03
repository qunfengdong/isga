#! /usr/bin/perl

use warnings;
use strict;

use lib 'build_lib';

use SysMicro::Party::Test;

Test::Class->runtests;
