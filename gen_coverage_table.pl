#!/usr/bin/perl
open (fh, $ARGV[0]) or die "could not open coverage file\n";
$one=0, $ten=0, $twenty=0, $thirty, $fifty=0;
$count=0;
while($input=<fh>)
{
    chomp($input);
    @rec=split(" ",$input);
    if($rec[2] > 1) {$one++;}
    if($rec[2] > 10) {$ten++;}
    if($rec[2] > 20) {$twenty++;}
    if($rec[2] > 30) {$thirty++;}
    if($rec[2] > 50) {$fifty++;}
    $count++;
}
close(fh);

open (out, ">coverage_summary") or die "could not open output file\n";
print out  ("%Coverage\t%>1X\t%>10X\t%>20X\t%>30X\t%>50\n");
print out "Value\t".(($one*100)/$count)."\t".(($ten*100)/$count)."\t".(($twenty*100)/$count)."\t".(($thirty*100)/$count)."\t".(($fifty*100)/$count)."\n";
close(out);
