#! /usr/bin/perl

use warnings;
use strict;

use GD;

use Tree;



my $st1 = Tree->new( 'Predict Protein Function' );
$st1->add_child( Tree->new('wu-blastp'), Tree->new( 'signalp' ) );


my $st2 = Tree->new( 'Magic' );
$st2->add_child($st1);

my $st3 = Tree->new( 'Gene Curation' );
$st3->add_child( $st2, Tree->new('targetp') );

# this is the tree
my $tree = Tree->new( 'glimmer' );
$tree->add_child( $st3 );


my $image = GD::Image->new('example-pipeline.png');

my $white = $image->colorClosest(255,255,255);

my $grey = $image->colorAllocate(227,227,227);

my $green = $image->colorAllocate(124,255,0);

# change the color in 

for ( my $i = 223; $i <= 363; $i++ ) {
  for ( my $j = 58; $j <= 113; $j++ ) {
    $image->setPixel($i,$j,$green) if $image->getPixel($i,$j) == $white;
  }
}
 

#print "White is $white.\n";
#my $first = $image->getPixel(223,58);
#print "First Index is $first.\n";
#my $second = $image->getPixel(222,58);
#print "Second Index is $second.\n";
#print "Closest to White is ", $image->rgb($white), ".\n";

binmode STDOUT;

print $image->png;

