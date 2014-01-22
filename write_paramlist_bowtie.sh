#!/bin/bash

SRC_DIR=$HOME/Ecoli_RNAseq

read_1=($SCRATCH/data/raw_reads/MURI_*_R1_*.fastq)

rm -f $SCRATCH/data/paramlist_bowtie

for ((i=0;i<${#read_1[@]};i++)); do
	echo $i
	r1=${read_1[$i]}
        r2=${r1/R1/R2}    
	echo "$SRC_DIR/bowtie_commands.sh $r1 $r2" >> $SCRATCH/data/paramlist_bowtie
done
