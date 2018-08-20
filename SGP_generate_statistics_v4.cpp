#include <iostream>
#include <fstream>
#include <map>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <cstdarg>
#include <vector>
#include <sstream>
#include <iterator>
#include <sys/stat.h>
#include <cstddef>         
using namespace std;

unsigned long basecount=0;
unsigned int readcount=0;
unsigned long Acount=0, Ccount=0, Gcount=0, Tcount=0, TargetRegions=0;
map<int,unsigned long int> basequalitymap,readlengthmap;

void manual()
{
   cout << "\nmanual\n";
   cout<<"./SGP_generate_statistics_v4 <fastq1> <fastq2> <bed file> <param.txt>\n\n";
}

string getLasttoken (const std::string& str)
{
  size_t found = str.find_last_of("/\\");
  return str.substr(found+1);
}

void unzipDirectory(const char* filepath)
{
  struct stat sb;
  char folder[200];
  strcpy(folder,filepath);
  char* loc=strstr(folder,".fastq");
  strncpy(loc,"_fastqc",7); 
  cout << string(loc) << endl;                        
  cout<< string(folder) << endl;
  if (stat(folder, &sb) == 0 && S_ISDIR(sb.st_mode))
  {
      char scommand1[1000]="rm -r ";
      strcat(scommand1,folder);
      cout <<  scommand1 << endl;
      system(scommand1);
  }
   
  char command2[1000]="unzip ";
  strcat(command2,filepath);
  cout<< command2<<endl;
  char * pch1;
  pch1 = strstr (command2,".fastq");
  strncpy (pch1,"_fastq",6);
  strcat(command2,"c.zip");
  system(command2);
  cout << command2 << endl;
}


void loadData(const char* filepath)
{
  char fastqfile[1000];
  strcpy(fastqfile,filepath);
  ifstream infastqfile(fastqfile);
  bool seqflag;
  unsigned int i=0;
  unsigned int counter=0;
  char reads[1000];
  while (infastqfile)
  {
    i++;
    infastqfile.getline(reads,1000);
    if(i%4000000==0)
    {
      cout <<i/4000000<<" million reads processed from Sample "<<fastqfile<<"\r\n";
    }

    if(i%4==0)
    {
       readcount++;
       for(int c =0; c<strlen(reads); c++)
       {
           int ascii= int(reads[c])-33;
           basequalitymap[ascii]++; 
       }
       counter++;      
    }
    
    if(i==(2+counter*4))
    {
       basecount +=strlen(reads);
       for (int len=0;len < strlen(reads); len++)
       {
          if(reads[len]=='A')
             Acount++;
           else if(reads[len]=='C')
             Ccount++;
           else if(reads[len]=='G')
             Gcount++;
           else if(reads[len]=='T')
             Tcount++;
       }
       readlengthmap[strlen(reads)]++;  
    }
  }
  infastqfile.close(); 
}


int main(int argc, char** argv)
{

  if(argc != 5) 
  {
     manual();
     exit(1);
  }

  string fastq1=getLasttoken(argv[1]);
  string fastq2=getLasttoken(argv[2]);
  cout << fastq1.c_str() <<"\t"<< fastq2.c_str()<<"\n";
 

  char command[2000]="/illumina/TestExomes/softwares/FastQC/fastqc";
  strcat(command,"\t");
  strcat(command,argv[1]);
  strcat(command,"\t");
  strcat(command,argv[2]);
  system(command);

  unzipDirectory(fastq1.c_str());
  unzipDirectory(fastq2.c_str());
  
  loadData(fastq1.c_str());
  loadData(fastq2.c_str());
  
  ifstream configfile(argv[4]);
  char configline[1000];
  char sample_name[200];
  char ordernum[200];
  char capturekit[200];
  char sequencertype[200];
 
  if (configfile.is_open()) {
     while(configfile)
     {
        configfile.getline(configline,1000);
        if(strlen(configline) !=0) {
          char* pcon=strtok(configline,"\t");
         if(strcmp(pcon,"Sample")==0) { pcon=strtok(NULL,"\t");strcpy(sample_name,pcon);cout << sample_name << endl;}
         if(strcmp(pcon,"Order Number")==0) {pcon=strtok(NULL,"\t");strcpy(ordernum,pcon); cout << ordernum << endl;}
         if(strcmp(pcon,"Capture Kit")==0) {pcon=strtok(NULL,"\t"); strcpy(capturekit,pcon);cout << capturekit << endl;}
         if(strcmp(pcon,"Type of Sequencer")==0) {pcon=strtok(NULL,"\t"); strcpy(sequencertype,pcon);cout << sequencertype << endl;}
       }
     }
  } else cout <<"could not open config file\n";
  configfile.close();
  
  ofstream statfile("Sample_Run_Information");
  if (statfile.is_open()) {
     statfile << "Sample\t"<<sample_name<<endl;
     statfile << "Sample File\t" <<argv[1]<<", "<< argv[2]<<endl;
     statfile << "Order Number\t"<<ordernum<<"\n";
     statfile << "Capture Kit\t"<<capturekit<<"\n";
     statfile << "Type of Sequencer\t"<<sequencertype<<"\n";
  } else cout <<"could not open info file\n";
   statfile.close();
      

  ifstream bedfile(argv[3]);
  long int target_region=0;
  char str[1000];
  if (bedfile.is_open()) {
  while (bedfile)
  {
    if(!bedfile.eof()) 
    {
        bedfile.getline(str,1000);  
        if(strlen(str))
        {               
            char* pch = strtok(str,"\t");
            pch = strtok (NULL, "\t");    // strat
            long int start= atol(pch);
            pch = strtok (NULL, "\t");    // stop
            long int stop= atol(pch);
            target_region += (stop -start);
        }
    }
   } 
   } else cout <<"could not open info file\n";
   bedfile.close();
 
  unsigned long Q20=0;
  unsigned long Q30=0;
  unsigned long Qscore=0;
  
  for (std::map<int,unsigned long int>::iterator it=basequalitymap.begin(); it!=basequalitymap.end(); ++it)
  {
     if(it->first >= 20) {Q20 += it->second; cout << Q20 <<"\t"<< it->second<<"\n";}
     if(it->first >= 30) {Q30 += it->second; cout << Q30 <<"\t"<< it->second<<"\n";}
     Qscore += it->second;
  }


  unsigned long int xfreq =0;
  unsigned long int frequency=0;
  for (std::map<int,unsigned long int>::iterator it=readlengthmap.begin(); it!=readlengthmap.end(); ++it)
  {
      xfreq += (it->first)*(it->second); 
      frequency  += it->second;
  }

  ofstream Statistics("Statistics_Information");
  if(Statistics.is_open()) 
  {
      Statistics << "Total no Bases\t"<<basecount<<"\n";
      Statistics << "Total no Reads\t"<<readcount<<"\n";
      Statistics << "GC percentage\t"<<(Ccount+Gcount)*100/(basecount)<<"\n";
      Statistics << "Q20 percentage\t"<<(Q20*100)/(Qscore)<<"\n";
      Statistics << "Q30 percentage\t"<< (Q30*100)/(Qscore)<<"\n";
  } else cout <<"could not open Statistics Information file\n";
  Statistics.close();
   
  double avreadlength = double (xfreq)/double(frequency);
 
  ofstream PreAlignedStatistics("Pre_Alignment_Statistics");
  if(PreAlignedStatistics.is_open()) 
  {
     PreAlignedStatistics << "Total Number of Reads\t"<<readcount<<endl;
     PreAlignedStatistics << "Average Read Length (bp)\t"<< avreadlength <<"\n";
     PreAlignedStatistics << "Total Yield (Mbp)\t"<<(readcount)*(avreadlength)<<"\n";
     PreAlignedStatistics << "Target Regions (bp)\t"<<target_region<<"\n";
     PreAlignedStatistics << "Average Throughput Depth of Target regions (X)\t"<<(readcount*avreadlength)/target_region<<"\n";
  } else cout <<"could not open Pre Align Statistics file\n";
  PreAlignedStatistics.close();

  char shellcommand[500];
  strcpy(shellcommand,"sh gen_statistics_v2.sh ");
  strcat(shellcommand,sample_name);  
  system(shellcommand);
  
  return 0;
}


