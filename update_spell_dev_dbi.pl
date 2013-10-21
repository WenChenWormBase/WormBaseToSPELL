#!/usr/bin/perl 
use DBI();

# MYSQL CONFIG VARIABLES
$host = "localhost";
#$database = "spell_test";
$database = "spell_dev";
$user = "";
$pw = "";

# PERL MYSQL CONNECT()
#$dbh = DBI->connect("DBI:mysql:$database:$host", $user, $pw,
#                         {'RaiseError' => 1});
$dbh = DBI->connect("DBI:mysql:$database:$host;mysql_local_infile=1", $user, $pw, {'RaiseError' => 1});

# DEFINE A MySQL QUERY
$myquery[0] = "delete from datasets;";
#$myquery[1] = "LOAD DATA LOCAL INFILE '/home/wen/SPELL/TablesForSPELL/dataset_table.txt' INTO TABLE datasets;";
$myquery[1] = "LOAD DATA LOCAL INFILE '/home/wen/SPELL/TablesForSPELL/dataset_table_enriched.txt' INTO TABLE datasets;";
$myquery[2] = "delete from genes;";
$myquery[3] = "LOAD DATA LOCAL INFILE '/home/wen/SPELL/TablesForSPELL/gene_list.txt' INTO TABLE genes;";
$myquery[4] = "delete from exprs;";
$myquery[5] = "LOAD DATA LOCAL INFILE '/home/wen/SPELL/TablesForSPELL/expressionTable.txt' INTO TABLE exprs;";
$myquery[6] = "delete from common_genes;";
$myquery[7] = "LOAD DATA LOCAL INFILE '/home/wen/SPELL/TablesForSPELL/systematic_to_common.txt' INTO TABLE common_genes;";
$myquery[8] = "delete from gene_aliases;";
$myquery[9] = "LOAD DATA LOCAL INFILE '/home/wen/SPELL/TablesForSPELL/alias_to_systematic.txt' INTO TABLE gene_aliases;";


$i = 0;
while ($i < 10){
    $q = $myquery[$i];
    #$dbh->do($q);
    #$act = $dbh->prepare($q);
    #$act->execute();
    #$warning = $act->{mysql_warning_count};
    $affectedrows = $dbh->do($q);
    print "$q\n";
    print "$affectedrows rows affected.\n";
    #print "$warning warnings found.\n";
    $i++;
}

