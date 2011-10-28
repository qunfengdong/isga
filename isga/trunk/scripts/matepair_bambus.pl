#!/usr/bin/perl -w
#!/usr/local/bin/perl -w
#!/bin/perl -w

## Author: Jeong-Hyeon Choi
## Date: Sep 20 2007

## make read pairs from reads.placed and either sequence file or length file
## this script can be run in 3 kinds of auxiliary parameters
## 1) -n library_name -a average_length -d stdev
## 	all paired reads are in a library
## 2) -l library_file -r read_file
##		each line in read file specifies
##			<read prefix> <library name>
##		each line in library file specifies
##			<library name> <average insert length> <standard deviation>
##		and it can be generated by the following command for each library
##			echo `grep '^>' read.fna | cut -c 2-10 | sort | uniq` library_name
## 3) -l library_file -s sff_dir
##		each line in library file specifies
##			<library name> <average insert length> <standard deviation>
## $Id$

my $readPrefixLen = 9;

use Getopt::Long qw(:config no_ignore_case);

my ($helpFlag, $inFile, $outFile, $verbose, $quiet, $libFile, $sffDir, $readFile, $libName, $libAvg, $libStdev);
my (%libs, %region2lib, %pairs);

GetOptions(
	"h|?|help"		=> \$helpFlag,	
	"input=s"		=> \$inFile,		## input file
	"output=s"		=> \$outFile,		## output file
	"verbose+"		=> \$verbose,		## verbose output
	"quiet"			=> \$quiet,
	"lib=s"			=> \$libFile,
	"sff=s"			=> \$sffDir,
	"read=s"			=> \$readFile,
	"name=s"			=> \$libName,
	"avg=s"			=> \$libAvg,
	"stdev=s"		=> \$libStdev,
) || die "\n";

checkOptions();

loadLibrary($libFile) if $libFile;
loadRead($readFile) if $readFile;
process($inFile);
output();


#-------------------------------------------------------------------------------

sub loadLibrary
{
	my ($fileName) = @_;

	print STDERR "Loading $fileName ...\n" if $fileName && !$quiet;
	my $in = openInput($fileName);

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;
		my @a = split;
		my $l = $a[0]; $l =~ s/\.sff$//;
		$libs{$l} = [@a[1,2]];

		die "Not found: sffinfo\n" if !`which /cluster/454/bin/sffinfo`;
		my $sff = openInput("/cluster/454/bin/sffinfo -s $sffDir/$a[0] |");
		while (<$sff>)
		{
			$region2lib{region($1)} = $l if (/^>(\S+)/);
		}
		close($sff);
	}

	close($in) if defined $fileName;
}

sub loadRead
{
	my ($fileName) = @_;

	print STDERR "Loading $fileName ...\n" if $fileName && !$quiet;
	my $in = openInput($fileName);

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;
		my @a = split;
		foreach my $r (@a[0..$#a-1])
		{
			die "Wrong read prefix: $r\n" if length($r) != $readPrefixLen;
			$region2lib{$r} = $a[-1];
		}
	}

	close($in) if defined $fileName;
}

sub process
{
	my ($fileName) = @_;

	print STDERR "Processing $fileName ...\n" if $fileName && !$quiet;
	my $in = openInput($fileName);

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;
		my @a = split;
		if ($a[1] =~ /_(left|right)\.\S+/)
		{
			$pairs{$`}{$1} = $a[1];
		}
	}

	close($in) if defined $fileName;
}

sub output
{
	my ($fileName) = @_;

	print STDERR "Saving $fileName ...\n" if $fileName && !$quiet;
	my $out = openOutput($outFile);

	die "No library\n" if !keys %libs;

	foreach my $l (sort keys %libs)
	{
		print $out join("\t", 'library', "$l", $libs{$l}[0]-int($libs{$l}[1]*2), $libs{$l}[0]+int($libs{$l}[1]*2)), "\n";
	}

	foreach my $p (keys %pairs)
	{
		next if !exists $pairs{$p}{'left'} || !exists $pairs{$p}{'right'};
		my $r = region($p);
		my $l;
		if ($libFile)
		{
			die "Unknown library for the region $r\n" if !exists $region2lib{$r};
			$l = $region2lib{region($p)};
		}
		else
		{
			$l = (keys(%libs))[0];
			die "Unknown library for the region $r\n" if !$l;
		}
		print $out join("\t", $pairs{$p}{'left'}, $pairs{$p}{'right'}, $l), "\n";
	}
}

sub region
{
	my ($str) = @_;
	return substr($str, 0, $readPrefixLen);
}

#-------------------------------------------------------------------------------

sub openInput
{
	my ($fileName) = @_;

	return STDIN unless defined $fileName;

	my ($fd);
	open($fd, $fileName) || die("Open error: $fileName");
	return $fd;
}

sub openOutput
{
	my ($fileName) = @_;

	return STDOUT unless defined $fileName;

	my ($fd);
	open($fd, ">$fileName") || die("Open error: $fileName");
	return $fd;
}

sub checkOptions
{
	$inFile  = shift(@ARGV) if !defined $inFile  && @ARGV > 0;
	$outFile = shift(@ARGV) if !defined $outFile && @ARGV > 0;
	die "The output file name is the same as the input file name\n" if defined $inFile && defined $outFile && $inFile eq $outFile;

	if ($helpFlag || !$inFile || (!$libFile && !$libName && !$libAvg && !$libStdev) || ($libFile && !$readFile && !$sffDir))
	{
		die("Arguments: <option> [-i] reads.placed [[-o] out_file] [-v]\n"
		  . "\t-n library_name -a averarge_length -stdev stdev\n"
		  . "\t-l library_file -r read_file\n"
		  . "\t-l library_file -sff sff_dir\n"
		  );
	}

	$libs{$libName} = [$libAvg, $libStdev] if ($libName);

	$sffDir = '.' if !$sffDir;
}