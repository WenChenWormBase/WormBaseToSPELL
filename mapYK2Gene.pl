#!/usr/bin/perl -w

use strict;
use Ace;

my @gene;
my @seq;
my %cloneGene;
my ($s, $clone, $cds, $gene);

print "This script create yk clone -- Gene table from current WS release.\n";

my $acedbpath='/home/citace/WS/acedb/';
my $tace='/usr/local/bin/tace';

print "connecting to database... ";
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;
open (OUT, ">mapping/ykClone_mapping.csv") || die "can't open $!";

#------------Build Gene Name hash------------------------------------- 
my $query="QUERY FIND Sequence yk*";
@seq = $db->find($query);
foreach $s (@seq) {
        if ($s->Clone) {
	    $clone = $s->Clone;
	} else {
	    $clone = "";
	}
	
	if ($s->Matching_CDS) {
	    $cds = $s->Matching_CDS;
	    if ($cds->Gene) {
		$gene = $cds->Gene;
	    } else {
		$gene = "";
	    }
	} else {
	    $gene = "";
	}

	if (($clone ne "")&&($gene ne "")) {
	    print OUT "A-MEXP-41_$clone\t$gene\n";
	}
}
close(OUT);
$db->close();
