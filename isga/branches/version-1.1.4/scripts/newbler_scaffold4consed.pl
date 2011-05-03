#!/usr/bin/perl -w
#!/usr/local/bin/perl -w
#!/bin/perl -w

## Author: Jeong-Hyeon Choi
## Date: 2009

## Description

## Usage:
## CHECK usage with option  -h

## $Id: perl_template,v 1.2 2007-09-21 22:51:23 jeochoi Exp $


use Getopt::Long qw(:config no_ignore_case);
use POSIX qw(strftime);

my ($helpFlag, $agpFile, $inFile, $outFile, $verbose, $quiet);

GetOptions(
	"h|?|help"		=> \$helpFlag,	
	"agp=s"			=> \$agpFile,		## input file
	"input=s"		=> \$inFile,		## input file
	"output=s"		=> \$outFile,		## output file
	"verbose+"		=> \$verbose,		## verbose output
	"quiet"			=> \$quiet,
) || die "\n";

checkOptions();

my (%scaffolds, %contigs);

load($agpFile);
process($inFile);


#-------------------------------------------------------------------------------

#scaffold00001   1       578     1       W       contig00001     1       578     +
#scaffold00001   579     2441    2       N       1863    fragment        yes
#scaffold00001   2442    3568    3       W       contig00002     1       1127    +
sub load
{
	my ($fileName) = @_;

	print "Loading ", $fileName || 'STDIN', " ...\n" if !$quiet;
	my $in = openInput($fileName);

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;
		my @a = split;
		push(@{$scaffolds{$a[0]}}, $a[5]) if $a[4] eq 'W';
	}

	close($in) if defined $fileName;
}

#CO contig00001 585 44 21 U
#GCGTTGTTGCGCACCAGGGCAATGTTGGCGGCGAGGCTGCGGCCTtcGGT
sub process
{
	my ($fileName) = @_;

	print "Processing ", $fileName || 'STDIN', " ...\n" if !$quiet;
	my $in = openInput($fileName);
	my $out = openOutput($outFile);
	my $cid;
	my $flag = 0;

	while (<$in>)
	{
		if (/^CO\s+(\S+)\s+(\d+)/)
		{
			$cid = $1;
			$contigs{$cid}[0] = $2;
			$flag = 1;
		}
		elsif ($flag == 1)
		{
			$contigs{$cid}[1] = substr($_, 0, 1);
			$contigs{$cid}[2] = substr($_, length($_)-2, 1);
			$flag = 2;
		}
		elsif (/^\s*$/ || /^BQ/)
		{
			$flag = 0;
		}
		elsif ($flag == 2)
		{
			$contigs{$cid}[2] = substr($_, length($_)-2, 1);
		}

		print $out $_;
	}

	close($in) if defined $fileName;

	writePairs(\%scaffolds, \%contigs, $out);
}

#CT{
#contig00067 contigEndPair consed 1 1 100407:163445
#1
#<-gap
#c
#}
#
#CT{
#contig00066 contigEndPair consed 1979 1979 100407:163445
#1
#gap->
#c
#}
#
sub writePairs
{
	my ($rscaffolds, $rcontigs, $out) = @_;
	my $no = 1;
	my $date = strftime "%y%m%d:%H%M%S", localtime;

	foreach my $sid (sort keys %$rscaffolds)
	{
		for (my $i = 1; $i < @{$rscaffolds->{$sid}}; $i++, $no++)
		{
			my ($fid, $tid) = @{$rscaffolds->{$sid}}[$i-1,$i];
			my ($fb, $tb) = (lc($contigs{$fid}[2]), rc($contigs{$tid}[1]));
			print $out qq(
CT{
$fid contigEndPair newbler $contigs{$fid}[0] $contigs{$fid}[0] $date
$no
gap->
$fb
}

CT{
$tid contigEndPair newbler 1 1 $date
$no
<-gap
$tb
}
);
		}
	}
}

sub rc
{
	my ($b) = @_;
	$b =~ tr/ACGTNacgt/tgcantgca/;
	return $b;
}

#-------------------------------------------------------------------------------

sub openInput
{
	my ($fileName) = @_;

	return *STDIN unless defined $fileName;

	my ($fd);
	open($fd, $fileName =~ /.gz(ip)?$/ ? "zcat $fileName |" : $fileName =~ /.bz(ip)?2$/ ? "bzcat $fileName |" : $fileName) || die("Open error: $fileName");
	return $fd;
}

sub openOutput
{
	my ($fileName) = @_;

	return *STDOUT unless defined $fileName;

	my ($fd);
	open($fd, $fileName =~ /.gz$/ ? "| gzip -c > $fileName" : $fileName =~ /.bz(ip)?2$/ ? "| bzip2 -z -c > $fileName" : ">$fileName") || die("Open error: $fileName");
	return $fd;
}

sub checkOptions
{
	$inFile  = shift(@ARGV) if !defined $inFile  && @ARGV > 0;
	$outFile = shift(@ARGV) if !defined $outFile && @ARGV > 0;
	die "The output file name is the same as the input file name\n" if defined $inFile && defined $outFile && $inFile eq $outFile;

	if ($helpFlag || (!$agpFile && !$inFile))
	{
		die("Arguments: -t map_file [[-i] in_file] [[-o] out_file] [-v] [-q]\n"
		  . "\t\n"
		  );
	}
}
