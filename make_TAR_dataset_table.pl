#!/usr/bin/perl
use strict;
use Ace;

#-------------------Type out the purpose of the script-------------
print "This script checks WormBase Tiling Array data and make dataset file for SPELL\n";
print "Output file: dataset_list_TAR.txt, dataset_table_TAR.txt\n\n";

open (DATASET, ">dataset_table_TAR.txt") || die "can't open $!";
open (LIST, ">dataset_list_TAR.txt") || die "can't open $!";

my $id = 0;
#my $mrdataset; 
#open (MRLIST, "/home/wen/WormBaseToSPELL/Microarray/dataset_list_mr.txt") || di#e "can't open $!";
#while ($mrdataset = <MRLIST>) {
#    $id++;
#}
#close (MRLIST);

#open (RSLIST, "/home/wen/WormBaseToSPELL/RNAseq/dataset_list_RNAseq.txt") || die "can't open $!";
#while ($mrdataset = <RSLIST>) {
#    $id++;
#}
#close (RSLIST);

#print "$id microarray and RNAseq datasets found.\n";

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

#--------------Query for Tiling array reference in WS ----------------
print "Look for Tiling Array Papers ...";
my $db = Ace->connect(-path => '/home/citace/WS/acedb/',  -program => '/usr/local/bin/tace') || die print "Connection failure: ", Ace->error;

my $query='QUERY FIND Condition TAR*; follow Reference';
my @Papers=$db->find($query);

print scalar @Papers, " Tiling Array Papers found.\n";
#--------------Done query for tiling array papers in WS ------

#-------------------------------------------------------------------
foreach my $paper (@Papers) {
    $id++;
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

    open (COND, "/home/wen/WormBaseToSPELL/TilingArray/$paper.ce.tr.cond")  || die "cannot open $!\n";
    while ($line = <COND>) {
	chomp ($line);
	($numGene, $Cond_count[$id], $Cond_description[$id]) = split /\t/, $line;
    }
    close (COND);

    $ChannelCount = 1;
#    print DATASET "$id\t$PMID[$id]\t$PaperID[$id].tr.paper\tN.A.\tN.A.\t$ChannelCount\tTilingArray: $Title[$id]\t$Abstract[$id]\t$Cond_count[$id]\t$numGene\t$First_author[$id]\t$AllAuthors[$id]\t$Title[$id]\t$Journal[$id]\t$Year[$id]\t$Cond_description[$id]\tdefault\n";
#    print LIST "$id\t$paper.tr.paper\n";
    print DATASET "$PMID[$id]\t$PaperID[$id].ce.tr.paper\tN.A.\tN.A.\t$ChannelCount\tTilingArray: $Title[$id]\t$Abstract[$id]\t$Cond_count[$id]\t$numGene\t$First_author[$id]\t$AllAuthors[$id]\t$Title[$id]\t$Journal[$id]\t$Year[$id]\t$Cond_description[$id]\tdefault\n";
    print LIST "$paper.ce.tr.paper\n";



}

#-----------------------------------------------------------

$Total_datasets = $id;

close (IN);
close (DATASET);
close (LIST);
print "$Total_datasets papers parsed including Tiling Array, RNAseq and Microarray.\n";
