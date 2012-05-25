#! /usr/bin/perl

=head1 NAME

install_pipeline.pl - Installs a new pipeline for ISGA

=head1 SYNOPSIS

USAGE: install_pipeline.pl 
         --source=path to pipeline directory
       [ --help
         --force_install
         --status
       ]

=head1 OPTIONS

B<--source>
  Filesystem path to root directory of pipeline you are installing

B<--status Available|Published|Retired>
  Overrides the status of the pipeline

B<--force_install>
  If database entries in this pipeline conflict with installed entries, overwrite the old version.

B<--help,-h> 
    This help message

=head1 DESCRIPTION

Installs a new pipeline into the local ISGA installation.

=head1 INPUT

=head1 OUTPUT

=head1 CONTACT

=cut

use strict;
use warnings;

use ISGA::X;

use ISGA::GlobalPipeline;
use ISGA::FileFormat;
use ISGA::FileType;
use ISGA::ComponentTemplate;
use ISGA::ClusterInput;
use ISGA::ClusterOutput;
use ISGA::ConfigurationVariable;
use ISGA::PipelineConfiguration;
use ISGA::Workflow;

use ISGA::ErgatisInstall;
use ISGA::ModuleInstaller;

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

my %valid_statuses = ( Available => undef, Published => undef, Retired => undef );

my %options = ();
my $result = GetOptions (\%options, 'source=s', 'force_install', 'status=s', 'help|h');

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

&check_parameters(\%options);


my $mi = ISGA::ModuleInstaller->new(%options);

$mi->install();

sub check_parameters {

  my ($options) = @_;

  if ( exists $options{status} ) {
    if ( ! exists $valid_statuses{$options{status}} ) {
      print "$options{status} is not a valid pipeline status";
      exit(1);
    }
  }

  if ( ! exists $options{source} ) {
    
    print "--source is a required parameter\n";
    exit(1);
  }


}



