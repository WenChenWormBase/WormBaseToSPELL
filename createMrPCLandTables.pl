#!/usr/bin/perl 

use strict;
use Ace;
use Getopt::Long;
use Storable qw(store retrieve);

if ($#ARGV !=0) {
    die "usage: $0 series_file ace\n";
}

my %speName = ("cbg" => "Caenorhabditis briggsae",
	       "cbn" => "Caenorhabditis brenneri",
	       "cja" => "Caenorhabditis japonica",
	       "cre" => "Caenorhabditis remanei",
	       "ce" => "Caenorhabditis elegans",
	       "ppa" => "Pristionchus pacificus");
my $specode = $ARGV[0];

if ($speName{$specode}) {
    print "***** Prepare PCL files for microarray data for $speName{$specode} *****\n";    
} else {
    die "Species code $specode is not recognized.\n";
}


my ($paper, $database, $exp, $TotalPaper, $gene, $mr_result, $line, $TotalColumns, $value, $MrKey, $TotalMrData, $dataline, $noempty, $gds, $gpl, $e, $spe);
my $geneid=0;
my $expid=0; #count of total experiments in all papers.
my $expDesc="";
my %PaperExp;
my %ExpPaper;
my %GeneMrResult;
my %PaperGeneNumber;
my %MrValue;
my @tmp;
my @mrResultList;
my @geneList;
my @allexp; #all microarray experiments including other species 
my @expList; #c elegans experiment list only
my @paperList;


my $paperid = 0 ;
my ($FirstName, $Total_datasets, $Author_count, $Abs, $ChannelCount);
my @PaperID;
my %IDforPaper;
my @PMID;
my @Title;
my @Journal;
my @Year;
my @Authors;
my @First_author;
my @LastName;
my @AllAuthors;
my @Abstract;
my @Cond_description;
my @Cond_count;
my @Chan_count;
my %NumGene;
my %PaperGDS;
my %PaperGPL;

my $tace='/usr/local/bin/tace';

#------------Get GEO accession numbers----------------------
if ($specode eq "ce") {
open (GEOT, "/home/wen/LargeDataSets/Microarray/CurationLog/FindID/MAPaperGSETable.txt") || die "can't open $!";
while($line = <GEOT>){
    chomp ($line);
    @tmp=split("\t", $line);
    $TotalColumns = @tmp;
    #print "$TotalColumns\n";
    next unless ($TotalColumns == 5);
    $PaperGDS{$tmp[1]} = $tmp[4];
    $PaperGPL{$tmp[1]} = $tmp[3];
    #print "$tmp[1] $PaperGDS{$tmp[1]} $PaperGPL{$tmp[1]}\n";
}
close (GEOT);
}
#---------- Start Parsing Paper Class ----------------------
print "connecting to WS_current ...\n";
print "Build Microarray Paper - Experiment table...\n";
my $acedbpath='/home/citace/WS/acedb/';
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;

#my $query="query find Paper Microarray_experiment & !*30980* & !*32290";

my $query="query find Microarray_experiment Species = \"$speName{$specode}\"; follow Reference; !*30980* & !*32290";
my @paperList=$db->find($query);

foreach my $paper (@paperList) {
    $paperid++;
    $PaperID[$paperid] = $paper;
    $IDforPaper{$paper} = $paperid;

    @expList = ();
    $e = 0; #experiment id
    @allexp = $paper->Microarray_experiment;
    $expDesc="";
    foreach $exp (@allexp) {
	$spe = $exp->Species;
	next unless ($spe eq $speName{$specode});
	$expList[$e] = $exp;
	$e++;
	$expid++;
	$PaperExp{$exp} = $paper;
	if ($exp eq $expList[0]) {
	    $expDesc = $exp;
	} else {
	    $expDesc = "$expDesc~$exp";
	}
    }
    $Cond_count[$paperid] = @expList;
    $Cond_description[$paperid] = $expDesc;

    $ExpPaper{$paper} = $expDesc;

    if ($paper->Database) {
	$database = $paper->get('Database', 2);
	if ($database eq "PMID") {
	    $PMID[$paperid] = $paper->get('Database', 3);
	}
    } else {
	$PMID[$paperid] = 0;
    }

    if ($paper->Title) {
	$Title[$paperid] = $paper->Title;
    } else {
        $Title[$paperid] = "N.A.";
    }
    if ($paper->Journal) {
        $Journal[$paperid] = $paper->Journal;
    } else {
        $Journal[$paperid] = "N.A.";
    }

    if ($paper->Publication_date) {    	
	@tmp = split '-', $paper->Publication_date; 
	$Year[$paperid] = $tmp[0];
    } else {
	$Year[$paperid] = 0;
    }

    if ($paper->Author) {
	@Authors = $paper->Author;
	$First_author[$paperid] = $Authors[0];
	($LastName[$paperid], $FirstName) = split (/\s/, $First_author[$paperid]);
	$Author_count = 0;
	foreach (@Authors) {	
	    if ($Author_count == 0) { 
		$AllAuthors[$paperid] = $Authors[0];
	    } else {
		$AllAuthors[$paperid] = "$AllAuthors[$paperid], $_";
	    } 
	    $Author_count++;
	}
    } else {
	$First_author[$paperid] = "N.A.";
	$AllAuthors[$paperid] = "N.A.";
    }

    if ($paper->Abstract) {
	$Abstract[$paperid] = $paper->Abstract->right;
	@tmp = split '\n', $Abstract[$paperid];
	$Abstract[$paperid] = $tmp[1];
    } else {
	$Abstract[$paperid] = "N.A.";
    }

    if ($paper->Microarray_experiment->Microarray_sample) {
	$ChannelCount = 1;
    } else {
	$ChannelCount = 2;
    }
    $Chan_count[$paperid] = $ChannelCount;
}
$db->close();
$TotalPaper = @paperList;
print "$expid Microarray Experiments found in $TotalPaper papers.\n";
#----------Finish Parsing Paper Class ------------------------


#---------Start Parsing Gene Class ----------------------------

print "Build Gene - Microarray_results table...\n";

#$query="QUERY Find Gene Microarray_results";
#my $iterator=$db->fetch_many(-query=>$query);

#while (my $gene=$iterator->next) {
#    $geneid++; 
#    print "$geneid genes processed.\n" if $geneid % 10000 == 0;    
#    @mrResultList = $gene->Microarray_results;
#    foreach $mr_result (@mrResultList) {
#	$GeneMrResult{$mr_result} = $gene;
#    }
#}
#$db->close();

open (WGM, "/home/wen/WormBaseToSPELL/ace_files/WBGeneMr.ace") || die "can't open $!"; 

my $gene;
my @stuff;
while ($line = <WGM>) {
    if ($line =~ /^Gene/) {
	($stuff[0], $gene) = split'"', $line;
	if ($gene =~ /^WBGene/) {
	     $geneid++; 
	} else{
	    print "Wrong Gene entry: $line\n";
	} 
    } elsif ($line =~ /^Microarray_results/) {
	($stuff[0], $mr_result) = split'"', $line;
	$GeneMrResult{$mr_result} = $gene;
    }
}
@stuff = ();
print "$geneid genes found with Microarray_results\n";
#-------------Finish Parsing Gene Class ------------------------


#--------Printing Files for Probe Centric Microarray Data --------------------
my @fileList;
my $fileListID = 0;
open (LIST, ">dataset_list_mr.txt") || die "can't open dataset_list.txt!";
open (PROBEFILE, "mrFileList.txt") || die "can't open $!"; 
while ($line=<PROBEFILE>) {
    chomp($line);
    $fileList[$fileListID] = $line;
    $fileListID++;
}
close(PROBEFILE);
print "$fileListID datasets found.\n";
my %geneExist; #this tells if the gene already appeared in the databset
my %MrValueCount; #this count time of a gene measured in the same experiment
my $averageValue;

print "Read probe centric Microarray data ... \n";

open (TEST, ">test.txt") || die "can't open $!";

foreach my $f (@fileList) {
    #print "$f";
    open (IN, "$f") || die "can't open $f";
    ($stuff[0], $stuff[1]) = split 'WBPaper', $f;
    if ($specode eq "ce") {
	($stuff[2], $stuff[3], $stuff[4]) = split /MrData/, $stuff[1];
    } else {
	($stuff[2], $stuff[3], $stuff[4]) = split /$specode/, $stuff[1];
    }
    $paper = "WBPaper$stuff[2]";
    $paperid = $IDforPaper{$paper};
    #print LIST "$paperid\t$paper.$specode.mr.paper\n";
    
    #empty all parameters for this paper. 
    $TotalMrData = 0;
    $geneid = 0;
    %MrValue = ();
    %geneExist = ();
    %MrValueCount = (); 
    @expList = ();
    @geneList = ();

    #start parsing the file.
    $geneid = 0;
    while ($line = <IN>){
	chomp ($line);
	@tmp=split("\t", $line);
	$TotalColumns = @tmp;
	if ($TotalColumns != 10) {
	    print TEST "column number wrong, only $TotalColumns columns found.\n";
	}
	next unless ($TotalColumns == 10); #WBPaperXXXXXXXXMrData.txt files have 10 columns

	$mr_result = $tmp[0]; #this is spot ID
	if ($GeneMrResult{$mr_result}) {
	    #do nothing
	} else {
	    print TEST "Cannot find matching gene for $mr_result\n";
	}
	next unless ($GeneMrResult{$mr_result}); #only work on mapped probes.
	
	$exp = $tmp[1]; # get name of experiment
	
	#get expression value
	if ($tmp[3] ne "\\N") { #a_vs_b_log_ratio
	    $value = $tmp[3];
	} elsif (($tmp[5] ne "\\N") && ($tmp[5] > 0)) {#frequency	
	    $value = $tmp[5];
	    $value = log($tmp[5])/log(2);  #log(2) transform frequency
	} else {
	    $value = "\\N";
	}

	#accumulate gene list for this paper.
	$gene = $GeneMrResult{$mr_result};    
	$MrKey = "$gene$exp";

	if ($geneExist{$gene}) {
	    #do nothing
	} else {
	    #this is a new gene, add to the list
	    $geneList[$geneid] = $gene;
	    $geneExist{$gene} = 1;
	    $geneid++;
	} 

	#average value for each gene/experiment pair
	if ($value ne "\\N") {		   
	   if ($MrValue{$MrKey}) {
	      #this gene was already reported in this experiment.
	      $averageValue = log((2**$MrValue{$MrKey})*$MrValueCount{$MrKey} + 2**$value)/log(2); #average the expression value
	      $MrValue{$MrKey} = $averageValue; #update the record
	      $MrValueCount{$MrKey}++;
	      print TEST "$gene in $exp got $MrValueCount{$MrKey} results\n";
	   } else {
	      #this gene is new in this experiment
	      $MrValue{$MrKey} = $value;
	      #print TEST "$mr_result\t$gene\t$exp\t$value\n";
	      $MrValueCount{$MrKey} = 1;
	   }
	}
	$TotalMrData++;     
    }
    $NumGene{$paper} = $geneid;
    PrintDataSet (); #print out PCL file 
    PrintDataSetCSV (); #print out downloadable file
    print "$NumGene{$paper} genes studied in $paper.\n";
    close (IN);
}
print "$TotalMrData microarray data processed. \n";
close(TEST);

#-------Start to print dataset list table. -----------------
print "print dataset_table.txt ...";
open (DATASET, ">dataset_table_mr.txt") || die "can't open $!";
$paperid = 1;
while ($paperid <= $TotalPaper) {
    if ($PaperGDS{$PaperID[$paperid]}) {
	#@tmp = split ',', $PaperGDS{$PaperID[$paperid]};
	#$gds = $tmp[0];
	$gds = $PaperGDS{$PaperID[$paperid]};
    } else {
	$gds = "N.A.";
    }

    if ($PaperGPL{$PaperID[$paperid]}) {
	#@tmp = split ',', $PaperGPL{$PaperID[$paperid]};
	#$gpl = $tmp[0];
	$gpl = $PaperGPL{$PaperID[$paperid]};
    } else {
	$gpl = "N.A.";
    }

    print "No numGene for $PaperID[$paperid]\n" unless ($NumGene{$PaperID[$paperid]});

    print LIST "$PaperID[$paperid].$specode.mr.paper\n";
    #print DATASET "$PMID[$paperid]\t$PaperID[$paperid].$specode.mr.paper\t$gds\t$gpl\t$Chan_count[$paperid]\t$Title[$paperid]\t$Abstract[$paperid]\t$Cond_count[$paperid]\t$NumGene{$PaperID[$paperid]}\t$First_author[$paperid]\t$AllAuthors[$paperid]\t$Title[$paperid]\t$Journal[$paperid]\t$Year[$paperid]\t$Cond_description[$paperid]\tdefault\n";
    print DATASET "$PMID[$paperid]\t$PaperID[$paperid].$specode.mr.paper\t$gds\t$gpl\t$Chan_count[$paperid]\t$Title[$paperid]\t$Abstract[$paperid]\t$Cond_count[$paperid]\t$NumGene{$PaperID[$paperid]}\t$First_author[$paperid]\t$AllAuthors[$paperid]\t$Title[$paperid]\t$Journal[$paperid]\t$Year[$paperid]\t$Cond_description[$paperid]\tMethod: microarray\|Species: $speName{$specode}\n";
    $paperid++;
}
close (DATASET);
close (LIST);
print "done.\n";


#--------------Subroutine PrintDataSet----------------------------

sub PrintDataSet {
	open (OUT, ">$paper.$specode.mr.paper") || die "can't open $paper.$specode.mr.paper!";
	print "printing $paper.$specode.mr.paper ...";
	#print "$ExpPaper{$paper}\n";
	@expList = split ("~", $ExpPaper{$paper});
	print OUT "name\tname\tGWEIGHT\t", join("\t", @expList), "\n";
	print OUT "EWEIGHT\t\t";
	for (my $i=0; $i<=$#expList; $i++) {
	    print OUT "\t1";
	}
	print OUT "\n";
        #$geneid = @geneList;
	print "$geneid genes studied ...";
	$geneid = 0;
	foreach $gene (@geneList) {
	    $dataline = "$gene\t$gene\t1";
	    $noempty = 0;
	    foreach $exp (@expList) {
		$MrKey = "$gene$exp";
		if ($MrValue{$MrKey} ne "") {
		    $dataline = "$dataline\t$MrValue{$MrKey}";
		    $noempty = 1;
		} else {	    
		    $dataline = "$dataline\t\\N";
		    $noempty = 0;
		    print TEST "empty data line caused by $exp for $gene\n";
		    last;
		}
	    }
	    if ($noempty == 1) {
		print OUT "$dataline\n";
		$geneid ++;
	    }
	}
	close (OUT);
	print " $geneid genes printed done.\n";
}


sub PrintDataSetCSV {
	open (OUT, ">$paper.$specode.mr.csv") || die "can't open $paper.$specode.mr.csv!";
	print "printing $paper.$specode.mr.csv ... \n";
	@expList = split ("~", $ExpPaper{$paper});
	#print OUT "name\tname\tGWEIGHT\t", join("\t", @expList), "\n";
	#print OUT "EWEIGHT\t\t";
	print OUT "name\t", join("\t", @expList), "\n";
	#for (my $i=0; $i<=$#expList; $i++) {
	    #print OUT "\t1";
	#}
	#print OUT "\n";
	foreach $gene (@geneList) {
	    #$dataline = "$gene\t$gene\t1";
	    $dataline = "$gene";
	    $noempty = 0;
	    foreach $exp (@expList) {
		$MrKey = "$gene$exp";
		if ($MrValue{$MrKey} ne "") {
		    $dataline = "$dataline\t$MrValue{$MrKey}";
		    #$noempty = 1;
		} else {	    
		    $dataline = "$dataline\t\\N";
		    #$noempty = 0;
		    #print "empty data line caused by $exp for $gene\n";
		    #last;
		}
	    }
	    #if ($noempty == 1) {
		print OUT "$dataline\n";
	    #}
	}
	close (OUT);
	print "done.\n";
}

