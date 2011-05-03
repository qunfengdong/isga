#!/usr/bin/perl -w
use strict;
#use File::Basename;
use Bio::SearchIO;
use YAML;

my $file = shift;
#my $out =  basename($file) . ".html";
my $out =  $file . ".txt";

open my $ifh, '<', $file || die "File Open Error: $file\n";
#open(OUT, ">$out") || die "File Open Error: $out\n";
my $in = new Bio::SearchIO(-format => 'blast',
                           -fh     => $ifh);

my $yaml = "/research/projects/isga/sw/db/Tair9/TAIR9_locus_type/TAIR9_locus_type";
#my $gene_model = YAML::LoadFile($yaml);

my %print_results;
# parse each blast record:
while( my $result = $in->next_result ) {

    # parse each hit per record.
    while( my $hit = $result->next_hit ) {

        # a hit consists of one or more HSPs
        while( my $hsp = $hit->next_hsp ) {
            my @x;
# query_name
            $x[0] = $result->query_name();
# query_description
  # parse for contig ID
  # org=contig01342 gene=isogroup00001 length=1011
            $result->query_description() =~ /org\=((contig|isotig)\d+)/o and $x[1] = $1;
if (not defined $x[1] or $x[1] eq ''){
   print $result->query_description(), "\n";
}
# query_length
            $x[2] = $result->query_length();
# hit_name
  # locus ID
            $x[3] = $hit->name();
# percent_identity
            $x[4] = sprintf ("%.1f", $hsp->percent_identity());
# raw_score
            $x[5] = $hsp->score();
# hit_description
# Symbols: | glutamine amidotransferase class-I domain-containing protein | chr4:14925410-14926861 FORWARD
            my $hit_descr = $hit->description();
            $hit_descr =~ s/^\|\s*//;
            my @description = split(/\|/, $hit_descr);
# Hit Symbol
            $x[6] = shift(@description);
            $x[6] =~ s/Symbols\: //o;
            $x[6] = "No Symbol Available" if $x[6] =~ /^\s*$/g;
# Hit Description
            $x[7] = shift(@description);
            $x[7] =~ s/^\s+//o;
            $x[7] =~ s/\s+$//o;
            my $coordinate = pop(@description);
            $coordinate =~ s/ (FORWARD|REVERSE)$//o;
            $coordinate =~ s/ //go;
            $coordinate =~ s/(\d+)\-(\d+)/$1..$2/o;
# hit length
            $x[8] = $hit->length();
# e_value
            $x[9] = $hsp->evalue();
# GBrowse coordinate
#            $x[10] = $coordinate;
            $x[10] = 'http://ram1-dev.cgb.indiana.edu/webgbrowse/cgi-bin/gbrowse/454?name='.$coordinate;
            if ( (not defined $print_results{$x[0]}) || ( $print_results{$x[0]}[9] > $x[9] )){
               $print_results{$x[0]} = [ @x ];
            } elsif ($print_results{$x[0]}[9] == $x[9]) {
               $print_results{"$x[0]_2"} = [ @x ];
            }
            undef @x;
        }
    }
}
close $ifh;

my $gene_model = YAML::LoadFile($yaml);

open(OUT, ">$out") || die "File Open Error: $out\n";
print OUT "Isotig ID\tContig ID\tContig length\tLocus Identifier\tPercent Identity\te-value\tRaw Score\tGene Length\tPrimary Gene Symbol\tGene Model Description\tGene Model Type\tURL\n";
foreach my $key (sort (keys(%print_results))){
#print OUT "$print_results{$key}[0]\t$print_results{$key}[1]\t$print_results{$key}[2]\t$print_results{$key}[3]\t$print_results{$key}[4]\t$print_results{$key}[9]\t$print_results{$key}[5]\t$print_results{$key}[8]\t$print_results{$key}[6]\t$print_results{$key}[7]\t-\t$print_results{$key}[10]\n";

my $model_key = $print_results{$key}[3];
$model_key =~ s/\.\d$//;

print OUT "$print_results{$key}[0]\t";
print OUT "$print_results{$key}[1]\t";
print OUT "$print_results{$key}[2]\t";
print OUT "$print_results{$key}[3]\t";
print OUT "$print_results{$key}[4]\t";
print OUT "$print_results{$key}[9]\t";
print OUT "$print_results{$key}[5]\t";
print OUT "$print_results{$key}[8]\t";
print OUT "$print_results{$key}[6]\t";
print OUT "$print_results{$key}[7]\t";
if (defined $gene_model->{$model_key}){
  print OUT "$gene_model->{$model_key}\t";
} else {
  print OUT "Gene Model Type Not Found\t";
}
print OUT "$print_results{$key}[10]\n";

#print OUT ' <tr>'."\n";
#print OUT '  <td>'.$print_results{$key}[0].'</td>'."\n";
#print OUT '  <td><a href="http://ram1-dev.cgb.indiana.edu/webgbrowse/cgi-bin/gbrowse/454?name='.$print_results{$key}[4].'">'.$print_results{$key}[1].'</a></td>'."\n";
#print OUT '  <td>'.$print_results{$key}[3].'</td>'."\n";
#print OUT '  <td>'.$print_results{$key}[2].'</td>'."\n";
#print OUT ' </tr>'."\n";

}
#close $ifh;
close OUT;
exit;
