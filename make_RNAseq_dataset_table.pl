#!/usr/bin/perl
use strict;
use Ace;

#-------------------Type out the purpose of the script-------------
print "This script checks WormBase RNAseq data and make dataset file for SPELL\n";
print "Output file: dataset_list_RNAseq.txt, dataset_table_RNAseq.txt\n";


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
    print "***** Prepare dataset table for RNAseq data for $speName{$specode} *****\n";    
} else {
    die "Species code $specode is not recognized.\n";
}

open (DATASET, ">dataset_table_RNAseq.txt") || die "can't open $!";
open (LIST, ">dataset_list_RNAseq.txt") || die "can't open $!";

my @tmp;
my ($FirstName, $Total_datasets, $Author_count, $Abs, $ChannelCount, $line, $database, $numGene);
my @PaperID;
my @PMID;
my @Title;
my @Journal;
my @Year;
my @Authors;
my @First_author;
my @LastName;
my @AllAuthors;
my @Abstract;
my @exp;
my @Cond_description;
my @Cond_count;

#------------Get GEO accession numbers----------------------
my ($gds, $gpl, $TotalColumns);
my %PaperGDS;
my %PaperGPL;
open (GEOT, "/home/wen/LargeDataSets/Microarray/CurationLog/FindID/MAPaperGSETable_RNAseq.txt") || die "can't open $!";
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
@tmp = ();


#--------------Query for Microarray reference in WS ----------------
print "Look for RNAseq Papers ...";
my $db = Ace->connect(-path => '/home/citace/WS/acedb/',  -program => '/usr/local/bin/tace') || die print "Connection failure: ", Ace->error;

my $paper;
my @topic;
my $topicName;
my %topicPaper;
my %tissuePaper;

#get tissue information
my $query="query find Condition Tissue = *";
my @conditionList=$db->find($query);
foreach (@conditionList) {
    if ($_->Reference) {
	$paper = $_->Reference;
	$tissuePaper{$paper} = "|Tissue Specific";
    }
}


$query="QUERY FIND Analysis Database = SRA;  NOT Reference = *00041194; NOT Reference = *00041168; NOT Reference = *00035224; follow Sample; Species = \"$speName{$specode}\"; follow Reference";
my @Papers=$db->find($query);

print scalar @Papers, " RNAseq Papers found for $speName{$specode} in ACeDB.\n";
#--------------Done query for microarray papers in WS ------


my $id = -1;

#-------------------------------------------------------------------
my $empty = 0;
foreach $paper (@Papers) {
    
    #----------- first figure out if this is an empty dataset -----------
    $empty = 0; #suppose this dataset is not empty.

    open (COND, "$paper.$specode.rs.cond")  || die "cannot open $paper.$specode.rs.cond\n";
    while ($line = <COND>) {
	chomp ($line);
	if ($line eq "EMPTY DATASET!") {
	    $empty = 1;
	}
	next unless ($empty==0); #suppose this is not an empty dataset

	$id++;
	($numGene, $Cond_count[$id], $Cond_description[$id]) = split /\t/, $line;
    }
    close (COND);
    
    next unless ($empty==0); #suppose this is not an empty dataset

    if ($tissuePaper{$paper}) {
	#do nothing
    } else {
	$tissuePaper{$paper} = "";
    }

    $PaperID[$id] = $paper;

    if ($paper->Database) {
	$database = $paper->get('Database', 2);
	if ($database eq "PMID") {
	    $PMID[$id] = $paper->get('Database', 3);
	}
    } else {
	$PMID[$id] = 0;
    }

    if ($paper->Title) {
	$Title[$id] = $paper->Title;
    } else {
        $Title[$id] = "N.A.";
    }
    if ($paper->Journal) {
        $Journal[$id] = $paper->Journal;
    } else {
        $Journal[$id] = "N.A.";
    }

    if ($paper->Publication_date) {    	
	@tmp = split '-', $paper->Publication_date; 
	$Year[$id] = $tmp[0];
    } else {
	$Year[$id] = 0;
    }

    if ($paper->Author) {
	@Authors = $paper->Author;
	$First_author[$id] = $Authors[0];
	($LastName[$id], $FirstName) = split (/\s/, $First_author[$id]);
	$Author_count = 0;
	foreach (@Authors) {	
	    if ($Author_count == 0) { 
		$AllAuthors[$id] = $Authors[0];
	    } else {
		$AllAuthors[$id] = "$AllAuthors[$id], $_";
	    } 
	    $Author_count++;
	}
    } else {
	$First_author[$id] = "N.A.";
	$AllAuthors[$id] = "N.A.";
    }
    if ($paper->Abstract) {
	$Abstract[$id] = $paper->Abstract->right;
	@tmp = split '\n', $Abstract[$id];
	$Abstract[$id] = $tmp[1];
    } else {
	$Abstract[$id] = "N.A.";
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
    #---- done -----------

    $ChannelCount = 1;


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

    print DATASET "$PMID[$id]\t$PaperID[$id].$specode.rs.paper\t$gds\t$gpl\t$ChannelCount\t$Title[$id]\t$Abstract[$id]\t$Cond_count[$id]\t$numGene\t$First_author[$id]\t$AllAuthors[$id]\t$Title[$id]\t$Journal[$id]\t$Year[$id]\t$Cond_description[$id]\tMethod: RNAseq\|Species: $speName{$specode}$topicPaper{$paper}$tissuePaper{$paper}\n";
    #print LIST "$id\t$paper.rs.paper\n";
    print LIST "$paper.$specode.rs.paper\n";
}

#-----------------------------------------------------------

$Total_datasets = $id + 1;

close (IN);
close (DATASET);
close (LIST);
$db->close();
print "$Total_datasets papers parsed for $speName{$specode} RNAseq.\n\n";

