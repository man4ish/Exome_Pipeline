pipeline for processing exome data.<br>
Requirements:<br>
Programming Languages:<br>
R Language<br>
C++ <br>
Java (verison 8)<br><br>

Step1. Install all dependencies and softwares.<br>
sh setup.sh                                          #pls modify SGP_illumina_suite pth in setup.sh after copying on different machine.<br>
Step2. Check all dependencies.<br>
sh check_dependencies.sh<br>
Step3. Run the pipeline<br>
sh run_pipeline_allchr.sh  <fastq1> <fastq2> <br>
step4. Generate QC reports <br>
./SGP_generate_statistics_v3 <fastq1> <fastq2> SureSelect_v5.bed <param.txt>

