#!/bin/bash

SRC_DIR=$HOME/Ecoli_RNAseq/src
TIME_COURSE_DIR=glucose_time_course

all_read_files=($SCRATCH/data/${TIME_COURSE_DIR}/sample*/RNA/*.processed/)
##look into processed directory 

rm -f $SCRATCH/data/paramlist_bowtie_${TIME_COURSE_DIR}

for ((i=0;i<${#all_read_files[@]};i++)); do
	echo $i
	read_file=${all_read_files[$i]}    
	echo "$SRC_DIR/bowtie_commands.sh $read_file" >> $SCRATCH/data/paramlist_bowtie_${TIME_COURSE_DIR}
done
