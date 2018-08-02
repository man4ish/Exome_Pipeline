#include <iostream>
#include <fstream>
#include <map>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <cstdarg>
#include <sys/stat.h>

using namespace std;

unsigned int i1=0;
unsigned int i2=0;
unsigned long basecount=0;
unsigned int readcount=0;
map<int,unsigned long int> basequalitymap,readlengthmap;
int main(int argc, char** argv)
{
  char command[2000]="/illumina/TestExomes/softwares/FastQC/fastqc";
  strcat(command,"\t");
  strcat(command,argv[1]);
  strcat(command,"\t");
  strcat(command,argv[2]);
  system(command);

  char command2[1000]="unzip ";
  strcat(command2,argv[1]);
  cout<< command2<<endl;
  char * pch1;
  pch1 = strstr (command2,".fastq");
  cout<< pch1<< endl;
  strncpy (pch1,"_fastq",6);
  strcat(command2,"c.zip");
  struct stat sb,sb2;
 
  char folder1[200];
  strcpy(folder1,argv[1]);
  char* loc1=strstr(folder1,".fastq");
  strncpy(loc1,"_fastqc",7);
   
  //char folder1[200]="S671Nr1.1_fastqc";
  if (stat(folder1, &sb) == 0 && S_ISDIR(sb.st_mode))
  {
      char scommand1[1000]="rm -r ";
      strcat(scommand1,folder1);
      system(scommand1);
  }
  system(command2);

  cout<< command2<<endl;
  
  cout<< "********\n"; 
  
  char folder2[200];
  strcpy(folder2,argv[2]);
  char* loc2=strstr(folder2,".fastq");
  strncpy(loc2,"_fastqc",7);

  //char folder2[200]="S671Nr1.2_fastqc";
  if (stat(folder2, &sb2) == 0 && S_ISDIR(sb2.st_mode))
  {
        char scommand2[1000]="rm -r ";
        strcat(scommand2,folder2);
        cout <<"******"<< scommand2 << endl;
        system(scommand2);
  }


  char command3[1000]="unzip ";
  strcat(command3,argv[2]);
  char * pch2;
  pch2 = strstr (command3,".fastq");
  strncpy (pch2,"_fastq",6);
  cout << command3 << endl;
  strcat(command3,"c.zip"); 
  system(command3);



  cout << command3 << endl;
   
  char filename[2000];
  strcpy(filename,argv[1]);
  char * pch;
  char samplename[100];
  pch = strstr (filename,".");
  int pos = pch - filename;
  strncpy(samplename,filename,pos);
  cout<< samplename << endl;

  
  ofstream statfile("Sample_Run_Information");
  statfile << "Sample\t"<<samplename<<endl;
  statfile << "Order Number\t1802CNHP-0001\n";
  statfile << "Capture Kit\tSureSelect_V5\n";
  statfile << "Type of Sequencer\tHiSeq2500\n";
  statfile.close();

  /*ifstream infastqc("18-0700_1_fastqc/fastqc_data.txt");
  while (infastqc)
  {
      char recline[1000];
       cout <<infastqc.getline(recline,1000) << endl;
  }   
  infastqc.close();*/

 
  unsigned long Acount=0, Ccount=0, Gcount=0, Tcount=0, TargetRegions=0;

  ifstream in1(argv[1]);
  bool seqflag;
  unsigned int counter=0;
  char reads1[1000];
  while (in1)
  {
    i1++;
    in1.getline(reads1,1000);
    if(i1%4000000==0)
    {
      cout <<i1/4000000<<" million reads processed from Sample "<< argv[1]<<"\r\n";
    }

    if(i1%4==0)
    {
       readcount++;
       for(int c =0; c<strlen(reads1); c++)
       {
           int ascii= int(reads1[c])-33;
           basequalitymap[ascii]++; 
       }
       counter++;      
    }
    
    if(i1==(2+counter*4))
    {
       basecount +=strlen(reads1);
       for (int len=0;len < strlen(reads1); len++)
       {
          if(reads1[len]=='A')
             Acount++;
           else if(reads1[len]=='C')
             Ccount++;
           else if(reads1[len]=='G')
             Gcount++;
           else if(reads1[len]=='T')
             Tcount++;
       }
       readlengthmap[strlen(reads1)]++;  
    }
  }
  in1.close(); 


  unsigned int counter2=0;
  ifstream in2(argv[2]);
  char reads2[1000];
  while (in2)
  {
    i2++;
    in2.getline(reads2,1000);
    if(i2%4000000==0)
    {
      cout <<i2/4000000<<" million reads processed from Sample "<< argv[2]<<"\r\n";
    }

    if(i2%4==0)
    {
       readcount++;
       for(int c =0; c<strlen(reads2); c++)
       {
           int ascii= int(reads2[c])-33;
           basequalitymap[ascii]++;
       }
       counter2++;
    }
    if(i2==(2+counter2*4))
    {
       basecount+=strlen(reads2);
       for (int len=0;len < strlen(reads2); len++)
       {
          if(reads2[len]=='A')
             Acount++;
           else if(reads2[len]=='C')
             Ccount++;
           else if(reads2[len]=='G')
             Gcount++;
           else if(reads2[len]=='T')
             Tcount++;
       }
       readlengthmap[strlen(reads2)]++;
    }
  } 
  in2.close();

  ifstream infile(argv[3]);
  long int target_region=0;
  char str[1000];
  while (infile)
  {
    if(!infile.eof()) 
    {
        infile.getline(str,1000);  
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
 
  unsigned long Q20=0;
  unsigned long Q30=0;
  unsigned long Qscore=0;
  
  for (std::map<int,unsigned long int>::iterator it=basequalitymap.begin(); it!=basequalitymap.end(); ++it)
  {
     if(it->first >= 20) {Q20 += it->second; cout << Q20 <<"\t"<< it->second<<"\n";}
     if(it->first >= 30) {Q30 += it->second; cout << Q30 <<"\t"<< it->second<<"\n";}
     Qscore += it->second;
  }


  unsigned long int xf =0;
  unsigned long int f=0;
  for (std::map<int,unsigned long int>::iterator it=readlengthmap.begin(); it!=readlengthmap.end(); ++it)
  {
      xf += (it->first)*(it->second); 
      f  += it->second;
      //std::cout <<xf<<"\t"<< it->first << " => " << it->second << '\n';
  }

  ofstream Statistics("Statistics_Information");
  Statistics << "Sample\t"<<samplename<<endl;
  Statistics << "Total no Bases\t"<<basecount<<"\n";
  Statistics << "Total no Reads\t"<<readcount<<"\n";
  Statistics << "GC percentage\t"<<(Ccount+Gcount)*100/(basecount)<<"\n";
  Statistics << "Q20 percentage\t"<<(Q20*100)/(Qscore)<<"\n";
  Statistics << "Q30 percentage\t"<< (Q30*100)/(Qscore)<<"\n";
  Statistics.close();

   
  double avreadlength = double (xf)/double(f);
  cout <<xf<<"\t"<<f<<"\t"<<avreadlength <<"\n";
  ofstream PreAlignedStatistics("Pre_Alignment_Statistics");
  PreAlignedStatistics << "Total Number of Reads\t"<<readcount<<endl;
  PreAlignedStatistics << "Average Read Length (bp)\t"<< avreadlength <<"\n";
  PreAlignedStatistics << "Total Yield (Mbp)\t"<<(readcount)*(avreadlength)<<"\n";
  PreAlignedStatistics << "Target Regions (bp)\t"<<target_region<<"\n";
  PreAlignedStatistics << "Average Throughput Depth of Target regions (X)\t"<<(readcount*avreadlength)/target_region<<"\n";
  PreAlignedStatistics.close();


  char shellcommand[500];
  strcpy(shellcommand,"sh gen_statistics.sh ");
  strcat(shellcommand,samplename);  
  system(shellcommand);
  
  return 0;
}


