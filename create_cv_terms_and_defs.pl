#!/usr/bin/perl
use strict;
use Ace;

print "Look for Topics ...\n";
my $db = Ace->connect(-path => '/home/citace/WS/acedb/',  -program => '/usr/local/bin/tace') || die print "Connection failure: ", Ace->error;

my $query="QUERY FIND WBProcess Public_name =*";

my @topic = $db->find($query);
#my %topicName;

open (CV, ">add_CV_link.rhtml") || die "can't open $!";
foreach my $t (@topic) {
    my $name = $t->Public_name;
    my $def = $t->Summary;
    #$topicName{$t} = $name;
    print CV " \<tr height=13\>\n";
    print CV "  \<td height=13\>\<a href\=\"http:\/\/www.wormbase.org\/resources\/wbprocess\/$t\"\>Topic: $name<\/a\><\/td>\n";
    print CV "  \t\<td\>$def\n";
    print CV "  \t\<\/td\>\n";
    print CV " \<\/tr\>\n\n";
}
print "done.\n";
$db->close();
close(CV);

