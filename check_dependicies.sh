#!/bin/sh

for i in bwa-0.7.12  CancerAnalysisPackage-2015.1-3  picard-tools-1.130  samtools-1.2 Refgenome_ucsc FastQC;
do echo $i;

if [ -d "$i" ]
then
    echo "ok"
else
    echo "$i does not exist"; exit $ERRCODE;
fi
done;


for db in 1000G_phase1.indels.hg19.sites.vcf Mills_and_1000G_gold_standard.indels.hg19.sites.vcf dbsnp_138.vcf SureSelect_v5.bed;
do echo $db;

if [ -f "$db" ]
then
    echo "ok"
else
    echo "$db does not exist"; exit $ERRCODE;
fi
done;


for code in gen_statistics.sh get_statistics.pl SGP_generate_statistics_v3 gen_plot.R report_generator.rmd gen_coverage_table.pl run_pipeline_v1.sh;
do echo $code;

if [ -f "$code" ]
then
    echo "ok"
else
    echo "$code does not exist"; exit $ERRCODE;
fi
done;









