#!/usr/bin/perl -w
#This merge expression values in each file into one value per gene

use strict;

my @infile = ("/home/wen/SPELL/SPELL_usage_log/spell/2011-06_2012-03/development.log",      
	      "/home/wen/SPELL/SPELL_usage_log/spell/2012-03_2013-03/development.log", 
	      "/home/wen/SPELL/SPELL_usage_log/spell/2012-03_2013-08/development.log", 
	      "/home/wen/SPELL/SPELL_usage_log/spell/2013-08_2013-11/development.log",
	      "/home/wen/SPELL/SPELL_usage_log/spell/2013-11_2014-07/development.log");

my $visit = 0;

open (OUT1, ">SPELLusageIP.csv") || die "cannot open $!\n";
open (OUT2, ">SPELLuniqueIP.csv") || die "cannot open $!\n";

my $line;
my $i = 0;
my $f;
my %uniqueIP;
my @uIP;

foreach $f (@infile) {
    open (IN1, "$f") || die "cannot open $!\n";
    while ($line = <IN1>) {
	next unless ($line =~ /^Processing/);
	chomp($line);
	my @tmp = split /\s+/, $line;
	print OUT1 "$tmp[3]\t$tmp[5]\n";
     
	if ($uniqueIP{$tmp[3]}){
	    $uniqueIP{$tmp[3]}++;
	} else {
	    $uniqueIP{$tmp[3]} = 1;
	    $uIP[$i] = $tmp[3];
	    $i++;
	}
    }
}

close (IN1);
close (OUT1);

my $totalIP = $i;
$i = 0;
while ($i < $totalIP) {
    print OUT2 "$uIP[$i]\t$uniqueIP{$uIP[$i]}\n";
    next unless ($uIP[$i] ne "132.215.224.6");
    next unless ($uIP[$i] ne "132.215.52.65");
    $visit = $uniqueIP{$uIP[$i]} + $visit;
    $i++;
}
close (OUT2);

print "$totalIP unique IP found in this file. They visited SPELL page $visit times (excluding Raymond's robots).\n";
