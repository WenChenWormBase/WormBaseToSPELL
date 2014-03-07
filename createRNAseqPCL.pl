#!/usr/bin/perl -w
#This script parse RNAseq expression tables into PCL files, which will later be parsed into SPELL expression table. 

use strict;

if ($#ARGV !=0) {
    die "usage: $0 series_file ace\n";
}
my $specode = $ARGV[0];
my %speName = ("cbg" => "Caenorhabditis briggsae",
	       "cbn" => "Caenorhabditis brenneri",
	       "cja" => "Caenorhabditis japonica",
	       "cre" => "Caenorhabditis remanei",
	       "ce" => "Caenorhabditis elegans",
	       "ppa" => "Pristionchus pacificus");

if ($speName{$specode}) {
    print "***** Prepare PCL files for RNAseq data for $speName{$specode} *****\n";    
} else {
    die "Species code $specode is not recognized.\n";
}


my ($line, $gene, $paper, $exprLinear, $expr, $geneid, $totalCond, $sample, $stuff, $CondDesc, $numGene, $analysis, $sra);
my $totalRNAseqPaper = 0;
my %sraAnal;
my %GeneExprAll;
my %GeneExprOne;
my %DataLineCSV;
my %GeneExist;
my @tmp;
my @GeneList;
my @exp;
my @RNAseqPaper;
my %sraPaper;
my %paperRecord;
my %totalCondPaper;

#------Get Sample-Analysis table-----------
#---find Analysis Database = "SRA"--------------
my $AceFile = join "", "/home/wen/WormBaseToSPELL/ace_files/WB", $specode, "RNAseqAnalysis.ace";
open (ANAL, "$AceFile") || die "cannot open $!\n";
while ($line = <ANAL>) {
    if ($line =~ /^Analysis : /) {
	#get analysis name
	@tmp = split '"', $line;
	$analysis = $tmp[1];
    } elsif (($line =~ /^Database/) && ($line =~ /SRX/)) {
	@tmp = split '"', $line;
	$sra = $tmp[5];
	$sraAnal{$sra} = $analysis;
	#print "$sra -- $analysis\n"; -- for script testing
    } elsif ($line =~ /^Reference/) {
	@tmp = split '"', $line;
	$paper = $tmp[1];
	$sraPaper{$sra} = $paper;
	#print "$sra -- $paper\n"; -- for script testing 
	if ($paperRecord{$paper}) {
	    #this paper is already in record, skip
	    $totalCondPaper{$paper}++;
	} else {
	    $RNAseqPaper[$totalRNAseqPaper] = $paper;
	    $totalRNAseqPaper++;
	    $paperRecord{$paper} = 1;
	    $totalCondPaper{$paper} = 1;
	}
    }	
}
close (ANAL);
print "$totalRNAseqPaper RNAseq papers found in WS.\n";


#get the name of all input expr level files
my $i = 0;
my @inputfile;

open (IN1, "exprFileList.txt") || die "cannot open $!\n";
#open (IN1, "tempFileList.txt") || die "cannot open $!\n";
while ($line = <IN1>) {
     chomp($line);
     $inputfile[$i] = $line;
     $i++;     
 }
$totalCond = @inputfile;
close (IN1);
#------------done getting all the input file names. -----------


foreach $paper (@RNAseqPaper) { 
    $geneid = 0;
    %GeneExprAll = ();
    %GeneExprOne = ();
    %DataLineCSV = ();
    %GeneExist = ();
    @GeneList = ();
    print "$totalCondPaper{$paper} sample found in $paper in WormBase.\n";
    open (OUT, ">$paper.$specode.rs.paper")  || die "cannot open $!\n";
    open (CSV, ">$paper.$specode.rs.csv")  || die "cannot open $!\n";
    open (COND, ">$paper.$specode.rs.cond")  || die "cannot open $!\n";

    #print OUT "name\tname\tGWEIGHT\t", join("\t", @inputfile), "\n";
    print OUT "name\tname\tGWEIGHT";
    print CSV "name";

    #update mr_data table
    my $file;
    $i = 0;
    foreach $file (@inputfile) {
	#take condition information
	($sra, $stuff) = split ('\.', $file);
	next unless ($sraPaper{$sra});
	next unless ($sraPaper{$sra} eq $paper);

	open (IN2, "$file") || die "cannot open $!\n";	
	%GeneExist = ();    
	if ($sraAnal{$sra}) {
	    #print "parsing $file sample $sraAnal{$sra} in $paper ...";
	} else {
	    print "Cannot find analysis information for $sra!\n";
	}

	next unless ($sraAnal{$sra});

	$exp[$i] = $sraAnal{$sra};      
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
		    print "duplicate gene entry: $gene\n";
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
    
	#print "done.\n";

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

