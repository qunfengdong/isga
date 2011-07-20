package ISGA::Tar;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::SGEScheduler contains class methods that are used to submit and 
check the status of SGE jobs.

=head1 SYNOPSIS

=head1 DESCRIPTION

This class is a wrapper for Archive::Tar::Wrapper that reduces the
amount of data copying and is able to stream output via callback
routine.

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use Archive::Tar::Wrapper;
use base 'Archive::Tar::Wrapper';

use IPC::Run qw(run);
use Cwd;
use File::Path;
use File::Temp qw(tempdir);
use Log::Log4perl qw(:easy);
use File::Spec::Functions;
use File::Spec;
use File::Copy;
use File::Find;
use File::Basename;

#========================================================================

=head2 METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void write(coderef $callback, bool $compress);

Write out the tarball using the supplied callback. If compress
evaluates to true, the tarball will be gzipped.

=cut
#------------------------------------------------------------------------
sub write {

  my ($self, $callback, $compress) = @_;

  my $cwd = getcwd();
  chdir $self->{tardir} or X->throw( message => "Can't chdir to $self->{tardir} ($!)");
  
  my $compr_opt = "h";
  $compr_opt = "z" if $compress;

  opendir DIR, "." or X->throw( message => "Cannot open $self->{tardir}" );
  my @top_entries = grep { $_ !~ /^\.\.?$/ } readdir DIR;
  closedir DIR;

  my $rc = run( [ $self->{tar}, "${compr_opt}c", @top_entries] , '>', $callback );
  if(!$rc) {
    X->throw( message => "$self->{tar} ${compr_opt}c failed." );
  }  

  chdir $cwd or X->throw( message => "Cannot chdir to $cwd" );
}

#------------------------------------------------------------------------

=item public void add(string $relative_path, string $source_path);

Creates a symbolic link at $relative_path within the tarball pointing
to $source_path.

=cut
#------------------------------------------------------------------------
sub add {
  
  my ($self, $rel_path, $source) = @_;

  my $target = File::Spec->catfile($self->{tardir}, $rel_path);

  my $target_dir = dirname($target);
  mkpath($target_dir, 0, 0755) unless -d $target_dir;

  symlink($source,$target) or X->throw( message => "unable to creat symlink $target to $source" );

  perm_set($target, perm_get($source));
}

######################################
sub perm_cp {
######################################
    # Lifted from Ben Okopnik's
    # http://www.linuxgazette.com/issue87/misc/tips/cpmod.pl.txt

    my $perms = perm_get($_[0]);
    perm_set($_[1], $perms);
}

######################################
sub perm_get {
######################################
    my($filename) = @_;

    my @stats = (stat $filename)[2,4,5] or
        LOGDIE "Cannot stat $filename ($!)";

    return \@stats;
}

######################################
sub perm_set {
######################################
    my($filename, $perms) = @_;

    chown($perms->[1], $perms->[2], $filename) or
        LOGDIE "Cannot chown $filename ($!)";
    chmod($perms->[0] & 07777,    $filename) or
        LOGDIE "Cannot chmod $filename ($!)";
}

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
