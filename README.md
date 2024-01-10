# ThreeVCF_Analysis_TVA-GUI
This is a bash GUI tool that compares three VCF files, each produced by a different caller.  The tool provides a count of variants unique to each caller, those common to two of three callers and those common to all three callers.  

RATIONALE:  A variety of programs exist for calling variants from short-read DNA sequence data. It is sometimes advantageous to call variants with more than one tool with the idea that variants found by more than one tool are higher confidence.  When taking this approach, I typically use three callers and prioritize downstream evaluation of variants identified by all three. 

HISTORY: This tool was originally built to evaluate three VCFs created using BCFtools mpileup, FreeBayes, GATK HaplotypeCaller where each VCF was previously filtered and annotated using either the Mutation Finder Annotator (MFA) tool or the VCF Subset and Annotator (VSA) tool.  

NOTE: This program should work with VCFs created using different callers, but this has not been tested. 

INPUTS: Unzipped VCF files.

PARAMETERS:
1. User initials (for log file)
2. VCF files choice
3. Venn diagram labels for VCF files
4. Color of Venn circles
5. Outline style for Venn circles
6. Rotation of Venn diagram
7. Size of Venn numbers
8. Font of Venn numbers
9. Style of Venn numbers
10. Size of Venn labels
11. Font of Venn labels
12. Style of Venn labels
13. Format to save plot

OUTPUTS: 1. A new VCF that contains variants common to all three tools (in GATK format when defaults are used). 2. A table report of variant counts. 3. A Venn diagram of variant counts. 4. A log file that contains the R code used to make the diagram.  

CAUTION: Paths to VCF files should not contain spaces or the symbols / or $.  For example, it is okay if your VCFs are on an external USB drive named My_Drive, but if your drive is named My Drive, /MyDrive, etc., the program may not find your files. 

This tool performs analysis based on postion of variant call, not the call itself. Future versions can be made to be more sophisticated in terms of variant call and number of input VCFs if needed.  

DEPENDENCIES:  Bash, zenity, yad, grep, awk, R, ggplot2(R), VennDiagram(R), svglite(R)

EXAMPLE DATA: Three short VCFs and example ouputs can be found in the directory TVA_Example_Data.  

TO RUN: Download the .sh file and give permissions to run using chmod +x. Launch in a terminal window using ./ A graphical window will appear with information. Click OK to start. When prompted, enter the name for your analysis directory. A new directory will be created and the files created will be deposited in the directory. Follow the prompts to select files, choose plotting parameters, and to start the program. 

This program was built and tested on Linux Ubuntu 20.04 LTS. The program should work on macOS and Windows (with Linux bash shell installed). See https://github.com/bjtill/Copy-Number-Variant-Finder-GUI for more detials, including installing R and R packages.  
