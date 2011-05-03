#! /usr/bin/perl -w

use warnings;
use strict;

use YAML;

my $file = YAML::LoadFile('cluster.yaml');

use Data::Dumper;

warn Dumper($file);

foreach ( @$file ) {

  print $_->{LayoutXML}, "***\n";

}

