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

my ($helpFlag, $agpFile, $amosFile, $outFile, $verbose, $quiet);

GetOptions(
	"h|?|help"		=> \$helpFlag,	
	"agp=s"			=> \$agpFile,		## input file
	"amos=s"			=> \$amosFile,		## input file
	"output=s"		=> \$outFile,		## output file
	"verbose+"		=> \$verbose,		## verbose output
	"quiet"			=> \$quiet,
) || die "\n";

checkOptions();

my (%contigs, $out);

load($amosFile);
process($agpFile);


#-------------------------------------------------------------------------------

sub load
{
	my ($fileName) = @_;

	print "Loading ", $fileName || 'STDIN', " ...\n" if !$quiet;
	my $in = openInput($fileName);
	my ($flag, $uid, $eid);

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;

		if (/{CTG/) { $flag = 1; }
		elsif (/seq:/) { $contigs{$eid} = $iid if $flag; $flag = 0; }
		elsif (!$flag) {}
		elsif (/iid:(\S+)/) { $iid = $1; }
		elsif (/eid:(\S+)/) { $eid = $1; }
	}

	close($in) if defined $fileName;
}

sub process
{
	my ($fileName) = @_;

	print "Processing ", $fileName || 'STDIN', " ...\n" if !$quiet;
	my $in = openInput($fileName);
	$out = openOutput($outFile);
	my @lines;

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;
		my @a = split;

		if (@lines && $lines[0][0] ne $a[0])
		{
			onScaffold(\@lines);
			@lines = ();
		}

		push(@lines, \@a) if $a[4] ne 'N';
	}

	onScaffold(\@lines);
	close($in) if defined $fileName;
}

sub onScaffold
{
	my ($rlines) = @_;

	print $out "{SCF\n";
	print $out "iid:", ++$iid, "\n";
	print $out "eid:$rlines->[0][0]\n";

	for (my $i = 0; $i < @$rlines; $i++)
	{
		writeContig($rlines->[$i][5], $rlines->[$i][1], $rlines->[$i][7]-1, $rlines->[$i][8] eq '+');
	}

	print $out "}\n";
}

sub writeContig
{
	my ($cid, $pos, $len, $dir) = @_;

	print $out "{TLE\n";
	print $out "src:$contigs{$cid}\n";
	print $out "off:$pos\n";
	print $out "clr:", $dir ? "0,$len" : "$len,0", "\n";
	print $out "}\n";
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
	$amosFile  = shift(@ARGV) if !defined $amosFile  && @ARGV > 0;
	$agpFile  = shift(@ARGV) if !defined $agpFile  && @ARGV > 0;
	$outFile = shift(@ARGV) if !defined $outFile && @ARGV > 0;
	die "The output file name is the same as the input file name\n" if defined $agpFile && defined $outFile && $agpFile eq $outFile;
	die "The output file name is the same as the input file name\n" if defined $amosFile && defined $outFile && $amosFile eq $outFile;

	if ($helpFlag || (!$amosFile && !$agpFile))
	{
		die("Arguments: [-amos] amos_file [-agp] agp_file [[-o] out_file] [-v] [-q]\n"
		  . "\t\n"
		  );
	}
}
