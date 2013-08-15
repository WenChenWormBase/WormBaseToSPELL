#!/usr/bin/perl -w
#This merge expression values in each file into one value per gene

use strict;

my ($file, $line, $outfile, $gene, $expr);
my @inputfile;
my %geneExist;
my %totalValue; #total expr value for all spots per gene
my %countValue; #number of spots per gene
my @tmp;

open (IN1, "exprFileList.txt") || die "cannot open $!\n";
my $i = 0;
while ($line = <IN1>) {
     chomp($line);
     $inputfile[$i] = $line;
     $i++;     
}
close (IN1);

foreach $file (@inputfile) {
    $outfile = join "", $file, "mergevalue";

    open (IN, "$file") || die "cannot open $!\n";
    $i = 0; #this is to count the total number of genes
    my @geneList = ();
    %geneExist = ();
    while ($line=<IN>) {
	chomp ($line);
	@tmp = split /\t/, $line;
	$gene = $tmp[0];
	$expr = $tmp[1];
	#print "$gene -- $expr\n";
	next unless ($gene =~ /^WBGene/);
	next unless ($expr ne "");
	if ($geneExist{$gene}) {
	    $totalValue{$gene} = $totalValue{$gene} + $expr;
	    $countValue{$gene}++;
	} else { #new gene
	    $geneExist{$gene} = 1;
	    $totalValue{$gene} = $expr;
	    $countValue{$gene} = 1;
	    $geneList[$i] = $gene;
	    $i++;
	}	    
    }
    close (IN);
    print "$i genes found in $file\n";
    
    open (OUT, ">$outfile") || die "cannot open $!\n";
    foreach $gene (@geneList) {
	$expr = $totalValue{$gene}/$countValue{$gene};
	print OUT "$gene\t$expr\n";
    } 
    close (OUT);
}

