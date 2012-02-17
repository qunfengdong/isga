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
		 'Apache2::UploadProgress' => 0,
		 'Archive::Tar::Wrapper' => 0,
		 'Bio::Graphics' => 0,
		 'Crypt::SSLeay' => 0,
		 'Cwd' => 0,
		 'Date::Manip' => 0,
		 'Digest::SHA' => 0,
		 'Email::Find' => 0,
		 'File::Copy::Recursive' => 0,  
		 'File::Path' => '> 2',
		 'File::Pid' => 0,
		 'File::Temp' => '>= 0.22',
		 'GD::Image' => 0,
		 'Graph'      => 0,
		 'Hash::Merge::Simple' => 0,
		 'HTML::Scrubber' => 0,
		 'HTTP::Headers' => '> 5',
		 'HTTP::Request' => 0,
		 'IO::String' => 0,
		 'IPC::Run' => 0,
		 'JSON' => '> 2',
		 'LWP::UserAgent' => 0,
		 'PerlIO::gzip' => 0,
		 'Pod::Simple::HTMLBatch' => 0,
		 'Scalar::MoreUtils' => 0,
		 'Schedule::SGE' => 0,	 
		 'Test::More' => 0,
		 'URI' => 0,
		 'version'    => 0,
		 'XML::Twig' => 0,
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
