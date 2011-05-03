#! /usr/bin/perl

use warnings;
use strict;

use lib 'build_lib';

use SysMicro::Pipeline::Test;

Test::Class->runtests;
