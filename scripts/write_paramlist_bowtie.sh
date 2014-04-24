#!/bin/bash

SRC_DIR=$HOME/Ecoli_RNAseq/scripts

all_read_files=($SCRATCH/data/sample*/RNA/*.processed/)
##look into processed directory 

rm -f $SCRATCH/data/paramlist_bowtie

for ((i=0;i<${#all_read_files[@]};i++)); do
	echo $i
	read_file=${all_read_files[$i]}    
	echo "$SRC_DIR/bowtie_commands.sh $read_file" >> $SCRATCH/data/paramlist_bowtie
done
