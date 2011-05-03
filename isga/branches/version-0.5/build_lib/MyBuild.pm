package MyBuild;

use strict;
use warnings;

use base 'Module::Build';

use Cwd;

use DBI;
use File::Path;
use File::Copy;
use File::Spec::Functions;

sub ACTION_code {

  my $self = shift;

  $self->SUPER::ACTION_code(@_);
  
  # build path to module_maker.pl
  my $dir     = $self->args('use_foundation');
  my $lib_dir = "$dir/lib";
  my $exec   = "$dir/bin/build_app.pl";
  my $include     = "$dir/include";
  my $config_file = Cwd::cwd . "/CONFIG.yaml";

  `perl -I $lib_dir $exec SysMicro $include lib blib/lib $config_file`;
}

# don't just copy pm files
sub process_pm_files {

}

sub process_masoncomp_files {

  my $self = shift;
  my $files =
    $self->rscan_dir('masoncomp', 
		     sub { -f $_  and $_ !~ m{/.svn/} and $_ !~ m{\~$} });

  return unless @$files;
 
  my $www_dir = catdir($self->blib, 'masoncomp');
  File::Path::mkpath( $www_dir );

  $self->copy_if_modified($_, $self->blib) for @$files;
}

sub process_include_files {

  my $self = shift;
  my $files =
    $self->rscan_dir('include', 
		     sub { -f $_  and $_ !~ m{/.svn/} and $_ !~ m{\~$} });

  return unless @$files;
 
  my $include_dir = catdir($self->blib, 'include');
  File::Path::mkpath( $include_dir );

  $self->copy_if_modified($_, $self->blib) for @$files;
}


sub create_database {
  
  my $self = shift;

  my $cwd = getcwd();
  chdir( 'sql' );
  
  `psql -U cgb -f rebuild.sql sysmicro_test`;
  
  chdir( $cwd );

}

sub ACTION_test {

  my $self = shift;

  $self->create_database();
  $self->SUPER::ACTION_test(@_);
}

sub ACTION_realclean {

  my $self = shift;

  unlink('build_lib/SysMicro/Pg.pm' );
  rmdir( 'build_lib/SysMicro' );
  $self->SUPER::ACTION_realclean(@_);
}

1;
__END__
