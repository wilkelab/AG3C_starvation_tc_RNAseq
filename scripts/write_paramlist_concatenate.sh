#!/bin/bash

SRC_DIR=$HOME/Ecoli_RNAseq/scripts

all_read_files=($SCRATCH/data/sample*/RNA/*.raw/)
##look into processed directory 

rm -f $SCRATCH/data/paramlist_concatenate

for ((i=0;i<${#all_read_files[@]};i++)); do
	echo $i
	read_file=${all_read_files[$i]}    
	echo "cd $read_file" >> $SCRATCH/data/paramlist_concatenate
	echo "python $SRC_DIR/concatenate_reads.py $read_file" >> $SCRATCH/data/paramlist_concatenate
done
