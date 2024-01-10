#!/bin/bash
#Three VCF Analysis (TVA)  
#First Version: BT Dec 8, 2023
#V1.2 adds venn plotting
#Version V1.3 aims to make the program a stand-alone with yad interface 

zenity --width 1000 --info --title "Three VCF Analyzer - TVA" --text "
Version 1.3

ABOUT: A GUI tool to compare three VCF files, each produced by a different caller.  The tool provides a count of variants unique to each caller, those common to two of three callers and those common to all three callers.     

Originally built to evaluate three VCFs created using BCFtools mpileup, FreeBayes, GATK HaplotypeCaller where each VCF was previously filtered and annotated using either the Mutation Finder Annotator (MFA) tool or the VCF Subset and Annotator (VSA) tool.  NOTE: This program should work with VCFs created using different callers, but this has not been tested. 

INPUTS: Unzipped VCF files.

OUTPUTS: 1. A new VCF that contains variants common to all three tools (in GATK format when defaults are used). 2. A table report of variant counts. 3. A Venn diagram of variant counts. 4. A log file that contains the R code used to make the diagram.  

WARNINGS: Paths to VCF files should not contain spaces or the symbols / or $.  For example, it is okay if your VCFs are on an external USB drive named My_Drive, but if your drive is named My Drive, /MyDrive, etc., the program may not find your files. 

This tool performs analysis based on postion of variant call, not the call itself. Future versions can be made to be more sophisticated in terms of variant call and number of input VCFs if needed.  

LICENSE:  
MIT License
Copyright (c) 2024 Bradley John Till
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the *Software*), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

DEPENDENCIES:  Bash, zenity, yad, grep, awk, R, ggplot2(R), VennDiagram(R)
VERSION INFORMATION: January 9, 2024 BT"

directory=`zenity --width 500 --title="DIRECTORY" --text "Enter text to create a new directory (e.g. Trial1_Jan06_2024_BT).  
WARNING: No spaces or symbols other than an underscore." --entry`

if [ "$?" != 0 ]
then
    exit
    fi
mkdir $directory
cd $directory

YADINPUT=$(yad --width=600 --title="TVA PARAMETERS" --text="CAUTION: Avoid the use of | and $ as these are special symbols for this program"  --form --field="Your Initials (for the log file)" "Enter" --field="Caller used to make first VCF (name will appear on plot, click to change)" "BCFtools" --field="Select the first VCF:FL" "" --field="Caller used to make second VCF (click to change)" "FreeBayes" --field="Select the second VCF:FL" "" --field="Caller used to make third VCF (click to change)" "GATK" --field="Select the third VCF:FL" "" --field="**********PLOTTING PARAMETERS BELOW (defaults should produce a legible diagram)**********":LBL "" --field="Color in Venn for first VCF (click to change)":CLR "#456f01" --field="Color in Venn for second VCF (click to change)":CLR "deepskyblue4" --field="Color in Venn for third VCF (click to change)":CLR "#ffac12" --field="Outlines of Venn diagram:CB" 'None!Solid!Dashes!Dots' --field="Diagram rotation in degrees (click box to manually edit):CBE" '30!0!45!90!135!180!225!270!315' --field="Size of values (numbers) in Venn circles (click to change, or manually edit)":NUM "1[!0..50[!.5[!1]]]" --field="Font of numbers in Venn circles:CB" 'sans!serif!Palatino!AvantGarde!Helvetica-Narrow!URWBookman!NimbusMon!URWHelvetica!NimbusSanCond!CenturySch!URWPalladio' --field="Style of numbers in Venn circles:CB" 'plain!bold!italic!bold.italic' --field="Size of labels (click to change, or manually edit)":NUM "1.4[!0..50[!.1[!1]]]" --field="Font of labels:CB" 'sans!serif!Palatino!AvantGarde!Helvetica-Narrow!URWBookman!NimbusMon!URWHelvetica!NimbusSanCond!CenturySch!URWPalladio' --field="Style of labels:CB" 'plain!bold!italic!bold.italic' --field="Format to save plot:CB" 'jpeg!tiff!pdf!png!bmp!eps!svg') 
 echo $YADINPUT >> yad1
 
zenity --width 400 --info --title "READY TO LAUNCH" --text "Click OK to start the Three VCF Analysis (TVA) program."
if [ "$?" != 0 ]
then
    exit
fi
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>TVAt.log 2>&1
now=$(date)  
echo "TVA version 1.3
Script Started $now."  
(#Start 
echo "# Collecting Parameters"; sleep 2  
 
#Parameters file converted for the Venn circle outline parameter that needs to be in number format
tr '|' '\t' < yad1 | datamash transpose | head -n -1 | awk '{if ($1=="None") print "\x22""blank""\x22"; else print $0}' | awk '{if ($1=="Solid") print 1; else print $0}' | awk '{if ($1=="Dashes") print 2; else print $0}' | awk '{if ($1=="Dots") print 3; else print $0}' > parameters

echo "10"

echo "# Collecting Variant Positions In VCFs"; sleep 2

#To keep track of sourcenames, processing is done separately 
awk 'NR==3 {print $1}' parameters | awk '{print "grep -v","\x22""#""\x22",$1,"| awk","\047""{print $1""\x22""_""\x22""$2}""\047", "> VC1"}' > first
awk 'NR==5 {print $1}' parameters | awk '{print "grep -v","\x22""#""\x22",$1,"| awk","\047""{print $1""\x22""_""\x22""$2}""\047", "> VC2"}' > second
awk 'NR==7 {print $1}' parameters | awk '{print "grep -v","\x22""#""\x22",$1,"| awk","\047""{print $1""\x22""_""\x22""$2}""\047", "> VC3"}' > third
awk 'NR==7 {print $1}' parameters | awk '{print "grep -v","\x22""#""\x22",$1,"> VC3body"}' > body
awk 'NR==7 {print $1}' parameters | awk '{print "grep","\x22""#""\x22",$1,"| awk","\047""{print $1""\x22""_""\x22""$2}""\047", "> vhead"}' > header 

printf '#!/bin/bash \n' > top
cat top header first second third body > Part1.sh
chmod +x Part1.sh
./Part1.sh 
rm top header first second third body

echo "40"

echo "# Counting Variants Unique In Each VCF"; sleep 2

awk 'FILENAME!=ARGV[3]{seen[$0]++;next} !seen[$0]++' VC1 VC2 VC3 | wc -l > VCF3UniqueCount #Give the unique in #3
awk 'FILENAME!=ARGV[3]{seen[$0]++;next} !seen[$0]++' VC1 VC3 VC2 | wc -l > VCF2UniqueCount  #Give the unque in #2
awk 'FILENAME!=ARGV[3]{seen[$0]++;next} !seen[$0]++' VC3 VC2 VC1 | wc -l > VCF1UniqueCount #Give the unique in #1

echo "60"

echo "# Counting Variants Common In Two Or More VCFs"; sleep 2
awk '{print $1}' VC1 VC2 VC3 | sort | uniq -c | awk '{if ($1==3){print $2" "$3}}' > ChPos_InAllThree
wc -l ChPos_InAllThree > CommonCount

awk ' FNR == 1 { b++ } { a[$0]++ } END { for (i in a) { if (a[i] == b) { print i } } } ' VC1 VC2 | awk 'FILENAME!=ARGV[2]{seen[$0]++;next} !seen[$0]++' VC3 - | wc -l > Unique_VCF1_VCF2_Count
awk ' FNR == 1 { b++ } { a[$0]++ } END { for (i in a) { if (a[i] == b) { print i } } } ' VC1 VC3 | awk 'FILENAME!=ARGV[2]{seen[$0]++;next} !seen[$0]++' VC2 - | wc -l > Unique_VCF1_VCF3_Count
awk ' FNR == 1 { b++ } { a[$0]++ } END { for (i in a) { if (a[i] == b) { print i } } } ' VC3 VC2 | awk 'FILENAME!=ARGV[2]{seen[$0]++;next} !seen[$0]++' VC1 - | wc -l > Unique_VCF2_VCF3_Count
echo "80"

echo "# Plotting Data"; sleep 2


#Collect plotting info as variables
echo "tmp" > tmp
a=$(wc -l VC1 | awk '{print $1}') #first number
b=$(wc -l VC2 | awk '{print $1}') #second number
c=$(wc -l VC3 | awk '{print $1}') #third number 
d=$(awk '{print $1}' CommonCount) #seventh number 
e=$(head -1 Unique_VCF1_VCF2_Count)
f=$(head -1 Unique_VCF2_VCF3_Count)
g=$(head -1 Unique_VCF1_VCF3_Count)
h=$(awk -v var1=$d -v var2=$e '{print var1+var2}' tmp) #the fourth number 
i=$(awk -v var1=$d -v var3=$f '{print var1+var3}' tmp) #the fifth number
j=$(awk -v var1=$d -v var4=$g '{print var1+var4}' tmp) #the sixth number
k=$(awk 'NR==2 {print $1}' parameters)
l=$(awk 'NR==4 {print $1}' parameters)
m=$(awk 'NR==6 {print $1}' parameters)
n=$(awk 'NR==13 {print $1}' parameters) 
o=$(awk 'NR==12 {print $1}' parameters) 
p=$(awk 'NR==9 {print $1}' parameters) #three colors 
q=$(awk 'NR==10 {print $1}' parameters)
r=$(awk 'NR==11 {print $1}' parameters)
s=$(awk 'NR==14 {print $1}' parameters)
t=$(awk 'NR==15 {print $1}' parameters)
u=$(awk 'NR==16 {print $1}' parameters)
v=$(awk 'NR==17 {print $1}' parameters)
w=$(awk 'NR==18 {print $1}' parameters)
x=$(awk 'NR==19 {print $1}' parameters)
y=$(awk 'NR==20 {print $1}' parameters)
z=$(date "+%Y%m%d_%H%M")
printf ''

printf 'library(ggplot2) \nlibrary(VennDiagram) \np <- draw.triple.venn(%s, %s, %s, %s, %s, %s, %s, c("%s", "%s", "%s"), sep.dist = 0.1, rotation.degree = %s, lty = %s, fill = c("%s", "%s", "%s"),  cex=%s, fontfamily="%s", fontface="%s", cat.cex=%s, cat.fontfamily = "%s", cat.fontface = "%s", rptation=1) \nggsave(plot = p, filename= "ThreeVCFVenn_%s.%s")' $a $b $c $h $i $j $d $k $l $m $n $o $p $q $r $s $t $u $v $w $x $z $y > venn.r
Rscript venn.r

echo "90"

echo "# Generating New VCF Containing Common Variants"; sleep 2

#Create a VCF of the common variants using VCF3 format (GATK by default)
awk '{print $1"_"$2, $0}' VC3body | awk 'NR==FNR{a[$1]=$1;next}{if (a[$1]) print $0}' ChPos_InAllThree - | cut -f 2- -d " " | cat vhead - > CommonAllThree.vcf

echo "95"

echo "# Generating Summary Table"; sleep 2
c=$(date "+%Y%m%d_%H%M")
a=$(awk 'NR==1 {print $1}' parameters)

printf 'SUMMARY OF VCF COMPARISON PERFORMED BY %s ON %s \n \n** See Log File For VCF Callers Used ** \n \n\n' $a $c > top
awk '{print "Number Variants Common In All VCFs:", $1}' CommonCount > one
awk '{print "Number Variants Unique In VCF1:", $1}' VCF1UniqueCount > two
awk '{print "Number Variants Unique In VCF2:", $1}' VCF2UniqueCount > three
awk '{print "Number Variants Unique In VCF3:", $1}' VCF3UniqueCount > four
awk '{print "Number Variants Common To VCF1 And VCF2 Only:", $1}' Unique_VCF1_VCF2_Count > five
awk '{print "Number Variants Common To VCF1 And VCF3 Only:", $1}' Unique_VCF1_VCF3_Count > six
awk '{print "Number Variants Common To VCF2 and VCF3 Only:", $1}' Unique_VCF2_VCF3_Count > seven

cat top one two three four five six seven > VCF_Compare_Summary_${c}.txt

echo "99"

echo "# Tidying"; sleep 2
rm ChPos_InAllThree CommonCount five four one Part1.sh Rplots.pdf seven six three tmp top two Unique_VCF1_VCF2_Count Unique_VCF1_VCF3_Count Unique_VCF2_VCF3_Count VC1 VC2 VC3 VC3body VCF1UniqueCount VCF2UniqueCount VCF3UniqueCount vhead yad1

echo "Script Finished $now. The logfile is named SASDt.log") | zenity --width 800 --title "PROGRESS" --progress --auto-close
now=$(date)
echo "Script Finished $now."

#Cleaning

printf 'Initials of person who ran the program: \nName of variant caller used to make VCF1: \n File and path of VCF1: \nName of variant caller used to make VCF2: \n File and path of VCF2: \nName of variant caller used to make VCF3: \n File and path of VCF3: \n \nColor chosen for VCF1 Venn circle: \nColor chosen for VCF2 Venn circle: \nColor chosen for VCF3 Venn circle: \nOutlines of Venn diagram: \nDiagram rotation in degrees: \nSize of values (numbers) in Venn circles: \nFont of numbers in Venn circles: \nStyle of numbers in Venn circles: \nSize of labels: \nFont of labels: \n Style of labels \nFormat to save plot:' > first
paste first parameters > second
 awk 'BEGIN{print "*****R code used to make the plot*****"}1' venn.r > v1
 c=$(date "+%Y%m%d_%H%M")
cat TVAt.log second v1 > TVA_${c}.log
rm TVAt.log venn.r parameters v1 first second

# END OF PROGRAM ######################################################################################
