#!/bin/bash

read_1=(MURI_*_R1_*.fastq)

rm -f ./paramlist_bowtie

for ((i=0;i<${#read_1[@]};i++)); do
	echo $i
	r1=${read_1[$i]}
        r2=${r1/R1/R2}    
	echo "bowtie_commands.sh $r1 $r2" >> paramlist_bowtie
done
