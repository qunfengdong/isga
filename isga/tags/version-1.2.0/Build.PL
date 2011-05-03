use strict;
use warnings;

use lib 'build_lib';
use MyBuild;

my $builder = MyBuild->new(
    module_name         => 'ISGA',
    license             => 'perl',
    dist_abstract       => 'Integrative Services for Genomic Analysis',
    dist_author         => 'Center for Genomics and Bioinformatics <biohelp@cgb.indiana.edu>',
    dist_version_from   => 'lib/ISGA.pm',
    create_packlist     => 0,
    requires => {
        'Pod::Simple::HTMLBatch' => 0,
        'Test::More' => 0,
        'Graph'      => 0,
        'version'    => 0,
	'HTML::Scrubber' => 0,
        'Hash::Merge::Simple' => 0,
	'Digest::SHA' => 0,
	'GD::Image' => 0,
	'Email::Find' => 0,
	'Schedule::SGE' => 0,	 
	'Crypt::SSLeay' => 0,
	'File::Pid' => 0,
        'Bio::Graphics' => 0,
	'Date::Manip' => '< 6.0',
	'Apache2::UploadProgress' => 0,
    },
    add_to_cleanup      => [ 'ISGA-*' ],
);

# installation base dir
$builder->install_base or 
  die "ERROR: You must specify an installation directory with '--install_base'\n";

$builder->args('use_foundation') or
  die "ERROR: You must specify the location of Foundation with '--use_foundation'\n";

# we will install a custom include directory
my $base = $builder->install_base;

$builder->add_build_element('include');
$builder->install_path( include => "$base/include" );

$builder->add_build_element('masoncomp');
$builder->install_path( masoncomp => "$base/masoncomp" );

$builder->create_build_script();
