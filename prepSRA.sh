
#----------prepare RNAseq expression files for PCL generation ---------
#------------ all species for microarray are in c_elegans folder ----
cd /home/wen/WormBaseToSPELL/c_elegans/
#ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*Mr*.txt /home/wen/LargeDataSets/Microarray/MrDataFromACeDB/OldDafaForWS/*MrData.txt  /home/wen/LargeDataSets/Microarray/MrDataFromACeDB/ReAnnotate/*/*MrData.txt  > mrFileList.txt
ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*Mr*.txt /home/wen/LargeDataSets/Microarray/MrDataFromACeDB/OldDafaForWS/*MrData.txt > mrFileList.txt
#rm *SRA_gene_expression.tar.gz
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_elegans/PRJNA*/annotation/c_elegans.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_elegans.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_elegans.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_briggsae/
#ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*cbgMr.txt > mrFileList.txt
#rm *SRA_gene_expression.tar.gz
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_briggsae/PRJNA*/annotation/c_briggsae.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_briggsae.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_briggsae.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_brenneri/
#ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*cbnMr.txt > mrFileList.txt
#rm *SRA_gene_expression.tar.gz
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_brenneri/PRJNA*/annotation/c_brenneri.*.WS*.SRA_gene_expression.tar.gz .
gunzip c_brenneri.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_brenneri.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_remanei/
#ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*creMr.txt > mrFileList.txt
#rm *SRA_gene_expression.tar.gz
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_remanei/PRJNA*/annotation/c_remanei.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_remanei.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_remanei.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_japonica/
#ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*cjaMr.txt > mrFileList.txt
#rm *SRA_gene_expression.tar.gz
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_japonica/PRJNA*/annotation/c_japonica.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_japonica.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_japonica.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/p_pacificus/
#ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*ppaMr.txt > mrFileList.txt

#--------Prepare Tiling Array expression files for PCL generation -----
cd /home/wen/WormBaseToSPELL/TilingArray/
#rm *TAR_gene_expression.tar.gz
rm *TAR_gene_expression.tar
rm *.out*
cp /home/citace/WS/species/c_elegans/PRJNA*/annotation/c_elegans.PRJNA*.WS*.TAR_gene_expression.tar.gz .
gunzip c_elegans.PRJNA*.WS*.TAR_gene_expression.tar.gz
tar -xvf c_elegans.PRJNA*.WS*.TAR_gene_expression.tar
ls genes_*.out > exprFileList.txt

