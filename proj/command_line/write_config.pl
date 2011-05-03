#!/usr/bin/perl -w

# fake out apache 2.0
BEGIN { $ENV{MOD_PERL} = '2.0'; }
use strict;
use File::Copy;
use Data::Dumper;
use lib qw( /data/web/sysmicro.cgb/docs/lib );
use SysMicro;
use SysMicro::X;
use SysMicro::PipelineBuilder;

my $pipeline_builder = SysMicro::PipelineBuilder->new(Id => 1);
my $parameter_mask = $pipeline_builder->getParameterMask();

my $template_directory = "/data/web/sysmicro.cgb/SysMicro_svn/include/config_template/";

my $cluster = 6;
my $cluster_builder = SysMicro::ClusterBuilder->new($cluster);
my $mask_params = exists $parameter_mask->{ Cluster }->{ $cluster } ? $parameter_mask->{ Cluster }->{ $cluster } : undef;

# loop through component parameter defaults.
foreach (@{$cluster_builder->{Components}}){
  # copy config file for each ergatis component
  my $conf = './'.$$_{name}.'.config';
  copy($template_directory.$$_{name}.'.config', $conf);

  next if (not exists $$_{params});

  # loop through each input parameter for this component
  my %config_line = ();  # key is CONFIGLINE and value is the command to write to that line.
  foreach (@{$$_{params}}){
    # if the yaml does not have FLAG then just write the VALUE as the command for the appropriate config file line
    if (not exists $$_{FLAG}){
       $$_{VALUE} = ( defined $mask_params->{$$_{NAME}} ? $mask_params->{$$_{NAME}}->{Value} : $$_{VALUE} );
       my $command = ( defined $$_{VALUE} ? $$_{VALUE} . " " : "" );
       $config_line{$$_{CONFIGLINE}} = ( exists $config_line{$$_{CONFIGLINE}} ? $config_line{$$_{CONFIGLINE}} . $command : $command );
    # otherwise write FLAG and VALUE as the command
    }else{
      $$_{VALUE} = ( defined $mask_params->{$$_{NAME}}->{Value} ? $mask_params->{$$_{NAME}}->{Value} : $$_{VALUE} );
      my $command = ( defined $$_{VALUE} ? $$_{FLAG} . " " . $$_{VALUE} . " " : "" );
      $config_line{$$_{CONFIGLINE}} = ( exists $config_line{$$_{CONFIGLINE}} ? $config_line{$$_{CONFIGLINE}} . $command : $command );
    }
  }
  open(CONFIG, $conf) || die "Not gonna happen\n";
  open(TMP, ">./tmp.config") || die "Not gonna happen tmp\n";
  my $file = do { local $/; <CONFIG> };

  while (my ($key, $value) = each %config_line){
    $file =~ s/$key/$value/g;
  }
  print TMP $file;

  close(TMP);
  close(CONFIG);
  rename('./tmp.config', $conf);
}

exit;
