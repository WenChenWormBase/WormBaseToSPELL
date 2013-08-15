#!/usr/bin/perl

#-------------------Type out the purpose of the script-------------
print "This program check WS Gene_names and make alias file for SPELL\n";
print "Input file: /home/wen/WormBaseToSPELL/ace_files/WBGeneName.ace\n";
print "Output file: alias_to_systematic.txt, gene_list.txt, systematic_to_common.txt\n\n";


print "Parse Gene names ...";
open (IN, "/home/wen/WormBaseToSPELL/ace_files/WBGeneName.ace") || die "can't open $!";
open (ALIAS, ">alias_to_systematic.txt") || die "can't open $!";
open (GENES, ">gene_list.txt") || die "can't open $!";
open (COMMON, ">systematic_to_common.txt") || die "can't open $!";


$id = 0;
$id_a = 0;
$id_c = 0;

while ($Line=<IN>) {
    chomp ($Line);
    if ($Line =~ /^Gene : /) {
	($stuff1, $GeneID, $stuff2) = split ('"', $Line);	
	$id++;
	print GENES "$id\t$GeneID\n";
    } elsif ($Line =~ /^Public_name/) {
	($stuff1, $Public_name, $stuff2) = split ('"', $Line);
	$id_a++;
	print ALIAS "$id_a\t$Public_name\t$GeneID\n";
	$id_c++;
	print COMMON "$id_c\t$GeneID\t$Public_name\n";
    } elsif (($Line =~ /^CGC_name/) || ($Line =~ /^Sequence_name/) || ($Line =~ /^Molecular_name/) || ($Line =~ /^Other_name/)) {
	($stuff1, $Other_name, $stuff2) = split ('"', $Line);
	$id_a++;
	print ALIAS "$id_a\t$Other_name\t$GeneID\n";
    }
}
close (IN);
close (ALIAS);
close (GENES);
close (COMMON);
print "Done.\n";


