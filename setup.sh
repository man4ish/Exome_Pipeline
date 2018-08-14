#!/usr/bin/sh

#please install R,C++ and Java( version 8)
#please open terminal in X11 mode for generating report in visual mode.

sudo apt-get install xvfb libfontconfig wkhtmltopdf  # install wkhtmltopdf for converting html into pdf report
sudo apt-get install imagemagick                     # install imagemagick for converting pdf into png

path=/illumina/SGP_illumina_suite     #please change path to absolute path on the machine
ln -s $path/softwares/knitr_1.20.tar.gz .
ln -s $path/softwares/rmarkdown_1.10.tar.gz .
ln -s $path/softwares/reshape_0.8.7.tar.gz .
ln -s $path/script/SGP_generate_statistics_v2.cpp .

R CMD INSTALL knitr_1.20.tar.gz
R CMD INSTALL rmarkdown_1.10.tar.gz
R CMD INSTALL reshape_0.8.7.tar.gz

g++ SGP_generate_statistics_v3.cpp -o SGP_generate_statistics_v3

ln -s $path/script/run_pipeline_v1.sh .
ln -s $path/db/1000G_phase1.indels.hg19.sites.vcf .
ln -s $path/db/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf .
ln -s $path/db/dbsnp138_142.vcf .
ln -s $path/db/Refgenome_ucsc . 
ln -s $path/softwares/picard-tools-1.130 .
ln -s $path/softwares/GATK_version3.4 CancerAnalysisPackage-2015.1-3
ln -s $path/softwares/bwa-0.7.12 .
ln -s $path/db/SureSelect_v5.bed .
ln -s $path/softwares/samtools-1.2 .
ln -s $path/script/get_statistics.pl .
ln -s $path/script/gen_statistics.sh .
ln -s $path/script/input.rmd .
ln -s $path/softwares/FastQC/fastqc .

