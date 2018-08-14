#pipeline for processing exome data.
#Requirements:
#Programming Languages:
R Language
C++ 
Java (verison 8)

#Step1. Install all dependencies and softwares.
sh setup.sh                                          #pls modify SGP_illumina_suite pth in setup.sh after copying on different machine.
#Step2. Check all dependencies.
sh check_dependencies.sh
#Step3. Run the pipeline
sh run_pipeline_allchr.sh  <fastq1> <fastq2>
#step4. Generate QC reports
./SGP_generate_statistics_v3 <fastq1> <fastq2> SureSelect_v5.bed <param.txt>

