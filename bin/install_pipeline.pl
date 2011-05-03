#! /usr/bin/perl

=head1 NAME

install_pipeline.pl - Installs a new pipeline for ISGA

=head1 SYNOPSIS

USAGE: install_pipeline.pl 
         --source=path to pipeline directory
       [ --help
         --force_install
       ]

=head1 OPTIONS

B<--source>
  Filesystem path to root directory of pipeline you are installing

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

use ISGA;

use ISGA::ModuleInstaller;

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

my %options = ();
my $result = GetOptions (\%options, 'source=s', 'force_install', 'help|h');

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

&check_parameters(\%options);


my $mi = ISGA::ModuleInstaller->new(%options);

$mi->install();



sub check_parameters {

  my ($options) = @_;

  if ( ! exists $options{source} ) {
    
    print "--source is q requred parameters\n";
    exit(1);
  }


}



