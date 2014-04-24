#!/bin/sh

reads=($SCRATCH/data/raw_reads/unanalyzed/MURI_*.fastq)

for ((i=0;i<${#reads[@]};i++)); do
	echo $i
	read_file=${reads[$i]}
	SAMPLE_NUM=`echo $read_file | grep -o "MURI_[0-9]\+" | grep -o "[0-9]\+"`  
	
	echo "SAMPLE_NUM: $SAMPLE_NUM"
	echo "read_file: $read_file"
	
	if [[ $read_file == *ND* ]]; then
		echo "ND"
		echo "mkdir $SCRATCH/data/sample${SAMPLE_NUM}/RNA/non_depleted.raw/"
		echo "mv $read_file $SCRATCH/data/sample${SAMPLE_NUM}/RNA/non_depleted.raw/"
		mkdir $SCRATCH/data/sample${SAMPLE_NUM}/RNA/non_depleted.raw/
		mv $read_file $SCRATCH/data/sample${SAMPLE_NUM}/RNA/non_depleted.raw/
	else
		echo "mkdir $SCRATCH/data/sample${SAMPLE_NUM}/RNA/depleted.raw/"
		echo "mv $read_file $SCRATCH/data/sample${SAMPLE_NUM}/RNA/depleted.raw/"
		mkdir $SCRATCH/data/sample${SAMPLE_NUM}/RNA/depleted.raw/
		mv $read_file $SCRATCH/data/sample${SAMPLE_NUM}/RNA/depleted.raw/
	fi	
	
done

