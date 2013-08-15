#!/usr/bin/perl -w
#This script parse Tiling array expression tables into PCL files, which will later be parsed into SPELL expression table. 

use strict;

my ($line, $gene, $paper, $exprLinear, $expr, $geneid, $totalCond, $sample, $CondDesc, $numGene);
my $totalTilingPaper = 0;
my %GeneExprAll;
my %GeneExprOne;
my %DataLineCSV;
my %GeneExist;
my @tmp;
my @stuff;
my @GeneList;
my @exp;
my @TilingPaper;
my %samplePaper;
my %paperRecord;
my %totalCondPaper;

#------Get Sample-Analysis table-----------
#---find Analysis Database = "SRA"--------------
open (ANAL, "/home/wen/WormBaseToSPELL/ace_files/WBCeTARSample.ace") || die "cannot open $!\n";
while ($line = <ANAL>) {
    if ($line =~ /^Condition : /) {
	#get sample name
	@tmp = split '"', $line;
	$sample = $tmp[1];
	#print "found sample: $sample\n";
    } elsif ($line =~ /^Reference/) {
	@tmp = split '"', $line;
	$paper = $tmp[1];
	$samplePaper{$sample} = $paper;
	#print "found sample: $sample in $paper\n";
	if ($paperRecord{$paper}) {
	    #this paper is already in record, skip
	    $totalCondPaper{$paper}++;
	} else {
	    $TilingPaper[$totalTilingPaper] = $paper;
	    $totalTilingPaper++;
	    $paperRecord{$paper} = 1;
	    $totalCondPaper{$paper} = 1;
	}
    }	
}
close (ANAL);
print "$totalTilingPaper Tiling Array papers found in WS.\n";
#print "$totalCondPaper{$paper} samples found in $paper.\n";

#get the name of all input expr level files
my $i = 0;
my @inputfile;

open (IN1, "exprFileList.txt") || die "cannot open $!\n";
#open (IN1, "tempFileList.txt") || die "cannot open $!\n";
while ($line = <IN1>) {
     chomp($line);
     $inputfile[$i] = join "", $line, "mergevalue";
     $i++;     
 }
$totalCond = @inputfile;
print "$totalCond experiments found in the exprFileList.txt\n";
close (IN1);
#------------done getting all the input file names. -----------


foreach $paper (@TilingPaper) { 
    $geneid = 0;
    %GeneExprAll = ();
    %GeneExprOne = ();
    %DataLineCSV = ();
    %GeneExist = ();
    @GeneList = ();
    print "$totalCondPaper{$paper} sample found in $paper in WormBase.\n";
    open (OUT, ">$paper.ce.tr.paper")  || die "cannot open $!\n";
    open (CSV, ">$paper.ce.tr.csv")  || die "cannot open $!\n";
    open (COND, ">$paper.ce.tr.cond")  || die "cannot open $!\n";

    #print OUT "name\tname\tGWEIGHT\t", join("\t", @inputfile), "\n";
    print OUT "name\tname\tGWEIGHT";
    print CSV "name";

    #update mr_data table
    my $file;
    $i = 0;
    foreach $file (@inputfile) {
	print "$file ... ";
	#take condition information, make sure the sample exists in WS
	($stuff[0], $stuff[1]) = split /\./, $file;
	($stuff[3], $sample) = split /genes_/, $stuff[0];
	#print "$file -- $sample\n";

	next unless ($samplePaper{$sample});
	next unless ($samplePaper{$sample} eq $paper);

	open (IN2, "$file") || die "cannot open $!\n";	
	%GeneExist = ();    

	$exp[$i] = $sample;      
	print OUT "\t$exp[$i]";
	print CSV "\t$exp[$i]";
	
	if ($i == 0) {
	    $CondDesc = $exp[$i];
	} else {
	    $CondDesc = "$CondDesc~$exp[$i]";
	}

	while ($line = <IN2>) {
	    chomp($line);
	    ($gene, $exprLinear) = split /\s+/, $line;
	
	    #log2 transform expression level
	    if ($exprLinear eq "") {
		$expr = "\\N";
	    } elsif ($exprLinear == 0) {
		$expr = "\\N";
	    } else {
		$expr = log($exprLinear)/log(2);
	    }
	
	    #prepare dataline for the first expr file. 
	    if ($i==0) {
		if ($GeneExist{$gene}) {
		    print "$file duplicate gene entry: $gene\n";
		} else {
		    $GeneExist{$gene} = 1;
		    $GeneList[$geneid] = $gene;
		    $GeneExprAll{$gene} = "$gene\t$gene\t1\t$expr";
		    $DataLineCSV{$gene} = "$gene\t$expr";
		    $geneid++;
		}
	    } 

	    #this is what to do when dealing with the other files. 
	    if ($i > 0) {
		if ($GeneExist{$gene}) {
		    print "duplicate gene entry: $gene\n";
		} else {
		    $GeneExist{$gene} = 1;
		    $GeneExprOne{$gene} = $expr;
		}	   
	    }

	}

	#prepare dataline for the second and later expr file
	if ($i > 0) {
	    foreach $gene (@GeneList) {
		if ($GeneExprOne{$gene}) {
		    $GeneExprAll{$gene} = "$GeneExprAll{$gene}\t$GeneExprOne{$gene}";
		    $DataLineCSV{$gene} = "$DataLineCSV{$gene}\t$GeneExprOne{$gene}";
		} else {
		    $GeneExprAll{$gene} = "$GeneExprAll{$gene}\t\\N";
		    $DataLineCSV{$gene} = "$DataLineCSV{$gene}\t\\N";
		}
	    }
	}
    
	print "done.\n";

	close (IN2);
	%GeneExprOne = ();
	$i++;

    }

    $totalCond = $i;
    print "$i sample files found for $paper. WS contains $totalCondPaper{$paper} experiments for $paper.\n";
    #print out condition file
    $numGene = @GeneList;
    print COND "$numGene\t$i\t$CondDesc\n";

    print OUT "\nEWEIGHT\t\t";
    for ($i=0; $i<$totalCond; $i++) {
	print OUT "\t1";
    }
    print OUT "\n";

    print CSV "\n";

    #print out the PCL file
    foreach $gene (@GeneList) {
	#print "$gene\n";
	print OUT "$GeneExprAll{$gene}\n";
	print CSV "$DataLineCSV{$gene}\n";
    }

    close (OUT);
    close (CSV);
    close (COND);
}

