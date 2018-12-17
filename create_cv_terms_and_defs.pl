#!/usr/bin/perl
use strict;
#use Ace;

#print "Look for Topics ...\n";
#my $db = Ace->connect(-path => '/home/citace/WS/acedb/',  -program => '/usr/local/bin/tace') || die print "Connection failure: ", Ace->error;

#my $query="QUERY FIND WBProcess Public_name =*";

#my @topic = $db->find($query);
#my %topicName;

#open (CV, ">add_CV_link.rhtml") || die "can't open $!";
#foreach my $t (@topic) {
#    my $name = $t->Public_name;
#    my $def = $t->Summary;
#    #$topicName{$t} = $name;
#    print CV " \<tr height=13\>\n";
#    print CV "  \<td height=13\>\<a href\=\"http:\/\/www.wormbase.org\/resources\/wbprocess\/$t\"\>Topic: $name<\/a\><\/td>\n";
#    print CV "  \t\<td\>$def\n";
#    print CV "  \t\<\/td\>\n";
#    print CV " \<\/tr\>\n\n";
#}
#print "done.\n";
#$db->close();
#close(CV);


my %defTopic;
my ($line, $go, $def, $topic);
my @tmp;


open (CV, ">add_CV_link.rhtml") || die "can't open add_CV_link.rhtml!";

open (GO, "/home/citace/WS/ONTOLOGY/gene_ontology.WS268.obo") || die "can't opengene_ontology.WS268.obo!";
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
while ($line = <IN>) {

    chomp($line);
 
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
close (GO);
close (IN);






