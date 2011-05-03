package SysMicro::Job::MSA;
#------------------------------------------------------------------------

=head1 NAME

<SysMicro::Job::MSA> provides methods for working with MSA jobs.


=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use base 'SysMicro::Job';
use File::Basename;
use YAML;

{
#------------------------------------------------------------------------

=item public File buildQueryFile( File => $file, Upload => $fh, String => $string);

This method takes query sequences in any of three formats and combines
them to create an input file for the BLAST search and saves them as an
ISGA file.

=cut
#------------------------------------------------------------------------
sub buildQueryFile {
	
	my ($class, %args) = @_;
  # both of these are undefined to start with, lines may set them to circumvent unecessary work
  my $input_file = undef;
  my $fh = undef;

  # this will eventually be the file
  my $string = exists $args{String} ? $args{String} : '';

  # do we have a file
  if ( exists $args{File} ) {
    # if we only have a file, then we are done
    if ( ! exists $args{Upload} and ! $string ) {
      $input_file = $args{File};
    }

    # otherwise we append the contents of the file to $string
    $string .= $args{File}->toString;
  }

  # do we have a filehandle
  if ( exists $args{Upload} ) {
    # if we've defined a string by this point, then we need to append the included filehandle
    if ( $string ) {
      my $infh = $args{Upload};
      local ($/);
      $string .= <$infh>;

    # otherwise the filehandle is the only input and we can just use it
    } else {
      $fh = $args{Upload};
    }
  }

  # if we don't have $fh or $input_file then create a filehandle around the string
  if ( ! $fh and ! $input_file ) {
    $fh = File::Temp->new;
#    open $fh, '<', \$string;
    print $fh $string;
    seek($fh,0,0);
  }


  # if we have a filehandle, lets create an object out of it
  if ( $fh ) {

    $input_file = SysMicro::File->upload($fh,
           UserName => 'howdowesetthis',
           Type => SysMicro::FileType->new( Name => 'Nucleotide Sequence'),
           Format => SysMicro::FileFormat->new( Name => 'FASTA' ),
           Description => 'Input file for MSA job',
           CreatedBy => SysMicro::Login->getAccount,
           CreatedAt => SysMicro::Timestamp->new(),
           IsHidden => 0,
           ExistsOutsideCollection => 0
          );
  }

  # save the file into the YAML config for this job
  return $input_file;
}

#------------------------------------------------------------------------

=item public void buildConfigFile( String => $string);

This method creates the ConfigFile for a BLAST job in yaml format.
The file contains information about the job id, the query databases,
the blast parameters, and the input file.

=cut
#------------------------------------------------------------------------
sub buildConfigFile{
  my ($self, %args) = @_;


  my @params;
  foreach (keys %{$args{web_args}}) {
    unless ($_ eq 'query_sequence' || $_ eq 'upload_file' || $_ eq 'workbench_msa'){
      push(@params, {$_ => ${$args{web_args}}{$_}});
    }
  }
  my $config = {};
  $config->{job_id} = $self->getId;
	push @{$config->{params}}, @params;
	$config->{input_file} = $args{input_file};

  my $tmp = '___tmp_file_directory___' . time . $$ . 'msaConfig.yaml';

  my %args = ( Type => SysMicro::FileType->new( Name => 'Toolbox Job Configuration'),
               Format => SysMicro::FileFormat->new( Name => 'YAML' ),
               IsHidden => 1, UserName => basename($tmp),
               CreatedAt => SysMicro::Timestamp->new(),
               CreatedBy => SysMicro::Login->getAccount,
               ExistsOutsideCollection => 0, Description => 'Config for MSA' );

    $fh = File::Temp->new;
    print $fh YAML::Dump($config);
    seek($fh,0,0);

  my $file = SysMicro::File->upload( $fh, %args );


  SysMicro::FileCollectionContent->create( FileCollection => $self->getCollection,
             FileResource => $file,
             Index => 0
           );

}

#------------------------------------------------------------------------

=item public void buildConfigFile( String => $string);

This method creates the ConfigFile for a BLAST job in yaml format.
The file contains information about the job id, the query databases,
the blast parameters, and the input file.

=cut
#------------------------------------------------------------------------
sub addInputToCollection {
  my ($self, $input) = @_;
  use Data::Dumper;


  SysMicro::FileCollectionContent->create( FileCollection => $self->getCollection,
             FileResource => $input,
             Index => 1
           );


}



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
