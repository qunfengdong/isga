#! /usr/bin/perl

use warnings;
use strict;

use lib 'build_lib';

use ISGA::Party::Test;

Test::Class->runtests;
