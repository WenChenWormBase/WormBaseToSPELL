#!/bin/csh

#  ----- Make sure that old SPELL/TablesForSPELL/ and ../WormBaseToSPELL/currentSPELL/download/  were backed up.  ------------

#Make sure mr_data_dump_for_SPELL.txt.WSXXX is available on /home/citace/MrData/mr_data_dump/

#Create New TablesForSPELL directory.
cd /home/wen/SPELL/
mkdir TablesForSPELL/
mkdir TablesForSPELL/noempty/
mkdir /home/wen/WormBaseToSPELL/currentSPELL/download/
mkdir /home/wen/WormBaseToSPELL/currentSPELL/download/datasets/
mkdir /home/wen/WormBaseToSPELL/currentSPELL/download/tables/
cp /home/citace/WS/ONTOLOGY/gene_ontology.WS*.obo /home/wen/SPELL/TablesForSPELL/gene_ontology.obo
cp /home/citace/WS/ONTOLOGY/gene_association.WS*.wb /home/wen/SPELL/TablesForSPELL/gene_association.wb

#This will create WBGeneName.ace, WBCeTARSample.ace and WBCeRNAseqAnalysis.ace files
cd /home/wen/WormBaseToSPELL/currentSPELL/
/home/wen/WormBaseToSPELL/bin/dumpWS_Gene_Analysis.sh
/home/wen/WormBaseToSPELL/bin/prepSRA.sh


#Make gene alias names and gene table 
#This will create gene_list.txt, alias_to_systematic.txt and systematic_to_common.txt files
/home/wen/WormBaseToSPELL/bin/make_alias_table_from_file.pl
mv gene_list.txt /home/wen/SPELL/TablesForSPELL/.
mv alias_to_systematic.txt /home/wen/SPELL/TablesForSPELL/.
mv systematic_to_common.txt /home/wen/SPELL/TablesForSPELL/.


#Make PCL files for Microarray and RNAseq for multi species
#This will create *.paper, *.csv files, as well as dataset_list_...txt and dataset_table_....txt files for microarray and RNAseq datasets.
cd /home/wen/WormBaseToSPELL/c_elegans/
/home/wen/WormBaseToSPELL/bin/createMrPCLandTables.pl ce
/home/wen/WormBaseToSPELL/bin/createRNAseqPCL.pl ce
/home/wen/WormBaseToSPELL/bin/make_RNAseq_dataset_table.pl ce

cd /home/wen/WormBaseToSPELL/c_briggsae/
/home/wen/WormBaseToSPELL/bin/createMrPCLandTables.pl cbg
/home/wen/WormBaseToSPELL/bin/createRNAseqPCL.pl cbg
/home/wen/WormBaseToSPELL/bin/make_RNAseq_dataset_table.pl cbg

cd /home/wen/WormBaseToSPELL/c_brenneri/
/home/wen/WormBaseToSPELL/bin/createMrPCLandTables.pl cbn
/home/wen/WormBaseToSPELL/bin/createRNAseqPCL.pl cbn
/home/wen/WormBaseToSPELL/bin/make_RNAseq_dataset_table.pl cbn

cd /home/wen/WormBaseToSPELL/c_remanei/
/home/wen/WormBaseToSPELL/bin/createMrPCLandTables.pl cre
/home/wen/WormBaseToSPELL/bin/createRNAseqPCL.pl cre
/home/wen/WormBaseToSPELL/bin/make_RNAseq_dataset_table.pl cre

cd /home/wen/WormBaseToSPELL/c_japonica/
/home/wen/WormBaseToSPELL/bin/createMrPCLandTables.pl cja
/home/wen/WormBaseToSPELL/bin/createRNAseqPCL.pl cja
/home/wen/WormBaseToSPELL/bin/make_RNAseq_dataset_table.pl cja

cd /home/wen/WormBaseToSPELL/p_pacificus/
/home/wen/WormBaseToSPELL/bin/createMrPCLandTables.pl ppa
#/home/wen/WormBaseToSPELL/bin/createRNAseqPCL.pl ppa
#/home/wen/WormBaseToSPELL/bin/make_RNAseq_dataset_table.pl ppa
#No RNAseq for ppa

#make dataset tables and PCL files for C.elegans tiling array
cd /home/wen/WormBaseToSPELL/TilingArray/
/home/wen/WormBaseToSPELL/bin/merge_TAR_ExprValue.pl
/home/wen/WormBaseToSPELL/bin/createTARcePCL.pl
/home/wen/WormBaseToSPELL/bin/make_TAR_dataset_table.pl

#move PCL files and downloadable files to TablesForSPELL/
mv /home/wen/WormBaseToSPELL/TilingArray/*.paper  /home/wen/SPELL/TablesForSPELL/noempty/.
mv /home/wen/WormBaseToSPELL/TilingArray/*.csv /home/wen/SPELL/TablesForSPELL/download/.
mv /home/wen/WormBaseToSPELL/c_*/*.paper /home/wen/SPELL/TablesForSPELL/noempty/.
mv /home/wen/WormBaseToSPELL/p_*/*.paper /home/wen/SPELL/TablesForSPELL/noempty/.
mv /home/wen/WormBaseToSPELL/c_*/*.csv /home/wen/WormBaseToSPELL/currentSPELL/download/datasets/.
mv /home/wen/WormBaseToSPELL/p_*/*.csv /home/wen/WormBaseToSPELL/currentSPELL/download/datasets/.
cd /home/wen/WormBaseToSPELL/currentSPELL/download/datasets/
tar -zcvf AllDatasetsDownload.tgz *.csv

#This will create dataset_list.txt and dataset_table.txt files for all species and experiments.
cd /home/wen/WormBaseToSPELL/currentSPELL/
cat /home/wen/WormBaseToSPELL/c_*/dataset_list*.txt  /home/wen/WormBaseToSPELL/p_*/dataset_list*.txt   /home/wen/WormBaseToSPELL/TilingArray/dataset_list_TAR.txt  > noid_dataset_list.txt
cat /home/wen/WormBaseToSPELL/c_*/dataset_table*.txt  /home/wen/WormBaseToSPELL/p_*/dataset_table*.txt   /home/wen/WormBaseToSPELL/TilingArray/dataset_table_TAR.txt  > noid_dataset_table.txt
/home/wen/WormBaseToSPELL/bin/enrich_dataset_table.pl 
mv dataset_list.txt /home/wen/SPELL/TablesForSPELL/.
mv dataset_table.txt /home/wen/SPELL/TablesForSPELL/.
mv dataset_table_enriched.txt /home/wen/SPELL/TablesForSPELL/.

#Make expression table.
cd /home/wen/SPELL/SpellUpdate/bin/
java -Xmx2g -jar create_expression_table.jar /home/wen/SPELL/SpellUpdate/spell_web/config/config.txt > /home/wen/SPELL/TablesForSPELL/expressionTable.txt

#--------------------------------------------------------------------------

#Update spell_dev mySQL database. 
#export MALLOC_CHECK_=0
#/home/wen/WormBaseToSPELL/update_spell_dev_dbi.pl

#--------------------------------------------------------------------------

#Create Tables for users to download.
cd /home/citace/MrData/ProbeCentricData/
cat /home/wen/WormBaseToSPELL/c_*/mrFileList.txt /home/wen/WormBaseToSPELL/p_*/mrFileList.txt > mrFileList.txt
/home/wen/WormBaseToSPELL/bin/listProbeMrFiles.pl
chmod a+x addTitle_MrProbeFiles.sh
tar -zcvf /home/wen/WormBaseToSPELL/currentSPELL/download/datasets/MrDataProbeCentric.tgz  *.csv
cd /home/wen/WormBaseToSPELL/currentSPELL/download/tables/
/home/wen/Tables/bin/createTopoMapTable.pl
/home/wen/Tables/bin/makeGeneTissueTable.pl
/home/wen/Tables/bin/makeTissueGeneTable.pl
/home/wen/Tables/bin/makeGeneExprClusTable.pl
/home/wen/Tables/bin/makeMrExpTable.pl

