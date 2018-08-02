#!/usr/bin/sh
number=$1
samtools-1.2/samtools sort -@ 32 -m 3G out$number.bam sorted$number
java -jar picard-tools-1.130/picard.jar MarkDuplicates I=sorted$number.bam O=remdup$number.bam M=picard_metrics$number.txt CREATE_INDEX=true  AS=true REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=40000000 COMPRESSION_LEVEL=0 MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=100000

java -Xmx50g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T RealignerTargetCreator -R Refgenome_ucsc/ucsc.hg19.fasta -I remdup$number.bam -known Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -known 1000G_phase1.indels.hg19.sites.vcf -known dbsnp138_142.vcf -o chr$number.test_intervals -L SureSelect_v5.bed --interval_padding 100 --disable_auto_index_creation_and_locking_when_reading_rods -nt 4

java -Xmx50g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T IndelRealigner -R Refgenome_ucsc/ucsc.hg19.fasta -I remdup$number.bam -known Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -known 1000G_phase1.indels.hg19.sites.vcf -known dbsnp138_142.vcf -targetIntervals chr$number.intervals -L SureSelect_v5.bed --interval_padding 100 -o chr$number.realign.bam -compress 0 --disable_auto_index_creation_and_locking_when_reading_rods

java -Xmx50g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T BaseRecalibrator -R Refgenome_ucsc/ucsc.hg19.fasta -I chr$number.realign.bam -knownSites dbsnp138_142.vcf -knownSites Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -knownSites 1000G_phase1.indels.hg19.sites.vcf -L SureSelect_v5.bed --interval_padding 100 -o chr$number.firstpass.table -nct 24 --disable_auto_index_creation_and_locking_when_reading_rods

java -Xmx50g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T PrintReads -R Refgenome_ucsc/ucsc.hg19.fasta -I chr$number.realign.bam -BQSR  chr$number.firstpass.table -o chr$number.recal.bam -L SureSelect_v5.bed --interval_padding 100 --disable_auto_index_creation_and_locking_when_reading_rods -nct 24

java -Xmx10g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T HaplotypeCaller -R Refgenome_ucsc/ucsc.hg19.fasta -ERC GVCF -pairHMM VECTOR_LOGLESS_CACHING -variant_index_type LINEAR --dbsnp dbsnp138_142.vcf -variant_index_parameter 128000 -I chr$number.recal.bam -o chr$number.g.vcf -L SureSelect_v5.bed --interval_padding 100 --disable_auto_index_creation_and_locking_when_reading_rods -nct 32

java -Xmx10g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T GenotypeGVCFs -R Refgenome_ucsc/ucsc.hg19.fasta --variant chr$number.g.vcf --out chr$number.rawVariants.vcf --dbsnp dbsnp138_142.vcf -L SureSelect_v5.bed --interval_padding 100 --disable_auto_index_creation_and_locking_when_reading_rods -nt 1

java -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T SelectVariants -R Refgenome_ucsc/ucsc.hg19.fasta  -V chr$number.rawVariants.vcf -selectType SNP -o chr$number.rawSNPs.vcf

java -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T SelectVariants -R Refgenome_ucsc/ucsc.hg19.fasta  -V chr$number.rawVariants.vcf -selectType INDEL -o chr$number.rawINDELs.vcf

java -Xmx8g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T VariantFiltration -R Refgenome_ucsc/ucsc.hg19.fasta --variant chr$number.rawSNPs.vcf --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 " --filterName "MG_SNP_Filter" -o chr$number.rawSNPs.filtered.vcf

java -Xmx8g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T VariantFiltration -R Refgenome_ucsc/ucsc.hg19.fasta --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 " --filterName "MG_INDEL_Filter" --variant chr$number.rawINDELs.vcf -o chr$number.rawINDELs.filtered.vcf

java -Xmx8g -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T CombineVariants -R Refgenome_ucsc/ucsc.hg19.fasta --genotypemergeoption UNSORTED --variant chr$number.rawSNPs.filtered.vcf --variant chr$number.rawINDELs.filtered.vcf -o chr$number.Filtered.Variants.vcf --disable_auto_index_creation_and_locking_when_reading_rods


#comment below line as some of the intermediate files are needed for generating reports. moving this line to gen_statistics.sh
#rm chr$number.intervals out$number.bam sorted$number.bam sorted$number.bai chr$number.recal.bam chr$number.realign.bam chr$number.rawVariants.vcf chr$number.g.vcf  chr$number.rawSNPs.vcf chr$number.rawINDELs.filtered.vcf

