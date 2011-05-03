use strict;
use warnings;

use lib 'build_lib';
use MyBuild;

my $builder = MyBuild->new(
    module_name         => 'SysMicro',
    license             => 'perl',
    dist_author         => 'Chris Hemmerich <biohelp@cgb.indiana.edu>',
    dist_version_from   => 'lib/SysMicro.pm',
    create_packlist     => 0,
    requires => {
        'Pod::Simple::HTMLBatch' => 0,
        'Test::More' => 0,
        'Graph'      => 0,
        'version'    => 0,
	'HTML::Scrubber' => 0,
	'Digest::SHA' => 0,
	'GD::Image' => 0,
	'Email::Find' => 0,
	'Schedule::SGE' => 0,	 
	'File::Pid' => 0,
        'Bio::Graphics' => 0,
    },
    add_to_cleanup      => [ 'SysMicro-*' ],
);

# allow us to install www files
$builder->add_build_element('masoncomp');
$builder->add_build_element('include');

$builder->args('test_db_name') 
  || $builder->args('test_db_name', 'lims_test');
$builder->args('test_db_password') || $builder->args('test_db_password', '');
$builder->args('test_db_type') || $builder->args('test_db_type', 'Pg');
$builder->args('test_db_user') || $builder->args('test_db_user', 'cgb');
$builder->args('test_db_host') || $builder->args('test_db_host', '');

$builder->args('db_name') || $builder->args('db_name', 'lims_dev');
$builder->args('db_password') || $builder->args('db_password', '');
$builder->args('db_type') || $builder->args('db_type', 'Pg');
$builder->args('db_user') || $builder->args('db_user', 'cgb');
$builder->args('db_host') || $builder->args('db_host', '');

# installation base dir
$builder->install_base || $builder->install_base('/data/web/isga.cgb/docs/');

# path for CGB installation
$builder->args('use_foundation') 
  || $builder->args('use_foundation', '/data/web/perl');

$builder->install_base_relpaths( lib => 'lib' );
$builder->install_base_relpaths( libdoc => undef );
$builder->install_base_relpaths( masoncomp => 'masoncomp' );
$builder->install_base_relpaths( include => 'include' );

$builder->create_build_script();
