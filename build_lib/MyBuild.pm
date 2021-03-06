package MyBuild;

use strict;
use warnings;

use base 'Module::Build';

use Cwd;

use DBI;
use File::Path;
use File::Copy;
use File::Spec::Functions;

use IO::File;

use YAML;
use Kwalify qw(validate);

use NEXT;

sub ACTION_code {

  my $self = shift;

  $self->SUPER::ACTION_code(@_);
  
  $self->write_build_yaml();

  # validate CONFIG.yaml
  validate(
     YAML::LoadFile('include/schema/config_kwalify.yaml'),
     YAML::LoadFile('CONFIG.yaml'));

  # build path to module_maker.pl
  my $dir     = $self->args('use_foundation');
  my $lib_dir = $dir . '/' . $self->install_base_relpaths('lib');
  my $exec   =  "$dir/bin/build_app.pl";

  `perl -I $lib_dir $exec`;

}


# write BUILD.yaml file
sub write_build_yaml {

  my $self = shift;

  my $foundation = $self->args('use_foundation');
  
  my %build = ( package => 'ISGA' );
  $build{foundation_include} = $foundation . '/include';
  $build{foundation_lib} = $foundation . '/' . $self->install_base_relpaths('lib');
  $build{package_include} = $self->install_destination('include');
  $build{package_lib} = $self->install_destination('lib');
  $build{package_masoncomp} = $self->install_destination('masoncomp');
  $build{package_bin} = $self->install_destination('bin');

  YAML::DumpFile('BUILD.yaml', \%build);
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

sub process_script_files {

  my $self = shift;

  my $files = $self->find_script_files;
  return unless keys %$files;
  
  my $script_dir = File::Spec->catdir($self->blib, 'script');
  File::Path::mkpath( $script_dir );
  
  foreach my $file (keys %$files) {

    # skip temp files
    next if $file =~ /\~$/;

    my $result = $self->copy_if_modified($file, $script_dir, 'flatten') or next;
    $self->fix_use_line($result);
    $self->fix_shebang_line($result) unless $self->is_vmsish;
    $self->make_executable($result);
  }
}

sub fix_use_line {

  my ($self, @files) = @_;

  # create the use line
  my $useline = "use lib '" . $self->install_destination('lib') . "';\n";
  
  for my $file (@files) {

    # open the file
    my $FIXIN = IO::File->new($file) or die "Can't process '$file': $!";
    my $FIXOUT = IO::File->new(">$file.new") or die "Can't create new $file: $!\n";
    

    # if there is a shebang line, keep it first
    local $/ = "\n";
    my $line = <$FIXIN>;

    if ( $line =~ m/^\s*\#!\s*/ ) {
      print $FIXOUT $line;
      print $FIXOUT $useline;
    } else {
      print $FIXOUT $useline;
      print $FIXOUT $line;
    }

    # write to a new file
    local $\;
    undef $/; # Was localized above
    my $remainder = <$FIXIN>;
    print $FIXOUT $remainder;
    close $FIXIN;
    close $FIXOUT;  

    # clean up
    rename($file, "$file.bak") or die "Can't rename $file to $file.bak: $!";
    rename("$file.new", $file) or die "Can't rename $file.new to $file: $!";
    
    $self->delete_filetree("$file.bak")
      or $self->log_warn("Couldn't clean up $file.bak, leaving it there");
  }
}


#
# subroutine for creating and populating a test database. Based on test_load.pl from gmod 1.0
# release
#

sub create_database {
  
  my $self = shift;

  # db user
  my $user = '';
  my $dbname = '';

  # retrieve existing database names for this installation
  my @list = `psql -U $user -l`;
  my %dbs;
  my $ok = 0;
  for my $line ( @list ) {
    if ( $line =~ m/^\s*Name\s*|\s*Owner\s*/ ) {
      $ok = 1;
      next;
    } elsif ( $ok ) {
      if ( $line =~ m/^\s*(\w+)\s*\|\s*\w+\s*/ ) {
	$dbs{ $1 } = 1;
      }
    }
  }

  # if the database exists, prompt the user to delete it
  if ( $dbs{ $dbname } ) {
    print "A database called '$dbname' already exists.\n";
    print "OK to drop database '$dbname'? [Y/n] ";
    chomp( my $answer = <STDIN> );
    unless ( $answer =~ m/^[Nn]/ ) {
      print "Dropping database '$dbname'\n";
      system( "dropdb -U $user $dbname" ) == 0 or die "Cannot drop database: $?";
    }
    else {
      print "Will not drop database '$dbname'.  Exiting.\n";
      return;
    }
  }
  
  print "Creating new database called '$dbname'\n";
  system( "createdb -U $user $dbname" ) == 0 or die "Cannot create database: $?";
  
  system( 
   "psql -U $user -f sql/isga.sql $dbname 2>&1 | grep -E 'ERROR|FATAL|No such file or directory'"
	) == 0 or die "Problem creating tables: $?";
  
  print "Database '$dbname' created\n";
}

sub ACTION_test {

  my $self = shift;

  $self->create_database();
  $self->SUPER::ACTION_test(@_);
}

sub ACTION_realclean {

  my $self = shift;

  unlink('build_lib/ISGA/Pg.pm' );
  rmdir( 'build_lib/ISGA' );
  unlink('BUILD.yaml');
  $self->SUPER::ACTION_realclean(@_);
}

1;
__END__
