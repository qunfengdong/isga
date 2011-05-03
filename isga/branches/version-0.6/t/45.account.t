#! /usr/bin/perl

use warnings;
use strict;

use lib 'build_lib';

use SysMicro::Account::Test;

Test::Class->runtests;
