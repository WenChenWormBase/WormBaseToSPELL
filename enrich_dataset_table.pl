#!/usr/bin/perl 

use strict;

my ($id, $pubmedID, $filename, $geoID, $platformID, $channelCount, $name, $description, $num_conds, $num_genes, $author, $all_authors, $title, $journal, $pub_year, $cond_descs, $tags);

my $line;
my @tmp;
my @exp;
my @hypEXP;
my @stuff;
#my @fileList = ("/home/wen/WormBaseToSPELL/Microarray/dataset_table_mr.txt", "/home/wen/WormBaseToSPELL/RNAseq/dataset_table_RNAseq.txt", "/home/wen/WormBaseToSPELL/TilingArray/dataset_table_TAR.txt");

my ($i, $TotalColumns, $paper, $gds, $gpl, $hypGDS, $hypGPL, $expName, $hypEXPforDesc, $file);
my $c = 0;

#----------- give IDs to datasets --------------------------------
open (IN1, "noid_dataset_list.txt") || die "can't open $!";
open (LIST, ">dataset_list.txt") || die "can't open $!";
$id = 0;
while ($line = <IN1>) {
    $id++;
    chomp($line);
    print LIST "$id\t$line\n";
}
print "$id datasets found in the dataset list.\n";
close (IN1);
close (LIST);


open (IN2, "noid_dataset_table.txt") || die "can't open $!";
open (TABLE, ">dataset_table.txt") || die "can't open $!";
$id = 0;
while ($line = <IN2>) {
    $id++;
    chomp($line); 
    print TABLE "$id\t$line\n";
}
print "$id datasets found in the dataset table.\n";
close (IN2);
close (TABLE);


#----------- enrich dataset table  -----------
open (IN3, "dataset_table.txt") || die "can't open $!";
open (DATASET, ">dataset_table_enriched.txt") || die "can't open $!";
my ($pType, $csvFileName);
while ($line = <IN3>) {
    chomp ($line);
    ($id, $pubmedID, $filename, $geoID, $platformID, $channelCount, $name, $description, $num_conds, $num_genes, $author, $all_authors, $title, $journal, $pub_year, $cond_descs, $tags) = split /\t/, $line;
    @tmp = split /\./, $filename;
    $paper = $tmp[0];

    #add different colors to RNAseq and Tiling Array
    if ($filename =~ /.mr.paper/) { 
         #microarray, do nothing
    } elsif ($filename =~ /.rs.paper/) { 
	#RNAseq
	$title = "\<font color \= \"red\">$title\<\/font\>";
    } elsif ($filename =~ /.tr.paper/) { 
	#Tiling Array
	$title = "\<font color \= \"yellow\">$title\<\/font\>";	
    }

    #add information to short description 
    if (($geoID ne "N.A.")&&($platformID ne "N.A.")) {
	$name = "$title \<br\> GEO Record:";
	@tmp = ();
	@tmp = split /,/, $geoID;
	foreach (@tmp) {
	    $gds = $_;
	    $hypGDS = "\<a href\=\"http\:\/\/www.ncbi.nlm.nih.gov\/geo\/query\/acc.cgi\?acc\=$gds\" target=\"_blank\"\>$gds\<\/a\>";	
	    $name = "$name $hypGDS";	    
	}
	
	$TotalColumns = @tmp;
	#print "$id $geoID $TotalColumns\n";
	$name = "$name Platform:";
	@tmp = ();
	@tmp = split ',', $platformID;
	foreach (@tmp) {
	    $gpl = $_;
	    $hypGPL = "\<a href\=\"http\:\/\/www.ncbi.nlm.nih.gov\/geo\/query\/acc.cgi\?acc\=$gpl\" target=\"_blank\"\>$gpl\<\/a\>";	
	    $name = "$name $hypGPL";	    
	}

    } else {
	$name = "$title \<br\> GEO Record: N.A. Platform: N.A."
    }   

    ($pType, $stuff[0]) = split 'paper', $filename;
    $csvFileName = join "", $pType, "csv";
    #print "File name for download: $csvFileName\n";

    $name = "$name \<br\>Download gene-centric, log2 transformed data: \<a href\=\"ftp:\/\/caltech.wormbase.org\/pub\/wormbase\/spell_download\/datasets\/$csvFileName\" target=\"_blank\"\>$csvFileName\<\/a\>";

    #done working on short description. 

    #add information to experiment names
    @exp = ();
    @hypEXP = ();
    @exp = split /~/, $cond_descs;
    $i = 0;
    foreach (@exp) {
	#$expName = $_;
	@tmp = ();
	@tmp = split ':', $_;
	$expName = join "%3A", @tmp;
	if ($filename =~ /.mr.paper/) {
	    #This is Microarray
#	    $hypEXP[$i] = "\<a href\=\"http\:\/\/www.wormbase.org\/db\/microarray\/results\?name\=$expName\;class\=Microarray_experiment\" target=\"_blank\"\>$_\<\/a\>";
	    $hypEXP[$i] = "\<a href\=\"http\:\/\/www.wormbase.org\/tools\/tree\/run\?name=$expName;class\=Microarray_experiment\" target=\"_blank\"\>$_\<\/a\>";
	} elsif (($filename =~ /.rs.paper/)||($filename =~ /.tr.paper/)){
	    #This is RNAseq or tiling array
#	    $hypEXP[$i] = "\<a href\=\"http\:\/\/www.wormbase.org\/db\/misc\/analysis\?name\=$expName\;class\=Analysis\" target=\"_blank\"\>$_\<\/a\>";
	    $hypEXP[$i] = "\<a href\=\"http\:\/\/www.wormbase.org\/tools\/tree\/run\?name\=$expName\;class=Analysis\" target=\"_blank\"\>$_\<\/a\>";
	}

	$i++;
    }
    $cond_descs = join "~", @hypEXP;
    #done
    
    #add information to full description
    $hypEXPforDesc = join "\<br\>", @hypEXP;
    $description = "$description\<br\>Experimental Details: \<br\>$hypEXPforDesc.";
    #done.

    print DATASET "$id\t$pubmedID\t$filename\t$geoID\t$platformID\t$channelCount\t$name\t$description\t$num_conds\t$num_genes\t$author\t$all_authors\t$title\t$journal\t$pub_year\t$cond_descs\t$tags\n";
    
}
close (IN3);
close (DATASET);
