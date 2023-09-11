#! /usr/bin/bash
##需要基因组和基因的注释
fasta=
gff=
speciesname=
##01.提取cds和pep
gffread $gff  -g $fasta  -x $speciesname.cds.fa -y $speciesname.pep.fa

##02.根据注释提取蛋白序列和编码区位置
cat $gff | awk '{OFS="\t"; print $1,$4,$5,$3,$9}' | grep 'CDS' > $speciesname.exclude.bed

##03.EDTA analysis
perl /data/01/user214/software/EDTA-2.0.1/EDTA.pl  --genome $fasta --cds $speciesname.cds.fa --exclude $speciesname.exclude.bed --overwrite 1 --sensitive 1 --anno 1 --evaluate 1 --threads 10
