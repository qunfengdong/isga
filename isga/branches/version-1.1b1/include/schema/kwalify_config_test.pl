#!/usr/bin/perl -w
use strict;
use YAML;
use Data::Dumper;
use Kwalify qw(validate);

my $file = shift;
validate( 
   YAML::LoadFile('/home/abuechle/Desktop/Sysmicro_svn/include/schema/config_kwalify.yaml'), 
   YAML::LoadFile($file));
exit;
