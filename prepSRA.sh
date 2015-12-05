
#----------prepare RNAseq expression files for PCL generation ---------
#------------ all species for microarray are in c_elegans folder ----
cd /home/wen/WormBaseToSPELL/c_elegans/
#ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*Mr*.txt /home/wen/LargeDataSets/Microarray/MrDataFromACeDB/OldDafaForWS/*MrData.txt  /home/wen/LargeDataSets/Microarray/MrDataFromACeDB/ReAnnotate/*/*MrData.txt  > mrFileList.txt
ls /home/wen/LargeDataSets/Microarray/NewDataForWS/*/*/*Mr*.txt /home/wen/LargeDataSets/Microarray/MrDataFromACeDB/OldDafaForWS/*MrData.txt > mrFileList.txt
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_elegans/PRJNA*/annotation/c_elegans.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_elegans.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_elegans.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_briggsae/
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_briggsae/PRJNA*/annotation/c_briggsae.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_briggsae.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_briggsae.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_brenneri/
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_brenneri/PRJNA*/annotation/c_brenneri.*.WS*.SRA_gene_expression.tar.gz .
gunzip c_brenneri.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_brenneri.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_remanei/
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_remanei/PRJNA*/annotation/c_remanei.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_remanei.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_remanei.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/c_japonica/
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/c_japonica/PRJNA*/annotation/c_japonica.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip c_japonica.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf c_japonica.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/p_pacificus/
rm *SRA_gene_expression.tar
rm SRX*.out
cp /home/citace/WS/species/p_pacificus/PRJNA*/annotation/p_pacificus.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip p_pacificus.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf p_pacificus.PRJNA*.WS*.SRA_gene_expression.tar
ls SRX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/b_malayi/
rm *SRA_gene_expression.tar
rm ERX*.out
cp /home/citace/WS/species/b_malayi/PRJNA*/annotation/b_malayi.PRJNA*.WS*.SRA_gene_expression.tar.gz .
gunzip b_malayi.PRJNA*.WS*.SRA_gene_expression.tar.gz
tar -xvf b_malayi.PRJNA*.WS*.SRA_gene_expression.tar
ls ERX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/o_volvulus/
rm *SRA_gene_expression.tar
rm ERX*.out
cp /home/citace/WS/species/o_volvulus/PRJEB*/annotation/o_volvulus.PRJEB*.WS*.SRA_gene_expression.tar.gz .
gunzip o_volvulus.PRJEB*.WS*.SRA_gene_expression.tar.gz
tar -xvf o_volvulus.PRJEB*.WS*.SRA_gene_expression.tar
ls ERX*.out > exprFileList.txt

cd /home/wen/WormBaseToSPELL/s_ratti/
rm *SRA_gene_expression.tar
rm ERX*.out
cp /home/citace/WS/species/s_ratti/PRJEB*/annotation/s_ratti.PRJEB*.WS*.SRA_gene_expression.tar.gz .
gunzip s_ratti.PRJEB*.WS*.SRA_gene_expression.tar.gz
tar -xvf s_ratti.PRJEB*.WS*.SRA_gene_expression.tar
ls ERX*.out > exprFileList.txt

#--------Prepare Tiling Array expression files for PCL generation -----
cd /home/wen/WormBaseToSPELL/TilingArray/
#rm *TAR_gene_expression.tar.gz
rm *TAR_gene_expression.tar
rm *.out*
cp /home/citace/WS/species/c_elegans/PRJNA*/annotation/c_elegans.PRJNA*.WS*.TAR_gene_expression.tar.gz .
gunzip c_elegans.PRJNA*.WS*.TAR_gene_expression.tar.gz
tar -xvf c_elegans.PRJNA*.WS*.TAR_gene_expression.tar
ls genes_*.out > exprFileList.txt

