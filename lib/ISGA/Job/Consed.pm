package ISGA::Job::Consed;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::Job::Consed> provides methods for working with Consed jobs.


=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=over

=cut
#------------------------------------------------------------------------

use base 'ISGA::Job';
use File::Basename;
use YAML;

{

#------------------------------------------------------------------------

=item public File buildQueryFile( File => $file, Upload => $fh, String => $string);

This method takes query sequences in any of three formats and combines
them to create an input file for the Consed Conversion and saves them as an
ISGA file.

=cut
#------------------------------------------------------------------------
sub buildQueryFile {

  my ($class, %args) = @_;

#  my $collection = $self->getFileCollection();

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
  my $username = time."_consed_input";
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
    print $fh $string;
    seek($fh,0,0);
  }
 
  
  # if we have a filehandle, lets create an object out of it
  if ( $fh ) {

    $input_file = ISGA::File->upload($fh,
					 UserName => $args{Username},
					 Type => ISGA::FileType->new( Name => $args{Type} ),
					 Format => ISGA::FileFormat->new( Name => $args{Format} ),
					 Description => 'Input file for conversion for consed',
					 CreatedBy => ISGA::Login->getAccount,
					 CreatedAt => ISGA::Timestamp->new(),
					 IsHidden => 0,
					 ExistsOutsideCollection => 0
					);
  }

  # save the file into the YAML config for this job
  return $input_file;
}
 
#------------------------------------------------------------------------

=item public void buildConfigFile( String => $string);

This method creates the ConfigFile for a Consed job in yaml format.
The file contains information about the job id and the input file.

=cut
#------------------------------------------------------------------------
sub buildConfigFile{
  my ($self, %args) = @_;

  my $config = {};
  $config->{job_id} = $self->getId;
  $config->{output_file} = $args{output_file};

  my $tmp = '___tmp_file_directory___' . time . $$ . 'consedConfig.yaml';

  my %args = ( Type => ISGA::FileType->new( Name => 'Toolbox Job Configuration'),
               Format => ISGA::FileFormat->new( Name => 'YAML' ),
               IsHidden => 1, UserName => basename($tmp),
               CreatedAt => ISGA::Timestamp->new(),
               CreatedBy => ISGA::Login->getAccount,
               ExistsOutsideCollection => 0, Description => 'Config for assembler output conversion for Consed' );

  $fh = File::Temp->new;
  print $fh YAML::Dump($config);
  seek($fh,0,0);

  my $file = ISGA::File->upload( $fh, %args );

  ISGA::FileCollectionContent->create( FileCollection => $self->getCollection,
                                       FileResource => $file,
                                       Index => 0 
                                     );
}

#------------------------------------------------------------------------

=item public void addInputToCollection( String => $string);

This method adds the input file to the collection. 

=cut
#------------------------------------------------------------------------
sub addInputToCollection {
  my ($self, $input) = @_;

  my $next_index = ISGA::FileCollectionContent->exists( FileCollection => $self->getCollection );

  ISGA::FileCollectionContent->create( FileCollection => $self->getCollection,
                                       FileResource => $input,
                                       Index => $next_index++
                                     );

  
}

#------------------------------------------------------------------------

=item public void addOuputToCollection( String => $string);

This method adds the output file to the collection. 

=cut
#------------------------------------------------------------------------
sub addOutputToCollection {
  my ($self, $output) = @_;

  open my $fh, '<', $output or X::File->throw( error => "Cant open $output - $!" );

  seek($fh,0,0);
  $output_file = ISGA::File->upload( $fh,
                                         UserName => basename($output),
                                         Type => ISGA::FileType->new( Name => 'Consed Input'),
                                         Format => ISGA::FileFormat->new( Name => 'ACE' ),
                                         Description => 'Consed Input produced by workbench job',
                                         CreatedBy => ISGA::Login->getAccount,
                                         CreatedAt => ISGA::Timestamp->new(),
                                         IsHidden => 0,
                                         ExistsOutsideCollection => 0
                                      );
  my $next_index = ISGA::FileCollectionContent->exists( FileCollection => $self->getCollection );

  ISGA::FileCollectionContent->create( FileCollection => $self->getCollection,
				       FileResource => $output_file,
				       Index => $next_index++
				     );
#  return $output_file;

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
