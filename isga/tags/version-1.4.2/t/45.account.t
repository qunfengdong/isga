#! /usr/bin/perl

use warnings;
use strict;

use lib 'build_lib';

use ISGA::Account::Test;

Test::Class->runtests;
