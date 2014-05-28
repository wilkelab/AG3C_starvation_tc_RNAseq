#!/bin/bash

SRC_DIR=$HOME/Ecoli_RNAseq/scripts

all_read_files=($SCRATCH/data/sample*/RNA/*.processed/)
##look into processed directory 

rm -f $SCRATCH/data/paramlist_tRNA_count

for ((i=0;i<${#all_read_files[@]};i++)); do
	echo $i
	read_file=${all_read_files[$i]}    
	echo "$SRC_DIR/tRNA_count.sh $read_file" >> $SCRATCH/data/paramlist_tRNA_count
done
