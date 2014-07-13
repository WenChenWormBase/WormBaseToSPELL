
This is the README file for Scripts for that generate SPELL database

wb2spell.sh is the master script that manage the whole process of converting microarray, RNAseq and tiling array data from multi-species into SPELL data files. The following scripts work on different jobs during this process. 

1. dumpWS_Gene_Analysis.sh
 
Dump out all the required ace files from current WS release and store them under ../ace_files/

2. prepSRA.sh

Copy and unzip all the RNAseq and tiling array expression value files from current WS release and store them in different species folders.

3. make_alias_table_from_file.pl

Create gene_list.txt, alias_to_systematic.txt, and systematic_to_common.txt files for SPELL database.

4. createMrPCLandTables.pl

Create PCL files, dataset_list_mr.txt and dataset_table_mr.txt files for microarray data of different species. This script can parse all species at the same time. For example: ./createMrPCLandTables.pl

5. createRNAseqPCL.pl  

Create PCL files for RNAseq data of different species. Need to add species specifications when running the script. For example: ./createRNAseqPCL.pl ce

6. make_RNAseq_dataset_table.pl

Create dataset_list_RNAseq.txt and dataset_table_RNAseq.txt files for different species. Need to add species specifications when running the script. For example: ./make_RNAseq_dataset_table.pl ce

7. merge_TAR_ExprValue.pl

Work on the expression value files for tiling array experiments to merge values to one value per gene.

8. createTARcePCL.pl

Create PCL files for tiling array data (C. elegans only).

9. make_TAR_dataset_table.pl

Create dataset_list_TAR.txt and dataset_table_TAR.txt files for tiling array data (C. elegans only).

10. enrich_dataset_table.pl

Merge all the dataset_list*.txt and dataset_table*.txt files from different species and data types, create the final version of dataset_list.txt, dataset_table.txt and dataset_table_enriched.txt files for SPELL database. dataset_table_enriched.txt has HTML links embedded in the entries. This is the file that will be read into SPELL database.  

11. update_spell_dev_dbi.pl

This script update SPELL database with the newly generated table files. 

12. listProbeMrFiles.pl

Create a shell script called addTitle_MrProbeFiles.sh to add column titles to the probe centric microarray data files. 

13. create_cv_terms_and_defs.pl

This script create part of rhtml files for SPELL to display definition of tags. out file is called add_CV_link.rhtml. It does not need to be run in every build. It is only done when new tags are added to SPELL datasets.


--------------------------------------------------
Required file structures for the scripts to run

under /home/wen/WormBaseToSPELL/

ace_files  c_brenneri  c_elegans   c_remanei     log          p_pacificus
bin        c_briggsae  c_japonica  currentSPELL  OldPipeline  TilingArray

All the scripts stored under bin/, all other folders can be made empty. 

----------------------------------------------------


Other scripts:

1. getSPELLusage.pl  -- get unique IPs from develpment.log files

2. mapYK2Gene.pl - create links between yk cDNA clones and gene objects.

