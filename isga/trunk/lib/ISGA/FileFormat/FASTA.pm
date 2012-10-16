package ISGA::FileFormat::FASTA;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::FileFormat::FASTA provides utility methods for FASTA files,
including verification.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use ISGA::X;


use File::Temp;
use Bio::SeqIO;

# define valid alphabets
my @dna = qw( A a C c G g T t U u R r Y y K k M m S s W w B b D d H h V v N n X x - );

my @aa = qw( A a B b C c D d E e F f G g H h I i K k L l M m N n O o P p Q q R r S s
	     T t U u V v W w Y y Z z X x * - );

my %dna;
my %aa;

$dna{$_} = [] for @dna;
$aa{$_} = [] for @aa;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================


#------------------------------------------------------------------------

=item public filehandle format(filehandle $fh);

Uses BioPerl to clean up the formating of the supplied file.

=cut
#------------------------------------------------------------------------
sub format {

  my ($class, $fh) = @_;

  my $tmp_dir = ISGA::SiteConfiguration->value('local_tmp');
  my $new_fh = File::Temp->new(DIR => $tmp_dir);
  
  eval { 

    my $seqio_object = Bio::SeqIO->new(-format => 'fasta', -fh => $fh);
    
    my $seqOut = Bio::SeqIO->new(-format => 'fasta', -noclose => 1, -fh => $new_fh );
    
    while ( my $seq_object = $seqio_object->next_seq ) {
      $seqOut->write_seq($seq_object);
    }

  };
    
  # if we catch a bioperl error, present it to the user
  if ( my $e = $@ ) {
    if ( ! ref($@) ) {
      X::Dropped->throw( error => $@ );
    } elsif ( $e->isa('Bio::Root::Exception') ) {
      X::User->throw( error => $e->text );
    } else {
      $e->rethrow();
    }
  }

  # seek to beginning of otuput
  $new_fh->flush();
  seek($new_fh,0,0);

  -z $new_fh and X::File::Empty->throw( name => 'ah poop');

  return $new_fh;
}


#------------------------------------------------------------------------

=item public HashRef verify(File $file);
=item public HashRef verify(FileHandle $fh);

Verifies the contents of a Fasta file, checking for common errors and
errors known to cause problems for pipeline components.

Optional Named Parameters:

 Alphabet => [nucleotide|peptide] (OPTIONAL)

If an alphabet is supplied, the method checks to make sure all
characters are valid IUB/IUPAC codes.

 UserName => string (OPTIONAL)

If providing a file handle this attribute sets the filename to be returned in any exception.

Returns:

This method returns a small has reference containing useful information about the fasta file.

 seq_count => int
 base_count => int

=cut
#------------------------------------------------------------------------
sub verify {

  my ($class, $file, %named) = @_;

  my ($fh, $name);

  if ( UNIVERSAL::isa($file, 'ISGA::File') ) {      
      $fh = $file->getFileHandle;
      $name = $file->getUserName;
  } else {
    $fh = $file;
    $name = exists $named{UserName} ? $named{UserName} : 'user file';
  }

  # check for empty files
  -z $fh and X::File::Empty->throw( name => $name);

  # check for binary files
  -B $fh and X::File::FASTA::Binary->throw( name => $name);

  # initialize data hash
  my %fasta = ( seq_count => 0, base_count => 0 );
  my $in_seq = 0;
  my $line => 0;

  # set alphabet if we have one
  my $alphabet = ( exists $named{Alphabet} ? $named{Alphabet} : '' );

  # hash to store seen headers
  my %headers;

  my $seq_length = 0;

  while (<$fh>) {

    # always increment line number
    $line++;

    # good sequence header
    if ( /^>\S/ ) {

      # headers cannot start with numbers
      X::File::FASTA::Header::BeginningNumber->throw( name => $name, line => $line ) if ( /^>\d/ ); 

      # is this a duplicate header
      exists $headers{$_} ? X::File::FASTA::Header::Duplicate->throw( name => $name, line => $line ) : $headers{$_} = 1;
      
      X::File::FASTA::Header::EmptySequence->throw( name => $name, line => $line-1 ) if $in_seq and $seq_length == 0;

      #header has to be less 150 characters or less for RepeatMasker
      X::File::FASTA::Header::TooLong->throw( name => $name, line => $line ) if ( length($_) > 151 );

      $fasta{seq_count}++;
      
      # form now on sequence characters are valid
      $in_seq = 1;

      $seq_length = 0;
    # illegal space in sequence header
    } elsif ( /^>\s/ ) {
      X::File::FASTA::Header::BeginningSpace->throw( name => $name, line => $line );
      
    # process sequence characters only if we've been asked to verify an alphabet
    } else {

      # clear out the whitespace
      chomp;
      s/\s//g;

      # increment the base counter
      my $l = length($_);
      $fasta{base_count} += $l;

      $seq_length += $l;
      
      # skip empty lines
      next unless $l > 0;

      # if we aren't in a sequence, we have a bad header
      $in_seq or X::File::FASTA::Header::MissingSymbol->throw( name => $name, line => $line );

      # if we aren't concerned about the alphabet, save some time
      next unless $alphabet;

      my $c = undef;

      my @str = split(//, $_);

      # did we ask for nucleotide onles
      if ( $alphabet eq 'nucleotide' ) {
	exists $dna{$_} 
	  or X::File::FASTA::Sequence::IllegalCharacter->throw( name => $name, line => $line,
								alphabet => 'nucleotide',
								character => $_ ) for @str;

      # do we have a declared amino acid file
      } elsif ( $alphabet eq 'peptide' ) {
	exists $aa{$_} 
	  or X::File::FASTA::Sequence::IllegalCharacter->throw( name => $name, line => $line,
								alphabet => 'peptide',
								character => $_ ) for @str;

      # otherwise make sure it's one or the other
      } else {
	exists $aa{$_} or exists $dna{$_}
	  or X::File::FASTA::Sequence::IllegalCharacter->throw( name => $name, line => $line,
								character => $_ ) for @str;
      }
	
    }
  }

  X::File::FASTA::Header::EmptySequence->throw( name => $name, line => $line-1 ) if ($fasta{base_count} < 1);
  
  seek($fh,0,0);

  return \%fasta;
}


1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=item X::File::Empty

=item X::File::FASTA::Binary

=item X::FILE::FASTA::Header::BegginingSpace

=item X::FILE::FASTA::Header::MissingSymbol

=item X::FILE::FASTA::Sequence::IllegalCharacter

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
