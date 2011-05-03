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

my ($helpFlag, $xmlFile, $amosFile, $outFile, $verbose, $quiet);

GetOptions(
	"h|?|help"		=> \$helpFlag,	
	"xml=s"			=> \$xmlFile,		## input file
	"amos=s"			=> \$amosFile,		## input file
	"output=s"		=> \$outFile,		## output file
	"verbose+"		=> \$verbose,		## verbose output
	"quiet"			=> \$quiet,
) || die "\n";

checkOptions();

my (%contigs, $out);

load($amosFile);
process($xmlFile);


#-------------------------------------------------------------------------------

sub load
{
	my ($fileName) = @_;

	print "Loading ", $fileName || 'STDIN', " ...\n" if !$quiet;
	my $in = openInput($fileName);
	my ($flag, $uid, $eid, $seq);

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;

		if    (/{CTG/)      { $flag = 1; }
		elsif (!$flag)      {}
		elsif (/iid:(\S+)/) { $iid = $1; }
		elsif (/eid:(\S+)/) { $eid = $1; }
		elsif (/seq:/)
		{
			$seq = '';
			while (<$in>)
			{
				last if /^\./;
				chop;
				$seq .= $_;
			}
			$seq =~ s/-//g;
			$contigs{$eid} = [$iid, length($seq)];
			$flag = 0;
		}
	}

	close($in) if defined $fileName;
}

sub process
{
	my ($fileName) = @_;

	print "Processing ", $fileName || 'STDIN', " ...\n" if !$quiet;
	my $in = openInput($fileName);
	$out = openOutput($outFile);
	my ($sid, @buf);

	while (<$in>)
	{
		next if /^#/ || /^\s*$/;
		my @a = split;

		if    (/<SCAFFOLD\s+ID\s*=\s*"(.+)"/i)      { $sid = $1; @buf = (); }
		elsif (/<CONTIG\s+ID\s*=\s*"contig_(.+)"/i) { push(@buf, [$1]); }
		elsif (/X\s*=\s*"([\+\-\d]+)"/i)            { $buf[-1][1] = $1; }
		elsif (/ORI\s*=\s*"(.+)"/i)                 { $buf[-1][2] = $1; }
		elsif (/<\/SCAFFOLD>/i)                     { onScaffold($sid, \@buf); }
	}

	close($in) if defined $fileName;
}

sub onScaffold
{
	my ($sid, $rcontigs) = @_;

	print $out "{SCF\n";
	print $out "iid:", ++$iid, "\n";
	print $out "eid:$sid\n";

	for (my $i = 0; $i < @$rcontigs; $i++)
	{
		writeContig($rcontigs->[$i][0], $rcontigs->[$i][1], $rcontigs->[$i][2] eq 'BE');
	}

	print $out "}\n";
}

sub writeContig
{
	my ($cid, $pos, $dir) = @_;

	print $out "{TLE\n";
	print $out "src:$contigs{$cid}[0]\n";
	print $out "off:$pos\n";
	print $out "clr:", $dir ? "0,$contigs{$cid}[1]" : "$contigs{$cid}[1],0", "\n";
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
	$xmlFile  = shift(@ARGV) if !defined $xmlFile  && @ARGV > 0;
	$outFile = shift(@ARGV) if !defined $outFile && @ARGV > 0;
	die "The output file name is the same as the input file name\n" if defined $xmlFile && defined $outFile && $xmlFile eq $outFile;
	die "The output file name is the same as the input file name\n" if defined $amosFile && defined $outFile && $amosFile eq $outFile;

	if ($helpFlag || (!$amosFile && !$xmlFile))
	{
		die("Arguments: [-amos] amos_file [-xml] bambus_xml_file [[-o] out_file] [-v] [-q]\n"
		  . "\t\n"
		  );
	}
}
