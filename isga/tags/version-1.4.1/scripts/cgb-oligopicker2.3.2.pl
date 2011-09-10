#!/usr/bin/perl -w
# CollapsedSubs: gcPercent  gcCount  timeout
#################################################################################################################
# OligoPicker selects up to five oligo probes for each of the DNA sequences you provide for microarray printing.

# Copyright (C) 2002  Xiaowei Wang (email: xwang@molbio.mgh.harvard.edu), Massachusetts General Hospital
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#################################################################################################################

### V1.0 is original file before modifications made in year 2002
### V1.0 has been used to produce several oligo sets
### V1.0 has mainly two features: Tm range and 15mer perfect match filter
### V1.1.0 changes: include DUST program to mask low-complexity regions
### V1.1.1 changes: include gap position jump for fast screening
### V1.1.2 changes: combine 5' and 3' end in one block of code by using three IFs inside the loop
### V1.2.1 changes: include NCBI Blast program to check uniqueness
###                 move 10 bases instead of 1 in the positions loop, this is to prevent 14 perfect-match bases at the end
###                 screenKey sub is modified to eleminate the need of key deletion
### V1.2.2 changes: fixed a bug in crossReactivity sub. Some sequences may have the same 10mer at multiple locations
### V1.3.0 changes: include bl2seq for search for self-annealing
### V1.3.1 changes: include gap position jump for blastall and bl2seq to improve performance
### V1.4.0 changes: include a second fasta file as a filter
### V1.4.1 changes: add the parameter input part back and reset the position jump to 5
###                 V1.4.1 is used to produce the oligo list for the bake-off experiment

### V1.5.1 changes: separate removeDuplicate sub from this file into a new file called removeDup.pl. This greatly simplifies the program work flow
###                 ($keyUnit{$extUnitSeq} =~ /$unitIndex $extUnitPosition/) -> (index($keyUnit{$extUnitSeq}, "$unitIndex $extUnitPosition") != -1)
### V1.5.2 changes: create a tmp dir for blast-related tmp files and later delete the dir
### V1.5.3 changes: lower the word size for bl2seq (self-annealing) to 10: -W 10

### V2.0 is identical to V1.5.3, named as release version
### V2.0.1 changes: bug fix that affects 5' end reading (position jump for blastall and bl2seq)
###                 a minor fix for 3' reading (previously jumped one more position as needed)
###                 a minor bug fix for bl2seq itself (one position off for alignment by the program's current version)
###                 echo command used for blastall can't contain "'" in seq definition line! The tmp solution is to include only 'gi|1234|' as def. It is better to be replaced in future version
### V2.0.2 changes: position jump for the POSITION loop is changed to 1 (from 5) and jump 3 more positions just for 15mer screening to prevent trailing 14mer match
###                 reformat oligo and sequence files for bl2seq program
### V2.0.3 changes: a bug fix checking self-annealing. Previously, a masked sequenced was used for oligo query. The masked region can not be blasted
### V2.0.4 changes: position jump for 15mer screening is changed to 2 (from 3). This leave a trailing 12mer mactch (acceptable)
### V2.0.5 changes: minor changes to blast; still identical result to V2.0.4 for my data set
### V2.0.6 changes: Tm equation changes, didn't affect result; add -w tag; link blast Score to screen size
### V2.0.7 changes: Organize all programs in one directory
### V2.1.0 changes: add the function to design non-unique probes
### V2.1.1 changes: change the output format for non-unique oligos; remove \| for gi match
### V2.2.0 changes: can design multiple probes per sequence; more strict filter for oligo-oligo anneal;
###                 separate 3' and 5' code again; streamline code in blast and anneal sub; add -e 1000 to anneal and blast sub
### V2.2.1 changes: The oligo length is now changeable
### V2.2.2 changes: Filter and data sequences are completed separated, and more stringency is given to filter sequences
### V2.2.3 changes: Give user the flexibility to select different degrees of cross-reactivity for input and filter sequences.
### V2.3   changes: Release version from V2.2.3 with minor bug fixes for filter cross-reactivity
### V2.3.1 changes: Bug fix for Tm range calculation; include Tm values in the output file (in 1M NaCl)
###                 Minor Bug fix for the output file when cross probes are designed.
### V2.3.2 changes: Enforce the requirement of NCBI format


use strict;

use Getopt::Long;

my $hasFilterFile = "n";
my @filter = ();
my %filterUnit = ();

my @dna = ();
my %keyUnit = ();
my @original_seq = (); # used to preserve dna sequnces before masking, for self-anneal sub
my %original_gi = (); # used to preserve gi numbers before adding filter file, for blastCross sub
my $medianGC;


my $dust_dir = "/research/projects/isga/sw/bin/NCBI/dust";
my $blastDir = "/research/projects/isga/sw/bin/NCBI/blast";
my $tmpDirectory = "oligopicker_tmp";
my $blastDbName = "$tmpDirectory/oligopicker";

my $oldTime = times();
my $time;

my $oligoFile = "oligoOutput.data";


### set defaults for parameters

my $inputFile = ''; # input sequences
my $filterFile = ''; # file used to filter against for cross-reactivity

my $tmRange = 10;   # +- 5 degree range
my $crossDegree = 15; # degree of cross-hybridization, i.e. n.t. number for uniqueness
my $endPreference = 5;

my $default_copy = 1; # copy of probe per sequence
my $design_cross_probe = '';
my $oligoLength = 70;

my $maxBlastScore = undef; # blast score for blastall program, default to 30
my $filterCrossDegree = undef;

my $wordSize = 10; # word size for bl2seq program, default to 10

### read in our parameters

GetOptions ( "input=s" => \$inputFile,
	     "filter:s" => \$filterFile,
	     "filtercrossdegree=i" => \$filterCrossDegree,
	     "copyperseq=i" => \$default_copy,
	     "oligolength=i" => \$oligoLength,
	     "tmrange=i" => \$tmRange,
	     "crossdegree=i" => \$crossDegree,
	     "endpreference=i" => \$endPreference,
	     "crossreactingprobes:s" => \$design_cross_probe,
	     "threshold=i" => \$maxBlastScore,
	     "output=s" => \$oligoFile,
	   );

### sanity check our parameters

if ( -e $inputFile && -r $inputFile && -f $inputFile && -T $inputFile ) {
  print "Input File: $inputFile\n\n";
} else { 
  die "Unable to proceed with $inputFile. Must be readable, plain text file";
}

if ( $default_copy >=1 && $default_copy <= 5 ) {
  print "Probes designed for each sequence: $default_copy\n\n";
} else {
  die "$default_copy is not a valid number of probes ( 1-5 )";
}

if ( $oligoLength >=10 && $oligoLength <= 100 ) {
  print "Oligo probe length: $oligoLength\n\n";
} else {
  die "$oligoLength is not a valid oligo probe length ( 10-70 )";
}

if ( $tmRange >=10 && $tmRange <= 100 ) {
  print "Tm range: $tmRange\n\n";
} else {
  die "$tmRange is not a valid melting point range ( 1-30 )";
}

if ( $crossDegree ne "" and $crossDegree >= 11 and $crossDegree <= 20 ) {
  print "Degree of cross-reactivity: $crossDegree.\n\n";
} else {
  die "$crossDegree is not a valid degree of cross-reactivity ( 11 - 20 )";
}

# max blast score is a little special
if ( $maxBlastScore ) {
  if ( $maxBlastScore >= 20 && $maxBlastScore <= 50 ) {
    print "Threshold BLAST score: $maxBlastScore\n\n";
  } else {
    die "$maxBlastScore is not a valid BLAST threshold score ( 20 - 50 )";
  }
# otherwise calculate from the cross degree
} else {
  $maxBlastScore = 30 + ($crossDegree - 15) * (  $crossDegree < 15 ? 2.5 : 2 );
}

if ( $endPreference == 3 or $endPreference == 5 ) {
  print "Selected end preference: $endPreference\n\n";
} else {
  die "$endPreference is not a valid sequence end ( 5, 3 )";
}

if ( $filterFile ) {

  $hasFilterFile = 'y';

  if ( -e $filterFile && -r $filterFile && -f $filterFile && -T $filterFile ) {
    print "Input File: $filterFile\n\n";

    if ( $filterCrossDegree ) {
      
      if ( $filterCrossDegree >= 11 && $filterCrossDegree <= 20 ) {
	print "Degree of filter cross-reactivity: $filterCrossDegree\n\n";
      } else {
	die "$filterCrossDegree is not a valid cross-reactivity degree ( 11 - 20 )";
      }
    # use other cross degree as a default
    }
  } else { 
    die "Unable to proceed with $filterFile. Must be readable, plain text file";
  }
} else { print "You did not include a filter file\n\n"; }
$filterCrossDegree ||= $crossDegree; 


if ( $design_cross_probe ) {
  $design_cross_probe = 'y';
  print "You chose to design cross-reacting probes.\n\n";
} else {
  $design_cross_probe = 'n';
  print "You chose NOT to design cross-reacting probes.\n\n";
}

##########################################################################
# end of parameter input #
##########################################################################

print "***Starting program...***\n\n";

print "\nOligoPicker is now importing your data file...\n";

importDataFile($inputFile);

print "\nOligoPicker is now calculating median Tm...\n";
$medianGC = medianGCCount();
print "Median Tm for all $oligoLength-mer oligos in 1M NaCl: ", tm($medianGC), " degree. Processing time: ", usedTime(), " seconds.\n";

if ($hasFilterFile eq 'y') {
     print "\nOligoPicker is now including $filterFile...\n";
     &importFilterFile($filterFile);
     print "\nOligoPicker is now parsing all filter sequences...\n";
     &screenFilterKey();
}

print "\nOligoPicker is now parsing all input data sequences...\n";
&screenDataKey(); # should be after adding the filter file

print "\nOligoPicker is now masking low-complexity regions...\n";
&maskRepeat();  # should be after screenKey sub in order not to include filter sequences

print "\nBuild index for blast program......\n";
&prepareBlast();

print "\nOligoPicker is now picking oligos with the selected Tm range and degree of cross-hybridization......\n";

my $successCounter = 0;
my $printCounter = 0;
for (my $index = 0; $index <= $#dna; $index++) {

     # to print a report for every 10 sequences
     if ($index >= $printCounter * 10) {
          print "$index sequences screened and unique oligos selected for $successCounter sequences...\n" if $index > 0;
          $printCounter++;
     }

     # re-initialize $probe_number for each sequence
     my $probe_number = 0;

     $probe_number = pickProbe($crossDegree, $filterCrossDegree, $maxBlastScore, $index, $probe_number);
      if ($probe_number == 0){ # no probe has been picked
           $probe_number = pickProbe($crossDegree + 1, $filterCrossDegree + 1, $maxBlastScore + 2.5, $index, $probe_number);
      }
      if ($probe_number == 0 && $design_cross_probe eq 'y'){  # if no probe has been picked so far, pick only one cross-probe
           $probe_number = pickCrossProbe($crossDegree + 1, $filterCrossDegree + 1, $maxBlastScore + 2.5, $index);
      }
     $successCounter++ if $probe_number > 0;  # count a sequence as a success if at least one unique probe is designed

} # DNA loop

$_ = $#dna + 1;
print "\n$successCounter unique oligos has been designed for $successCounter out of total $_ genes. Processing time: ", usedTime(), " seconds.\n";

# remove blast-related temp files
#system("rm -r $tmpDirectory");

print "\nOligoPicker is now writing selected oligos to $oligoFile......\n";
&exportOligo();
print "The oligos were listed in file $oligoFile in tab dilimited format.\n\n";

print "***Program ended successfully.***\n";


#########################################################################################
# start of all subroutines
#########################################################################################

# a combination of several subs for fasta file import
sub importDataFile {

    my ($fastaFile) = @_;
    my $tabFile = "seq$$.tab"; # intermediate tmp file to store formatted and un-duplicate sequence data

    # get a tab file format from the original fasta file
    &fastaToTab($fastaFile, $tabFile);

    @dna = importTabSeq($tabFile);

    # preserve sequences before masking or adding filter file
    for (my $index = 0; $index <= $#dna; $index++) {
         # for Blast search in the self-anneal sub
         $original_seq[$index] = $dna[$index]{'dna'};
         # for blastCross sub to identify gi from data file, not from filter file
         $original_gi{$1} = 1 if ($dna[$index]{'id'} =~ /gi\|(\d+)/);
    }

    &printStatistics(@dna);  # average length at this time, need to add more stat

    unlink $tabFile if -e $tabFile;

    print "Sequence file has been imported. Number of DNA sequences: ", $#dna + 1, "\n";
    print "Processing time: ", usedTime(), " seconds.\n";
}


# a combination of several subs for filter fasta file import
sub importFilterFile {

    my ($fastaFile) = @_;
    my $tabFile = "filter_seq$$.tab"; # intermediate tmp file to store formatted filter file

    # get a tab file format from the original fasta file
    &fastaToTab($fastaFile, $tabFile);

    @filter = importTabSeq($tabFile);
    &printStatistics(@filter);  # average length at this time, need to add more stat

    unlink $tabFile if -e $tabFile;

    print "$fastaFile has been imported. Number of filter DNA sequences: ", $#filter+1, "\n";
    print "Processing time: ", usedTime(), " seconds.\n";
}


sub maskRepeat {

    my $maskedFile = "masked_" . $inputFile;
    system("$dust_dir/dust $inputFile > $maskedFile");

    # intermediate tmp file with PID name to store masked sequence data
    my $tabFile = "masked_seq$$.tab";
    # get a tab file format from the masked fasta file
    &fastaToTab($maskedFile, $tabFile);

    @dna = importTabSeq($tabFile); # import tabFile with masked sequences
    &printStatistics(@dna);

    unlink $tabFile if -e $tabFile;   # get rid of the tab file
    unlink $maskedFile if -e $maskedFile;

    print "Sequence file has been masked and imported. Number of DNA sequences: ", $#dna + 1, "\n";
    print "Processing time: ", usedTime(), " seconds.\n";

}

# will take two input param: tab file name and starting index position for @dna
# the second param is used to import a filter fasta file
# return the number of elements in the @dna array
sub importTabSeq {

     my ($tabFile) = @_;
     my @sequence = ();
     my $index = 0;

     open (IN, "$tabFile") || die("Can not open $tabFile file for reading in importTab sub!\n");
     while (<IN>) {
          chomp;
          ($sequence[$index]{'id'}, $sequence[$index]{'dna'}) = split /\t/, $_;
          $sequence[$index]{'length'} = length($sequence[$index]{'dna'});
          if ($sequence[$index]{'id'} =~ m/gi\|(\d+)/) {
               $sequence[$index]{'gi'} = $1;
          }
          else {
                print "\n\'", $sequence[$index]{'id'}, "' is not in NCBI format.\n";
                print "Please use 'NCBI_format.pl' program in this directory to format you file before using OligoPicker.\n";
                print "Non-NCBI format will be allowed to be used directly in the next release.\n";
                print "Program ended unsuccessfully.\n\n";
                exit;
          }
          next if ($sequence[$index]{'length'} < $oligoLength);
          $sequence[$index]{'dna'} =~ tr/A-Z/a-z/;
          $index++;
     }
     close(IN);

     return @sequence;
}


sub fastaToTab {

     my $id = "";
     my $dna= "";
     my $lastLine = "";

     my ($fastaFile, $tabFile) = @_;

     open (IN, "$fastaFile") || die("Can not open $fastaFile file for reading in fastaToTab sub!\n");
     open (OUT, ">$tabFile") || die("Can not open $tabFile file for writing!\n");

     while (<IN>) {

          chomp $_;
          next if ($_ !~ /\S/);

          if ($_ =~ /^\>/) {
               $id = $_;
               $id =~ s/^\>//;
               if ($lastLine =~ /^\>/) {   # for some casual format with more than one def line per seq
                    $id .= $_;
               }
               else {
                    print OUT "\n" if ($dna ne ""); # not the first line of the file
                    print OUT "$id\t";
                    $id = "";
               }
          }
          else {
               $_ =~ s/\s//g;
               $dna = $_;
               print OUT $dna;
          }
          $lastLine = $_;
     }

     close(IN);
     close(OUT);
}

# get a list of 10-mer duplicate n.t. sequences, and push into a hash
# $keyUnit{'aaatcgagatcaa'} = "1, 45, 3,444, 3, 555"  # gene index1, position1, gene index2, position2......

# get a list of 10-mer duplicate n.t. sequences, and push into a hash
# $keyUnit{'aaatcgagatcaa'} = "1, 45, 3,444, 3, 555"  # gene index1, position1, gene index2, position2......

sub screenDataKey {

     my $keyLength = 10;
     my $keySeq;

     for (my $index = 0; $index <= $#dna; $index++) {

          for (my $position = 0; $position <= $dna[$index]{'length'} - $keyLength; $position++) {

               $keySeq = substr($dna[$index]{'dna'}, $position, $keyLength);
               next if $keySeq =~ m/[^atcg]/;

               if (exists $keyUnit{$keySeq}) {
                     $keyUnit{$keySeq} .= " $index $position";
               }
               else {
                     $keyUnit{$keySeq} = "$index $position";
               }
          }
     }
     print "All input data sequences have been parsed. Processing time: ", usedTime(), " seconds.\n";

} # end of sub screenDataKey

# get a list of 10-mer duplicate n.t. sequences, and push into a hash
# $keyUnit{'aaatcgagatcaa'} = "1, 45, 3,444, 3, 555"  # gene index1, position1, gene index2, position2......

sub screenFilterKey {

     my $keyLength = 10;
     my $keySeq;

     for (my $index = 0; $index <= $#filter; $index++) {

          for (my $position = 0; $position <= $filter[$index]{'length'} - $keyLength; $position++) {

               $keySeq = substr($filter[$index]{'dna'}, $position, $keyLength);
               next if $keySeq =~ m/[^atcg]/;

               if (exists $filterUnit{$keySeq}) {
                     $filterUnit{$keySeq} .= " " . ($index + $#dna + 1) . " $position";
               }
               else {
                     $filterUnit{$keySeq} = ($index + $#dna + 1) . " $position";
               }
          }
     }
     print "All filter sequences have been parsed. Processing time: ", usedTime(), " seconds.\n";

} # end of sub screenFilterKey


# purpose: to select an oligo for each gene that meet tm and cross-hybridization requirement.
# method: for a given oligo, all possible 15-mers are evaluated by using two overlapping 10mers.
#         All 15-mers should be unique in the survived oligo.
sub pickProbe {
     my ($keyLength, $filterKeyLength, $maxScore, $index, $probe_copy) = @_;
     # take the shorter length of $keyLength and $filterKeyLength
     my $shorterKeyLength = ($keyLength <= $filterKeyLength) ? $keyLength : $filterKeyLength;

     my $oligo;   # temp variable to store an oligo for check-up

     if ($endPreference == 5) {

          POSITION: for (my $position = 0; $position <= $dna[$index]{'length'} - $oligoLength; $position++) {

		$oligo = substr($dna[$index]{'dna'}, $position, $oligoLength);

                my $filter_jump_length = simple_filter($oligo);
                if ($filter_jump_length == 1000) {   # tm or non-atcg filters failed
                     next;
                }
                elsif ($filter_jump_length >= 0) { # oligo-oligo self annealing filter failed
                     $position += $filter_jump_length;
                     next;
                }

                # step through the 10-mer unitKeys within the 70-mer (from the 3'-end first)
                for (my $keyIndex = $oligoLength - $shorterKeyLength; $keyIndex >= 0 ; $keyIndex--) {

                        my $unitIndex;
                        if ($hasFilterFile eq 'y') {
                             $unitIndex = keyTest($oligo, $index, $keyIndex, $filterKeyLength, \%filterUnit);
                             if ($unitIndex >= 0 ) {
                                  # the end position of the 15mer
                                  $position += $keyIndex; # the start position of the 14mer
                                  next POSITION;
                             }
                        }

                        $unitIndex = keyTest($oligo, $index, $keyIndex, $keyLength, \%keyUnit);
                        if ($unitIndex >= 0) {
                             # the end position of the 15mer
                             $position += $keyIndex; # the start position of the 15mer
                             $position += 2; # to prevent a trailing 14mer perfect match (now 12-mer match)
                             next POSITION;
                        }

                } # end for keyIndex

               my $annealPosition = anneal($oligo, $index);

	       warn "annealing $oligo, $index, $position";
               if ($$annealPosition[0] >= 0) {
                  $position += $$annealPosition[0] - 1;
                  next;
               }

               my $blastPosition = blast($oligo, $index, $maxScore, $probe_copy);
               if ($$blastPosition[0] >= 0) {  # 0 index for start position
                  $position += $$blastPosition[0] - 1;
                  next;
               }

               # All screenings are ok, recording info and proceed to the next DNA
               $dna[$index]{'oligo'}[$probe_copy] = $oligo; # qualified oligo is found! Go to the next dna seq
               $dna[$index]{'stringency'}[$probe_copy] = "$keyLength - $maxScore";
               $dna[$index]{'position'}[$probe_copy] = $position;

               $probe_copy++;

               if ($probe_copy >= $default_copy) {
                    return $probe_copy;
               }
               else {
                     $position += $oligoLength;
               }
          } # POSITION loop

     }
     else {
           POSITION: for (my $position = $dna[$index]{'length'} - $oligoLength; $position >= 0; $position -= 1) {

               $oligo = substr($dna[$index]{'dna'}, $position, $oligoLength);

               my $filter_jump_length = simple_filter($oligo);
               if ($filter_jump_length == 1000) {
                    next;
               }
               elsif ($filter_jump_length >= 0) {
                    $position -= $oligoLength - $filter_jump_length;
                    next;
               }

               # step through the 10-mer unitKeys within the 70-mer (from the 3'-end first)
               for (my $keyIndex = 0; $keyIndex <= $oligoLength - $shorterKeyLength; $keyIndex++) {

                    my $unitIndex;
                    if ($hasFilterFile eq 'y') {
                         $unitIndex = keyTest($oligo, $index, $keyIndex, $filterKeyLength, \%filterUnit);
                         if ($unitIndex >= 0 ) {
                              # the end position of the 15mer
                              $position -= $oligoLength - ($keyIndex + $filterKeyLength);
                              next POSITION;
                         }
                    }

                    $unitIndex = keyTest($oligo, $index, $keyIndex, $keyLength, \%keyUnit);
                    if ($unitIndex >= 0) {
                         # the end position of the 15mer
                         $position -= $oligoLength - ($keyIndex + $keyLength);
                         $position -= 2; # to prevent a trailing 14mer perfect match (now 12-mer match)
                         next POSITION;
                    }

               } # end for keyIndex


               my $annealPosition = anneal($oligo, $index);
               warn "annealing2 $oligo, $index, $position";  
              if ($$annealPosition[1] >= 0) {   # index 1 for end position
                  $position -= $oligoLength - $$annealPosition[1];
                  next POSITION;
               }

               my $blastPosition = blast($oligo, $index, $maxScore, $probe_copy);
               if ($$blastPosition[1] >= 0) {  # index 1 for end position
                  $position -= $oligoLength - $$blastPosition[1];
                  next POSITION;
               }

               # All screenings are ok, recording info and proceed to the next DNA
               $dna[$index]{'oligo'}[$probe_copy] = $oligo; # qualified oligo is found! Go to the next dna seq
               $dna[$index]{'stringency'}[$probe_copy] = "$keyLength - $maxScore";
               $dna[$index]{'position'}[$probe_copy] = $position;

               $probe_copy++;

               if ($probe_copy >= $default_copy) {
                    return $probe_copy;
               }
               else { # search for the next non-overlapping probe
                     $position -= $oligoLength;
               }

          } # POSITION loop
     }
     return $probe_copy;

} # end of sub pickProbe



sub simple_filter {

    my ($oligo) = @_;

    # skip the region that has low complexity (masked by N) or out-of-range Tm
    return 1000 if (($oligo =~ /[^atcg]/) || (!tmOK($oligo)));

     my $oligo_jump_length = oligo_self_anneal_ok($oligo);
     if ($oligo_jump_length >= 0) {
          return $oligo_jump_length;
     }
    return -1;

}

# check an oligo for repetitive 15-mer and return the index position within the oligo
# input param: $oligo - oligo sequence to be checked; $index - index of DNA sequence;
#              $keyIndex - position in the oligo; $keyLength - crossDegree (15 by default);
sub keyTest {

    my ($oligo, $index, $keyIndex, $keyLength, $unitRef) = @_;

    my @geneList;   # array for unitSeq gene indexes and positions
    my @extGeneList;

    my %extGene;  # hash all extended gene indexes

    my $unitSeq = substr($oligo, $keyIndex, 10);  # 10 bases, smaller than $keyLength
    my $extUnitSeq = substr($oligo, $keyIndex + $keyLength - 10, 10); # extended 10mer, the default keyLength is 15

    # $keyLength and $filterKeyLength can be different, so it is possible to have $unitSeq or $extUnitSeq length < 10
    # However (length($unitSeq)==10)&&(length($extUnitSeq)==10) is not necessary since the hash keys are alwasys 10mers
    if ((exists $$unitRef{$unitSeq}) && (exists $$unitRef{$extUnitSeq})) {

         # create two arrays that contain index, position (alternatively) for specific $keyUnits
         @geneList = split(/ /, $$unitRef{$unitSeq});    # contain gene indexes and positions
         @extGeneList = split(/ /, $$unitRef{$extUnitSeq});

         %extGene = (); # a tmp hash containing extended keyUnit key-value pair (index-position)

         # convert the extended gene index and position into a hash key and value pair
         for (my $extGeneIndex = 0; $extGeneIndex < $#extGeneList; $extGeneIndex += 2) {
              # The value may contain more than one value! Some sequences may have the same 10mer at multiple locations
              $extGene{$extGeneList[$extGeneIndex]} = $extGeneList[$extGeneIndex + 1];
         }

         # step through each gene index in the geneList array
         for (my $geneIndex = 0; $geneIndex < $#geneList; $geneIndex += 2) {

              my $unitIndex = $geneList[$geneIndex];
              my $unitPosition = $geneList[$geneIndex + 1];
              my $extUnitPosition = $unitPosition + $keyLength - 10;

              if (   # if it is not the currently tested gene itself
                 ($unitIndex != $index) &&
                 # and if extended gene index exists (the same with geneList),
                 (exists $extGene{$unitIndex}) &&
                 # and if 15mer match is found (extended position is current position + 5 if keyLength is 15),
                 #($keyUnit{$extUnitSeq} =~ /$unitIndex $extUnitPosition/)
                 (index($$unitRef{$extUnitSeq}, "$unitIndex $extUnitPosition") != -1)
                 )
                 {
                         return $unitIndex;
                 }

         }
    } # end if

    return -1;
}

# calculate gc pecent range 0-1
sub gcPercent {

    ($_) = @_;
    my $length = length($_);
    my $gcCount= 0;
    for (my $j = 0; $j < $length; $j++) {
         if (substr($_, $j, 1) eq 'c' || substr($_, $j, 1) eq 'g') {
              $gcCount++;
         }
    }
    return ($gcCount / $length);

}

# calculate the number of gc bases in a give dna sequence
sub gcCount {

    ($_) = @_;
    my $length = length($_);
    my $gcCount= 0;
    for (my $j = 0; $j < $length; $j++) {
         if (substr($_, $j, 1) eq 'c' || substr($_, $j, 1) eq 'g') {
              $gcCount++;
         }
    }
    return $gcCount;

}


sub medianGCCount {

     # construct a simple hash to sort out the median GC count
     my @tmpArray = ();
     my @sorted = ();
     my $tmpCount = 0;
     my $median;

     for (my $m = 0; $m <= $#dna; $m++) {
          $tmpArray[$m] = gcPercent($dna[$m]{'dna'});
     }

     # get the median GC percentage by sorting the tmpArray
     @sorted = sort {$a <=> $b} @tmpArray;
     $median = $sorted[int(($#dna + 1) / 2)];

     return int($median * $oligoLength + 0.5); # convert % to gc count;

}

sub tmOK {

     # Tm equation:  81.5 + 41 * (($gcCount - 14.63) / $oligoLength)
     ($_) = @_;
     return (abs(gcCount($_) - $medianGC) * 2 < $tmRange * $oligoLength / 41);
}

# input is the gcCount in an oligo
sub tm {

     # Tm equation:  81.5 + 41 * (($gcCount - 14.63) / $oligoLength) from primer3
     my ($gcCount) = @_;
     return int(81.5 + 41 * ($gcCount - 14.63) / $oligoLength);
}

# input is a primer
sub tmSimple {

     # Tm equation:  $tm = 81.5 + 41 * $gcCount / $length - 600 / $length from primer3
     my ($primer) = @_;
     my $gcCount = gcCount($primer);
     my $length = length($primer);
     # print "$gcCount\n";
     my $tm = 81.5 + 41 * $gcCount / $length - 600 / $length;
     return sprintf("%.1f", $tm);
}

# return the self-complementary strand of the input sequence
sub dna_complement {
    my ($sequence) = @_;
    $sequence =~ tr/atcgATCG/tagcTAGC/;
    my @char = split "", $sequence;
    my $complement = join("", reverse(@char));
    return $complement;
}


sub oligo_self_anneal_ok {

    my ($oligo) = @_;
    my $length = length($oligo);
    my $rejected_length = 9;
    my $oligo_complement = dna_complement($oligo);
    my (%forward_hash, %reverse_hash);

    for (my $j = 0; $j <= $length - $rejected_length; $j++) {
         $forward_hash{substr($oligo, $j, $rejected_length)} = 1;
         $reverse_hash{substr($oligo_complement, $j, $rejected_length)} = 1;
    }
    foreach (keys %forward_hash) {
          if (exists $reverse_hash{$_}) {
              return index($oligo, $_);
          }
    }
    return -1;
}


sub prepareBlast {

    mkdir $tmpDirectory;

    $inputFile = "'$inputFile $filterFile'" if -e $filterFile;

    #     -i Input file for formatting
    #     -p Type of file: T - protein; F - nucleotide
    #     -o Parse options: T - true: parse seqId and create indexes; F - false: do not parse
    #     -n  Base name for BLAST files [String]  Optional

    system("$blastDir/formatdb -i $inputFile -p F -o F -n $blastDbName");
    print ("Blast preparation is done!\n");
}

sub anneal {

    my ($oligo, $index) = @_;
    my $sequence = $original_seq[$index]; # there is mask by N.
    $sequence =~ s/(.{70})/$1\n/g; # to make fasta format

    my $oligoFile = "$tmpDirectory/query_oligo.$$";
    my $seqFile = "$tmpDirectory/query_seq.$$";

    open (OLIGO, ">$oligoFile") || die("Can not open file for writing!\n"); # for writing
    print OLIGO ">oligo\n$oligo\n";
    close(OLIGO);

    open (SEQ, ">$seqFile") || die("Can not open file for writing!\n"); # for writing
    print SEQ ">sequence\n$sequence";
    close(SEQ);


    #   -i  First sequence [File In]
    #   -j  Second sequence [File In]
    #   -p  Program name: blastp, blastn, blastx, tblastn, tblastx. For blastx 1st sequence should be nucleotide, tblastn 2nd sequence nucleotide [String]
    #   -o  alignment output file [File Out]  default = stdout
    #   -F  Filter query sequence (DUST with blastn, SEG with others) [String] default = T
    #   -e  Expectation value (E) [Real] default = 10.0
    #   -S  Query strands to search against database (blastn only).  3 is both, 1 is top, 2 is bottom [Integer] default = 3
    #   -D  Output format: 0 - traditional, 1 - tabulated [Integer]  default = 0
    #   -W  Wordsize (zero invokes default behavior) [Integer] default = 0

    # tmpseq_0        tmpseq_1        9.09    11      10      0       36      45      2970    2980    0.054   22.30

    # `system command` will not return anything if there is no output (!exists); system("command") returns 0 if no output
    my @result =
      grep { ! /^#/ } `$blastDir/bl2seq -i $oligoFile -j $seqFile -p blastn -S 2 -D 1 -F F -W $wordSize -e 1000`;
    
#    warn "$blastDir/bl2seq -i $oligoFile -j $seqFile -p blastn -S 2 -D 1 -F F -W $wordSize -e 1000";

    print scalar( @result ), " results\n";


    print $_ for @result;

#    if ( scalar( @result ) == 2 ) {
#      exit;
#    }

    if (exists $result[0]) {
        my @field = split "\t", $result[0];
	
#        return [$field[6]-1, $field[7]-1]; # to fix a bug in bl2seq. 35-44 is wrongly displayed as 36-45
	# this bug has been fixed
	return [$field[6], $field[7]];
    }
    return [-1, -1];
}


# return the failed position (the end position of the blasted region) if any
sub blast {

    my ($oligo, $index, $maxScore, $probe_index) = @_;
    my $gi = $1 if ($dna[$index]{'id'} =~ m/(gi\|\d+)/);
    my $fasta = ">$gi\n$oligo";

    #     -p Program Name: blastn, blastp, etc
    #     -d Database: must be first formatted with formatdb
    #     -i Query File: default - stdin
    #     -e Expectation value
    #     -o Blast output file: default - stdout
    #     -F Filter query sequence (F/T): DUST with blastn
    #     -m Output format: 8 for tab
    #     -I  Show GI's in deflines [T/F]  default = F
    #     -S  Query strands to search against database (for blast[nx], and tblastx).  3 is both, 1 is top, 2 is bottom [Integer] default = 3

    my @result;

    open (OUT, "echo '$fasta' | $blastDir/blastall -p blastn -m 8 -F F -S 1 -e 1000 -d $blastDbName |");

    my @field = ();
    while (<OUT>) {
            # the blast result format is as following:
            # gi|18053  gi|1805353   100.00   1392   0   0    1     1392    1    1392    0.0  2759.9
            chomp;
            @field = split "\t", $_;
            if (index($field[1], $field[0]) == -1) { # not the gene itself
                 if ($field[11] > $maxScore) {
                      return [$field[6], $field[7]];
                 }
                 else {
                       $dna[$index]{'blast'}[$probe_index] = $field[11];
                 }
                 last; # only need to check the first non-self score since the result is sorted by score!
            }
    }
    close(OUT);
    return [-1, -1];
}


sub timeout {

     ($_) = @_;
     $time = (times)[0]; while ((times)[0] - $time < $_){};
}

sub usedTime {

     my $time;
     $time = times() - $oldTime;
     $oldTime = times();
     return int($time);
}


sub printStatistics {

     my @sequence = @_;
     my $totalLength = 0;
     my $index;
     for ($index = 0; $index <= $#sequence; $index++) {
           $totalLength += $sequence[$index]{'length'};
     }
     my $averageLength = int($totalLength / $index);
     print "Average sequence length is $averageLength.\n";

}


sub exportOligo {

     open (OUT, ">$oligoFile") || die("Can not open file for writing!\n");
     for (my $index = 0; $index <= $#dna; $index++) {
     #for (my $index = 0; $index <= 1000; $index++) {
          print OUT $dna[$index]{'id'};
          print OUT "\t";
          print OUT $dna[$index]{'length'};
          print OUT "\t";

          for (my $copy = 0; $copy <= $default_copy; $copy++) {
                    print OUT $dna[$index]{'oligo'}[$copy] if defined $dna[$index]{'oligo'}[$copy];
                    print OUT "\t";
                    print OUT tmSimple($dna[$index]{'oligo'}[$copy]) if defined $dna[$index]{'oligo'}[$copy];
                    print OUT "\t";
                    print OUT $dna[$index]{'position'}[$copy] if defined $dna[$index]{'position'}[$copy];
                    print OUT "\t";
                    print OUT $dna[$index]{'blast'}[$copy] if defined $dna[$index]{'blast'}[$copy];
                    print OUT "\t";
                    print OUT $dna[$index]{'stringency'}[$copy] if defined $dna[$index]{'stringency'}[$copy];
                    print OUT "\t";
                    # stop if no more oligos to write
                    last if (!defined $dna[$index]{'oligo'}[$copy+1]);
          }

          # only a single copy is designed for cross-reacting probe
          if (defined %{$dna[$index]{'redundantGI'}}) {
              my %redundant = %{$dna[$index]{'redundantGI'}};
              my @key = keys %redundant;
              print OUT $#key + 1, "\t";
              foreach (@key) {
                   print OUT $_ . "(" . $redundant{$_} . ") ";
              }
          }
          print OUT "\n";
     }
     close(OUT);

}

# purpose: to select an oligo for each gene that meet tm and cross-hybridization requirement.
# method: for a given oligo, all possible 15-mers are evaluated by using two overlapping 10mers.
#         All 15-mers should be unique in the survived oligo.
sub pickCrossProbe {

     my ($keyLength, $filterKeyLength, $maxScore, $index) = @_;
     # take the shorter length of $keyLength and $filterKeyLength
     my $shorterKeyLength = ($keyLength <= $filterKeyLength) ? $keyLength : $filterKeyLength;

     my $oligo;   # temp variable to store an oligo for check-up

     my $redundantGI;
     my $minRedundantGI = 100000;

     POSITION: for (my $position = $dna[$index]{'length'} - $oligoLength; $position >= 0; $position -= 10) {

               $oligo = substr($dna[$index]{'dna'}, $position, $oligoLength);

               my $filter_jump_length = simple_filter($oligo);
               if ($filter_jump_length == 1000) {
                    next;
               }
               elsif ($filter_jump_length >= 0) {
                    $position -= $oligoLength - $filter_jump_length;
                    next;
               }

               $redundantGI = {}; # re-initialize the redundant GI group before checking a new oligo

               # step through the 10-mer unitKeys within the 70-mer (from the 3'-end first)
               for (my $keyIndex = 0; $keyIndex <= $oligoLength - $shorterKeyLength; $keyIndex++) {

                    my $unitIndex;
                    if ($hasFilterFile eq 'y') {
                         $unitIndex = keyTest($oligo, $index, $keyIndex, $filterKeyLength, \%filterUnit);
                         if ($unitIndex >= 0 ) {
                              # the end position of the 15mer
                              $position -= $oligoLength - ($keyIndex + $filterKeyLength);
                              next POSITION;
                         }
                    }

                    $unitIndex = keyTest($oligo, $index, $keyIndex, $keyLength, \%keyUnit);
                    if ($unitIndex >= 0) {
                         my $gi = $dna[$unitIndex]{'gi'};
                         $$redundantGI{$gi} = "100.00 $keyLength";
                    }
               }  # end of 70-mer key index

               # if the current oligo cross-hybridize to less sequences
               if ($minRedundantGI > scalar(keys %$redundantGI)) {
                    # if anneal to itself
                    my $annealPosition = anneal($oligo, $index);
                    if ($$annealPosition[1] >= 0) {
                         $position -= $oligoLength - $$annealPosition[1];
                         next POSITION;
                    }
                    else {  # check blast score and add in those cross-GI identified only by Blast, not by 15mer filter
                          $redundantGI = blastCross($oligo, $index, $maxScore, $redundantGI);
                          if (exists $$redundantGI{-1}) { # if oligo hybridizes to filter sequence
                              $position -= $$redundantGI{-1}; # the jumpLength from blastCross
                              next POSITION;
                          }
                          # if $minRedundantGI is still > current record after blast, choose this oligo
                          elsif ($minRedundantGI > scalar(keys %$redundantGI)) {
                               $dna[$index]{'oligo'}[0] = $oligo; # only one cross-probe is designed for each sequence
                               $dna[$index]{'position'}[0] = $position;
                               $dna[$index]{'redundantGI'} = $redundantGI;
                               $minRedundantGI = scalar(keys %$redundantGI);
                          }
                    }

              }
              # skip more on the less-promising region
              else {
                    $position -= 20;
              }

          } # POSITION loop

          # It is possible to find unique probes at this stage because every possible position is examined
          # (instead of jump 2 previously). In these cases, the probes are labelled as unique.
          if ($minRedundantGI > 0) {
                $dna[$index]{'stringency'}[0] = "$keyLength - $maxScore - cross";
                return 0;
          }
          else {
                $dna[$index]{'stringency'}[0] = "$keyLength - $maxScore";
                return 1;
          }


} # end of sub pickCrossProbe

# return the failed position (the end position of the blasted region) if any
sub blastCross {

    my ($oligo, $index, $maxScore, $redundantGI) = @_;
    my $gi = $1 if ($dna[$index]{'id'} =~ m/(gi\|\d+)/);
    my $fasta = ">$gi\n$oligo";

    #     -p Program Name: blastn, blastp, etc
    #     -d Database: must be first formatted with formatdb
    #     -i Query File: default - stdin
    #     -e Expectation value
    #     -o Blast output file: default - stdout
    #     -F Filter query sequence (F/T): DUST with blastn
    #     -m Output format: 8 for tab
    #     -I  Show GI's in deflines [T/F]  default = F
    #     -S  Query strands to search against database (for blast[nx], and tblastx).  3 is both, 1 is top, 2 is bottom [Integer] default = 3

    my @result;

    open (OUT, "echo '$fasta' | $blastDir/blastall -p blastn -m 8 -F F -S 1 -e 1000 -d $blastDbName |");

    my @field = ();
    while (<OUT>) {
            # the blast result format is as following:
            # gi|18053  gi|1805353   100.00   1392   0   0    1     1392    1    1392    0.0  2759.9
            chomp;
            @field = split "\t", $_;
            # not the gene itself and > threshold score
            if (index($field[1], $field[0]) == -1 && $field[11] > $maxScore) {
                if ($field[1] =~ m/gi\|(\d+)/) {
                     if (exists $original_gi{$1}) {
                         $$redundantGI{$1} = "$field[2] $field[3]";   # % of identity and aligned length, e.g. 100 70
                     }
                     else { # aligned with the filter file
                           return {-1, $oligoLength - $field[7]};
                     }
                }

            }
    }
    close(OUT);
    return $redundantGI;
}
