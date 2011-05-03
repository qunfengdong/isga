package ISGA::Job::BLAST;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::Job::BLAST> provides methods for working with BLAST jobs.


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
them to create an input file for the BLAST search and saves them as an
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
  my $username = time."_blast_input.fsa";
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

    $input_file = ISGA::File->upload($fh,
					 UserName => $args{Username},
					 Type => ISGA::FileType->new( Name => 'Nucleotide Sequence'),
					 Format => ISGA::FileFormat->new( Name => 'FASTA' ),
					 Description => 'Input file for BLAST job',
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

This method creates the ConfigFile for a BLAST job in yaml format.
The file contains information about the job id, the query databases,
the blast parameters, and the input file.

=cut
#------------------------------------------------------------------------
sub buildConfigFile{
  my ($self, %args) = @_;

  my @params;
  foreach (keys %{$args{web_args}}) {
    unless ($_ eq 'query_sequence' || $_ eq 'upload_file' || $_ eq 'sequence_database' || $_ eq 'workbench_blast' || $_ eq 'progress_id' || $_ eq 'notify_user'){
      push(@params, {$_ => ${$args{web_args}}{$_}});
    }
  }

  my $config = {};
  $config->{job_id} = $self->getId;
  $config->{input_file} = $args{input};
  $config->{input_file_path} = $args{input_file};
  $config->{output_file} = $args{output_file};
  push @{$config->{databases}}, @{$args{databases}};
  push @{$config->{params}}, @params;

  my $tmp = '___tmp_file_directory___' . time . $$ . 'blastConfig.yaml';

  my %args = ( Type => ISGA::FileType->new( Name => 'Toolbox Job Configuration'),
               Format => ISGA::FileFormat->new( Name => 'YAML' ),
               IsHidden => 1, UserName => basename($tmp),
               CreatedAt => ISGA::Timestamp->new(),
               CreatedBy => ISGA::Login->getAccount,
               ExistsOutsideCollection => 0, Description => 'Config for BLAST' );


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

  ISGA::FileCollectionContent->create( FileCollection => $self->getCollection,
					   FileResource => $input,
					   Index => 1 
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
                                         Type => ISGA::FileType->new( Name => 'BLAST Search Result'),
                                         Format => ISGA::FileFormat->new( Name => 'BLAST Raw Results' ),
                                         Description => 'Output file for BLAST job',
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


#------------------------------------------------------------------------

=item public void addHTMLOuputToCollection( String => $string);

This method adds the preprocessed HTML output file to the collection. 

=cut
#------------------------------------------------------------------------
sub addHTMLOutputToCollection {
  my ($self, $output) = @_;

  open my $fh, '<', $output or X::File->throw( error => "Cant open $output - $!" );

  seek($fh,0,0);
  $output_file = ISGA::File->upload( $fh,
                                         UserName => basename($output),
                                         Type => ISGA::FileType->new( Name => 'BLAST HTML Result'),
                                         Format => ISGA::FileFormat->new( Name => 'BLAST Raw Results' ),
                                         Description => 'Output file for BLAST job',
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

#------------------------------------------------------------------------

=item public void addXLSOuputToCollection( String => $string);

This method adds the preprocessed HTML output file to the collection. 

=cut
#------------------------------------------------------------------------
sub addXLSOutputToCollection {
  my ($self, $output) = @_;

  open my $fh, '<', $output or X::File->throw( error => "Cant open $output - $!" );

  seek($fh,0,0);
  $output_file = ISGA::File->upload( $fh,
                                         UserName => basename($output),
                                         Type => ISGA::FileType->new( Name => 'BLAST HTML Result'),
                                         Format => ISGA::FileFormat->new( Name => 'BLAST Raw Results' ),
                                         Description => 'Output file for BLAST job',
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
