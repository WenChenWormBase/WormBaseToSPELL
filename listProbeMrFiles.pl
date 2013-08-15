#!/usr/bin/perl 

#This file list all the microarray probe centric files and create a shell script file to add column titles to them.

open (OUT, ">addTitle_MrProbeFiles.sh") || die "can't open $!";
open (PROBEFILE, "mrFileList.txt") || die "can't open $!"; 

my ($line, $newFileName, $datasetid);
my @stuff;

while ($line=<PROBEFILE>){
    chomp($line);
    ($stuff[0], $stuff[1]) = split 'WBPaper', $line;
    ($datasetid, $stuff[2]) = split 'txt', $stuff[1];
    $newFileName = join "", "WBPaper", $datasetid, "csv";
    print OUT "cat \/home\/wen\/LargeDataSets\/Microarray\/MrDataSchema.txt $line > $newFileName\n";
}

close (PROBEFILE);
close (OUT);
