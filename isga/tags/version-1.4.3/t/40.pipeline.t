#! /usr/bin/perl

use warnings;
use strict;

use lib 'build_lib';

use ISGA::Pipeline::Test;

Test::Class->runtests;
