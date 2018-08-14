#!/usr/bin/sh

samplename=$1
#if [ 1 -eq 0 ]; then
samtools flagstat output.bam > mapped.statistics
file="Post-alignment_Statistics"
if [ -f $file ] ; then rm $file; fi
initial_reads=$(grep "QC-passed reads" mapped.statistics  | awk '{print "Initial Mappable Reads\t"$1}')
java -jar /illumina/TestExomes/softwares/picard-tools-1.130/picard.jar CollectInsertSizeMetrics  I=sorted.bam  O=insert_size_metrics.txt  H=insert_size_histogram.pdf
convert insert_size_histogram.pdf insert_size_histogram.png
grep -A 1 "MEDIAN_INSERT_SIZE" insert_size_metrics.txt | awk  '{print $1"\t"$6}' > metrics.table
#if [ -f $non_red_file ] ; then rm $non_red_file; fi
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y; do samtools flagstat remdup$i.bam | grep "QC-passed" | awk '{print "Non-Redundant Reads\t"$1}' >> non_red_chr; done;
non_redundant_reads=$(awk -F "\t"  '{sum += $2} END {print "Non-Redundant Reads\t"sum}' non_red_chr )
#On-Target Yield

target_file="recal_chr"
if [ -f $target_file ] ; then rm $target_file; fi
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y; do samtools flagstat chr$i.recal.bam | grep "QC-passed" | awk '{print "On-Target Reads\t"$1}' >> recal_chr; done;
target_reads=$(awk  -F "\t" '{sum += $2} END {print "On-Target Reads\t"sum}' recal_chr)

samtools view -bh sorted.bam -L SureSelect_v5.bed > tmpOut.bam
samtools depth tmpOut.bam > sorted.coverage
perl gen_coverage_table.pl sorted.coverage
Rscript gen_plot.R

on_target_yields=$(samtools flagstat tmpOut.bam | grep "QC-passed reads" | awk '{print "On-Target Yield (bp)\t"$1}')
echo "${initial_reads}" > $file
echo "${non_redundant_reads}" >> $file
echo "${target_reads}" >> $file
echo "${on_target_yields}" >> $file

#Rscript generate_post_alignment_plot.R

#vcf-concat chr1.Filtered.Variants.vcf chr2.Filtered.Variants.vcf chr3.Filtered.Variants.vcf chr4.Filtered.Variants.vcf chr5.Filtered.Variants.vcf chr6.Filtered.Variants.vcf chr7.Filtered.Variants.vcf chr8.Filtered.Variants.vcf chr9.Filtered.Variants.vcf chr10.Filtered.Variants.vcf chr11.Filtered.Variants.vcf chr12.Filtered.Variants.vcf chr13.Filtered.Variants.vcf chr14.Filtered.Variants.vcf  chr15.Filtered.Variants.vcf chr16.Filtered.Variants.vcf chr17.Filtered.Variants.vcf chr18.Filtered.Variants.vcf chr19.Filtered.Variants.vcf chr20.Filtered.Variants.vcf chr21.Filtered.Variants.vcf chr22.Filtered.Variants.vcf chrX.Filtered.Variants.vcf chrY.Filtered.Variants.vcf > chrmerged.Filtered.Variants.vcf
java -jar CancerAnalysisPackage-2015.1-3/GenomeAnalysisTK.jar -T VariantEval -D dbsnp138_142.vcf -R Refgenome_ucsc/ucsc.hg19.fasta -o output.eval.grp --eval chrmerged.Filtered.Variants.vcf
snp_indel_file="snp_indel_statistics"
if [ -f $snp_indel_file ] ; then rm $snp_indel_file; fi
summary=$(grep "VariantSummary" output.eval.grp  | grep "all" | awk '{print "No. of SNPs\t"$8"\nTsTv Ration\t"$9"\nNo. of Indels\t"$14}')
hethom=$(grep "CountVariants" output.eval.grp  | grep -w "all"  | awk '{print "Het/Hom Ration\t"$27}')
known=$(grep "CompOverlap" output.eval.grp | grep "all" | awk '{print "% Found in dbSNP142\t"$11}')
#write summary, hethom and known in file
echo "${summary}" > $snp_indel_file 
echo "${hethom}" >> $snp_indel_file
echo "${known}" >> $snp_indel_file

#fi
export RSTUDIO_PANDOC=/usr/lib/rstudio/bin/pandoc
export RSTUDIO_PANDOC=/usr/lib/rstudio/bin/pandoc
R -e rmarkdown::render"('report_generator.rmd',params=list(sample='"$samplename"'),output_file='report.html')"
./wkhtmltox/bin/wkhtmltopdf -s A4 -L 20 -T 10 -R 2 -B 10 --footer-spacing 0 --footer-center "KACST Exome Pipeline" --footer-right "[page]/[topage]" --footer-font-size 10 report.html $samplename.pdf

#R -e rmarkdown::render"('input.rmd',params=list(sample='"$samplename"'),output_file='report.html')"
#wkhtmltopdf report.html $samplename.pdf
