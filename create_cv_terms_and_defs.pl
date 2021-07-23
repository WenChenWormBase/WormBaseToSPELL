#!/usr/bin/perl
use strict;

my %defTopic;
my ($line, $go, $def, $topic);
my @tmp;
my @topicList;
my @sortedTopicList;

open (GO, "/home/wen/SPELL/TablesForSPELL/gene_ontology.obo") || die "can't open gene_ontology.obo!";
while ($line = <GO>) {

    chomp($line);
    if ($line =~ /^id: GO/) {
	@tmp = split /\s+/, $line;
	$go = $tmp[1];
    } elsif ($line =~ /^def: /) {
	@tmp = split '"', $line;
	$def = $tmp[1];
	$defTopic{$go} = $def;
    } 
}
close (GO);

open (IN, "/home/wen/WormBaseToSPELL/currentSPELL/topicList.csv") || die "can't open topicList.csv!";
$line = <IN>;
my $i = 0;
while ($line = <IN>) {
    chomp($line);
    $topicList[$i] = $line;
    $i++;
}
@sortedTopicList = sort { lc($a) cmp lc($b) } @topicList;
close (IN);

open (CV, ">add_CV_link.rhtml") || die "can't open add_CV_link.rhtml!";
foreach $line (@sortedTopicList) {
    if ($line =~ /GO:/) {
	@tmp = split / \| /, $line;
	$go = $tmp[1];
	$topic = $tmp[0]; 

	if ($defTopic{$go}) {
	    $def = $defTopic{$go};
	} else {
	    $def = $topic;
	}
    } else {
        @tmp = split /\|/, $line;
	$topic = $tmp[0]; 
	$def = $topic;
    } 

    print CV " \<tr height=13\>\n";
    print CV "  \<td height=13\>Topic: $topic<\/a\><\/td>\n";
    print CV "  \t\<td\>$def\n";
    print CV "  \t\<\/td\>\n";
    print CV " \<\/tr\>\n\n";
}
close (CV);
print "$i SPELL topics are used.\n"
