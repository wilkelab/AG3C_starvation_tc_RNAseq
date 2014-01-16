Ecoli_RNAseq
============

>adaptors.fna
Contains all adaptor sequences used for trimming by flexbar

>write_paramlist_bowtie.sh
writes paramlist_bowtie by finding all the MURI_*_R1_*.fastq within 
the directory and creating MURI_*_R1_*.fastq for given R1 file. 

>paramlist_bowtie
file with bowtie_commands.sh to be ran on reads1 and reads2. 
bowtie_launcher.sge executes paramlist_bowtie 

>bowtie_commands.sh
contains functions that carry out the analysis for reads1 and reads2 
for a sample

>bowtie_launcher.sge
launcher file used to submit a job on TACC to carry out bowtie_commands.sh

>reference_seqs
contains all generate reference sequences.
REL606.fa/.fai - original untampered fasta files with Ecoli DNA sequence
REL606_nc_tss_no_dupl.gtf - modified REL606.gtf file that contains 
non-coding RNAs and formatted tss column. There are also no 
duplicate entries present in this file (unlike REL606.gtf)
REL606_nc_tss_no_dupl_rRNAtRNA.gtf - modified 
REL606_nc_tss_no_dupl.gtf file with only tRNAs and rRNAs (needed by 
cuffdiff to weed out tRNAs and rRNAs)

>indexes
index files generated and used by bowtie2. It also contains original 
untampered REL606.fa. Bowtie2 requires a fasta file within this 
folder for proper functioning

>paramlist_cuffdiff
runs cuffdiff on given samples. 

>cuffdiff_launcher.sge
launcher file used to submit a job on TACC to carry out 
paramlist_cuffdiff
