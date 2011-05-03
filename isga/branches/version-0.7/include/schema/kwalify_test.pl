#!/usr/bin/perl -w
use strict;
use YAML;
use Data::Dumper;
use Kwalify qw(validate);

my $file = shift;
validate( 
   YAML::LoadFile('/home/abuechle/Desktop/Sysmicro_Smart_Clusters/include/schema/component_definition_kwalify.yaml'), 
   YAML::LoadFile($file));
exit;
