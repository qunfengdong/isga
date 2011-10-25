#!/usr/bin/perl -w
use strict;
use YAML;
use Data::Dumper;
use Kwalify qw(validate);

my $file = shift;
validate( 
   YAML::LoadFile('/data/web/isga.cgb/isga_svn/include/schema/run_analysis_kwalify.yaml'), 
   YAML::LoadFile($file));
exit;
