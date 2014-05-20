#!/usr/bin/perl 

use strict;
use Ace;
use Getopt::Long;
use Storable qw(store retrieve);

my %speName = ("cbg" => "Caenorhabditis briggsae",
	       "cbn" => "Caenorhabditis brenneri",
	       "cja" => "Caenorhabditis japonica",
	       "cre" => "Caenorhabditis remanei",
	       "ce" => "Caenorhabditis elegans",
	       "ppa" => "Pristionchus pacificus");

#if ($speName{$specode}) {
#    print "***** Prepare PCL files for microarray data for $speName{$specode} *****\n";    
#} else {
#    die "Species code $specode is not recognized.\n";
#}

my @tmp;
my @stuff;

my ($paper, $database, $exp, $gene, $mr_result, $line, $TotalColumns, $value, $MrKey, $TotalMrData, $dataline, $noempty, $gds, $gpl, $e, $specode);

my @paperList;

my ($FirstName, $Author_count, $Abs, $ChannelCount);

my @Cond_description;
my @Cond_count;
my @Chan_count;
my @NumGene;

my %PaperGDS;
my %PaperGPL;

my $tace='/usr/local/bin/tace';

#---------- Start Parsing Paper Class ----------------------
print "connecting to WS_current ...\n";
print "Build Microarray Paper - Experiment table...\n";
my $acedbpath='/home/citace/WS/acedb/';
my $db = Ace->connect(-path => $acedbpath,  -program => $tace) || die print "Connection failure: ", Ace->error;

my $query="query find Microarray_experiment; follow Reference";
my @paperList=$db->find($query);
my $TotalPaper = @paperList;
my %mrPaperACeDB;

my @expList; #list of experiments in each dataset
my %Chan_count_exp; #for each experiment
my %PMID; #for each paper
my %Title; #for each paper
my %Journal; #for each paper
my %Year; #for each paper
my @Authors;
my %First_author; #for each paper
#my %LastName;
my %AllAuthors; #for each paper
my %Abstract; #for each paper

my @topic;
my $topicName;
my %topicPaper;
my %tissuePaper;

foreach my $paper (@paperList) {
    $mrPaperACeDB{$paper} = 1; #this paper exist in WS as curated microarray paper.

    $tissuePaper{$paper} = ""; # preset all paper as not tissue specific, will update later.

#------ identify channel info ----------------- 
    @expList = $paper->Microarray_experiment;
    foreach $exp (@expList) {
	if ($exp->Microarray_sample) {
	    $ChannelCount = 1;
	} elsif ($exp->Sample_A) {
	    $ChannelCount = 2;
	} else {
	    print "ERROR! Cannot find channel info from $exp\n";
	}
	$Chan_count_exp{$exp} = $ChannelCount;
    }
#-----------------------------------------------

    if ($paper->Database) {
	$database = $paper->get('Database', 2);
	if ($database eq "PMID") {
	    $PMID{$paper} = $paper->get('Database', 3);
	}
    } else {
	$PMID{$paper} = 0;
    }

    if ($paper->Title) {
	$Title{$paper} = $paper->Title;
    } else {
        $Title{$paper} = "N.A.";
    }
    if ($paper->Journal) {
        $Journal{$paper} = $paper->Journal;
    } else {
        $Journal{$paper} = "N.A.";
    }

    if ($paper->Publication_date) {    	
	@tmp = split '-', $paper->Publication_date; 
	$Year{$paper} = $tmp[0];
    } else {
	$Year{$paper} = 0;
    }

    if ($paper->Author) {
	@Authors = $paper->Author;
	$First_author{$paper} = $Authors[0];
	#($LastName[$paperid], $FirstName) = split (/\s/, $First_author[$paperid]);
	$Author_count = 0;
	foreach (@Authors) {	
	    if ($Author_count == 0) { 
		$AllAuthors{$paper} = $Authors[0];
	    } else {
		$AllAuthors{$paper} = "$AllAuthors{$paper}, $_";
	    } 
	    $Author_count++;
	}
    } else {
	$First_author{$paper} = "N.A.";
	$AllAuthors{$paper} = "N.A.";
    }

    if ($paper->Abstract) {
	$Abstract{$paper} = $paper->Abstract->right;
	@tmp = split '\n', $Abstract{$paper};
	$Abstract{$paper} = $tmp[1];
    } else {
	$Abstract{$paper} = "N.A.";
    }

    #get topic information
    if ($paper->WBProcess) {
	@topic = $paper->WBProcess;
	$topicPaper{$paper} = "";
	foreach (@topic) {
	    $topicName = $_->Public_name;
	    $topicName = "Topic: $topicName";
	    $topicPaper{$paper} = "$topicPaper{$paper}\|$topicName";
	}
    } else {
	$topicPaper{$paper} = "";
    }

}

#get tissue information
$query="query find Condition Tissue = *";
my @conditionList=$db->find($query);
foreach (@conditionList) {
    if ($_->Reference) {
	$paper = $_->Reference;
	$tissuePaper{$paper} = "|Tissue Specific";
    }
}

$db->close();
print "$TotalPaper microarray papers found in ACeDB.\n";
#----------Finish Parsing Paper Class ------------------------


#---------Start Parsing Gene Class ----------------------------
print "Build Gene - Microarray_results table...\n";

#Get mappings from external mapping files --------
my $mFileName;
my $mfid = 0; 
my $geneid=0;
my %GeneMrResult;

open (MFL, "/home/wen/WormBaseToSPELL/bin/mapping/mapping_file_list.txt") || die "can't open $!"; 
while ($mFileName = <MFL>) {
    chomp ($mFileName);
    open (MFNAME, $mFileName) || die "can't open $!";
    while ($line = <MFNAME>) {
	chomp ($line);
	($mr_result, $gene) = split /\t/, $line;
	$GeneMrResult{$mr_result} = $gene;
    }
    close (MFNAME);
    $mfid ++;
}
print "$mfid external mapping files parsed.\n";
close (MFL);

#Get mappings from ACeDB -----------------------------
open (WGM, "/home/wen/WormBaseToSPELL/ace_files/WBGeneMr.ace") || die "can't open $!"; 

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
close (WGM);
#-------------Finish Parsing Gene Class ------------------------


#-------------- Get dataset - paper list from microarray flat file names  ---
my @fileList;
my $dataset_id = 0;
my $pclName; #name of PCL files, must be unique
my @pclDataset;
my @paperDataset;
my @speDataset;
print "Get dataset - paper reference ... \n"; 
open (PROBEFILE, "mrFileList.txt") || die "can't open $!"; 
while ($line=<PROBEFILE>) {
    chomp($line);

    #get paper id from file name
    ($stuff[0], $stuff[1]) = split /WBPaper/, $line; #get everything after WBPaper
    $stuff[1] = join "", "WBPaper", $stuff[1];
    $paper = substr $stuff[1], 0, 15;
    next unless ($mrPaperACeDB{$paper}); # skip this dataset if the experimental info is not in the current WS release. 

    #get species info from file name 
    if ($line =~ /MrData/) {
	$specode = "ce";                
    } elsif ($line =~ /Mrcbg/) {
	$specode = "cbg";
    } elsif ($line =~ /Mrcbn/) {
	$specode = "cbn";
    } elsif ($line =~ /Mrcja/) {
	$specode = "cja";
    } elsif ($line =~ /Mrcre/) {
	$specode = "cre";
    } elsif ($line =~ /Mrppa/) {
	$specode = "ppa";
    } else {
	print "ERROR! Cannot identify species info from $line\n"; 
    }
    $speDataset[$dataset_id] = $specode;


    ($stuff[2], $stuff[3]) = split /Mr/, $stuff[1];
    $pclName = join '.', $stuff[2], $specode, "mr";
    
    #print "$dataset_id $pclName.paper or .csv $line\n"; #for script testing 

    $pclDataset[$dataset_id] = $pclName;
    $paperDataset[$dataset_id] = $paper;
    $fileList[$dataset_id] = $line;
    $dataset_id++;
}
close(PROBEFILE);
@stuff = ();
my $TotalDataset = $dataset_id;
print "$TotalDataset datasets found.\n";
#-----------  dataset - paper list prepared -------------------------------------


#------------ Printing Files for Probe Centric Microarray Data ------------

print "Read probe centric Microarray data ... \n";

open (TEST, ">test.txt") || die "can't open $!"; #This files stores information about all duplicate data or missing data

my %MrValue;
my @geneList;
my %geneExist; #this tells if the gene already appeared in the databset
my %MrValueCount; #this count time of a gene measured in the same experiment
my $averageValue;

my $expDesc="";
my %expRecord; #identify if an experiment was already encountered

$dataset_id = -1;
foreach my $f (@fileList) {
    #print "$f";
    open (IN, "$f") || die "can't open $f";
    $dataset_id++;
    $paper = $paperDataset[$dataset_id];
    $pclName = $pclDataset[$dataset_id];

    #print "$dataset_id\t$pclName\n"; #for script testing
    
    #empty all parameters for this paper. 
    $TotalMrData = 0;
    $geneid = 0;
    %MrValue = ();
    %geneExist = ();
    %MrValueCount = (); 
    @expList = ();
    @geneList = ();

    @expList = (); #experiment list for each dataset
    $e = -1; #experiment id
    #@allexp = (); #same as expList
    $expDesc= ""; #experiment description


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

	#------ get microarray_experiment info ------------
	$exp = $tmp[1]; # get name of experiment
	if ($expRecord{$exp}) {
	    #already in record, do nothing
	} else {
	    $e++;
	    $expList[$e] = $exp;
	    $expRecord{$exp} = 1;
	    if ($e == 0) {
		$ChannelCount = $Chan_count_exp{$exp};
		$expDesc = $exp; #first experiment in the dataset
	    } else {
		$expDesc="$expDesc~$exp";
	    }
	}

	#------ done ---------------------------------------


	$mr_result = $tmp[0]; #this is spot ID
	if ($GeneMrResult{$mr_result}) {
	    #do nothing
	} else {
	    print TEST "Cannot find matching gene for $mr_result\n";
	}
	next unless ($GeneMrResult{$mr_result}); #only work on mapped probes.
	
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
    $NumGene[$dataset_id] = $geneid;
    $Cond_count[$dataset_id] = @expList;
    $Cond_description[$dataset_id] = $expDesc;
    #$ExpPaper{$dataset_id} = $expDesc;
    $Chan_count[$dataset_id] = $ChannelCount;

    PrintDataSet (); #print out PCL file 
    PrintDataSetCSV (); #print out downloadable file
    print "$pclName.paper: $NumGene[$dataset_id] genes, $Cond_count[$dataset_id] experiments, $TotalMrData microarray data processed.\n";
    close (IN);
}
print "\n";
close(TEST);


#------------Get GEO accession numbers----------------------
#if ($specode eq "ce") {
open (GEOT, "/home/wen/LargeDataSets/Microarray/CurationLog/FindID/MAPaperGSETable.txt") || die "can't open $!";
while($line = <GEOT>){
    chomp ($line);
    @tmp=split("\t", $line);
    $TotalColumns = @tmp;
    #print "$TotalColumns\n";
    next unless ($TotalColumns == 5);
    $paper = $tmp[1];
    $gpl = $tmp[3];
    $gds = $tmp[4];	
    $PaperGPL{$paper} = $gpl;
    $PaperGDS{$paper} = $gds;
    #print "$tmp[1] $PaperGDS{$tmp[1]} $PaperGPL{$tmp[1]}\n";
}
close (GEOT);

#-------Start to print dataset list table. -----------------

print "print dataset_table.txt ...";
open (LIST, ">dataset_list_mr.txt") || die "can't open dataset_list.txt!";
open (DATASET, ">dataset_table_mr.txt") || die "can't open $!";
$dataset_id = 0;
while ($dataset_id < $TotalDataset) {
    $paper = $paperDataset[$dataset_id];
    $specode = $speDataset[$dataset_id];  
  
    if ($PaperGDS{$paper}) {
	$gds = $PaperGDS{$paper};
    } else {
	$gds = "N.A.";
    }

    if ($PaperGPL{$paper}) {
	$gpl = $PaperGPL{$paper};
    } else {
	$gpl = "N.A.";
    }

    $pclName = $pclDataset[$dataset_id];
    print LIST "$pclName.paper\n";
    print DATASET "$PMID{$paper}\t$pclName.paper\t$gds\t$gpl\t$Chan_count[$dataset_id]\t$Title{$paper}\t$Abstract{$paper}\t$Cond_count[$dataset_id]\t$NumGene[$dataset_id]\t$First_author{$paper}\t$AllAuthors{$paper}\t$Title{$paper}\t$Journal{$paper}\t$Year{$paper}\t$Cond_description[$dataset_id]\tMethod: microarray\|Species: $speName{$specode}$topicPaper{$paper}$tissuePaper{$paper}\n";
    $dataset_id++;
}
close (DATASET);
close (LIST);
print "done.\n";


#--------------Subroutine PrintDataSet----------------------------

sub PrintDataSet {
	open (OUT, ">$pclName.paper") || die "can't open $pclName.paper!";
	print "printing $pclName.paper ...";
	#print "$ExpPaper{$paper}\n";
	#@expList = split ("~", $ExpPaper{$paper});
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
	print " $geneid genes printed.\n";
}


sub PrintDataSetCSV {
	open (OUT, ">$pclName.csv") || die "can't open $pclName.csv!";
	print "printing $pclName.csv ... ";
	#@expList = split ("~", $ExpPaper{$paper});
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

