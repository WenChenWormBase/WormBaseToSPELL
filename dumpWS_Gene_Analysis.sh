#!/bin/csh
#-------------prepare ace files for PCL file generation---------------------
cd /home/wen/WormBaseToSPELL/
setenv ACEDB /home/citace/WS/acedb/
## from Wen
/usr/local/bin/tace -tsuser 'wen' <<END_TACE
QUERY FIND Condition Species = "Caenorhabditis elegans"; follow Analysis; Database = SRA;
show -a -f ace_files/WBceRNAseqAnalysis.ace
QUERY FIND Condition Species = "Caenorhabditis briggsae"; follow Analysis; Database = SRA;
show -a -f ace_files/WBcbgRNAseqAnalysis.ace
QUERY FIND Condition Species = "Caenorhabditis brenneri"; follow Analysis; Database = SRA;
show -a -f ace_files/WBcbnRNAseqAnalysis.ace
QUERY FIND Condition Species = "Caenorhabditis japonica"; follow Analysis; Database = SRA;
show -a -f ace_files/WBcjaRNAseqAnalysis.ace
QUERY FIND Condition Species = "Caenorhabditis remanei"; follow Analysis; Database = SRA;
show -a -f ace_files/WBcreRNAseqAnalysis.ace
QUERY FIND Condition Species = "Pristionchus pacificus"; follow Analysis; Database = SRA;
show -a -f ace_files/WBppaRNAseqAnalysis.ace
QUERY FIND Condition TAR*;
show -a -t Reference -f ace_files/WBCeTARSample.ace
QUERY FIND Gene
show -a -t Name -f ace_files/WBGeneName.ace
show -a -t Species -f ace_files/WBGeneSpe.ace
QUERY FIND Gene Microarray_results
show -a -t Microarray_results -f ace_files/WBGeneMr.ace
quit
END_TACE
