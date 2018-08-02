#!/usr/bin/sh
bwa-0.7.12/bwa mem -t 32 -M -R "@RG\tPL:Illumina\tID:SN7001218\tSM:18-0700\tLB:SS5" Refgenome_ucsc/ucsc.hg19.fasta $1 $2 > output.sam
samtools-1.2/samtools view -bSu output.sam >  output.bam
samtools-1.2/samtools sort -@ 32 -m 3G output.bam sorted
samtools index sorted.bam
for number in  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y; 
do 
samtools-1.2/samtools view sorted.bam chr$number -b > out$number.bam
sh run_pipeline_chr.sh $number
done;

vcf-concat chr1.Filtered.Variants.vcf chr2.Filtered.Variants.vcf chr3.Filtered.Variants.vcf chr4.Filtered.Variants.vcf chr5.Filtered.Variants.vcf chr6.
Filtered.Variants.vcf chr7.Filtered.Variants.vcf chr8.Filtered.Variants.vcf chr9.Filtered.Variants.vcf chr10.Filtered.Variants.vcf chr11.Filtered.Varia
nts.vcf chr12.Filtered.Variants.vcf chr13.Filtered.Variants.vcf chr14.Filtered.Variants.vcf  chr15.Filtered.Variants.vcf chr16.Filtered.Variants.vcf ch
r17.Filtered.Variants.vcf chr18.Filtered.Variants.vcf chr19.Filtered.Variants.vcf chr20.Filtered.Variants.vcf chr21.Filtered.Variants.vcf chr22.Filtere
d.Variants.vcf chrX.Filtered.Variants.vcf chrY.Filtered.Variants.vcf > chrmerged.Filtered.Variants.vcf
