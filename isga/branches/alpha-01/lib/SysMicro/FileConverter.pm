package SysMicro::FileConverter;

#------------------------------------------------------------------------

=head1 NAME

B<SysMicro::FileConverter> provides methods for some common conversions
between file types.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use File::Basename;
use Archive::Tar;


#========================================================================

=back

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void fileListToTarGZ( string filelist, string tarfile );

Given an ergatis file list, it creates a .tar.gz file containing all
of the files in the list.

=cut 
#------------------------------------------------------------------------
sub fileListToTarGZ {

  my ( $class, $filelist, $output ) = @_;

  # make sure the input file exists
  -e $filelist or X::File::NotFound->throw( $filelist );

  # read in all of the input files
  open my $fh, '<', $filelist or X::File::Open->throw( name => $filelist, error => $! );
  my @list = <$fh>;
  chomp $_ for @list;

  # cavalierly charge ahead with Archive::Tar which reads all files into memory
  my $archive = Archive::Tar->new();

  # create hash to save usage of file names so we don't overwrite
  my %basenames;

  foreach ( @list ) {

    # retrieve the file name 
    my $file = basename($_);

    # if we've seen this name before prepend an incrementing tag to distinguish it
    if ( exists $basenames{ $file } ) {
      $basenames{$file}++;
      $file = $basenames{$file} . "_$file";
    } else { 
      $basenames{$file} = 1;
    }

    # add the data file to the tar file and then chomp the archive name of the file
    my ($fileObject) = $archive->add_files( $_ );
    $fileObject->rename( $file );
  }

  $archive->write( $output, 'COMPRESSION_GZIP' );
}

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
