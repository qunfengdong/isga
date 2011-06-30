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
  chdir $self->{tardir} or LOGDIE "Can't chdir to $self->{tardir} ($!)";
  
  my $compr_opt = "h";
  $compr_opt = "z" if $compress;

  opendir DIR, "." or LOGDIE "Cannot open $self->{tardir}";
  my @top_entries = grep { $_ !~ /^\.\.?$/ } readdir DIR;
  closedir DIR;

  my $rc = run( [ $self->{tar}, "${comp_opt}c", @top_entries] , '>', $callback );
  if(!$rc) {
    ERROR "@$cmd failed: $err";
    return undef;
  }  

  chdir $cwd or LOGDIE "Cannot chdir to $cwd";
}

#------------------------------------------------------------------------

=item public void add(string $relative_path, string $source_path);

Creates a symbolic link at $relative_path within the tarball pointing
to $source_path.

=cut
#------------------------------------------------------------------------
sub add {
  
  my ($self, $rel_path, $source) = @_;

  my $target = File::Spec->catfile($archive->{tardir}, $rel_path);

  my $target_dir = dirname($target);
  mkpath($target_dir, 0, 0755) unless -d $target_dir;

  symlink($source,$target) or LOGDIE "unable to creat symlink $target to $source";

  perm_set($target, perm_get($source));
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
