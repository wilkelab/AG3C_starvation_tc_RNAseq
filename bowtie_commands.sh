#!/bin/sh
## $1 = input fastq file for read 1
## $2 = input fastq file for read 2

TEST="false"
TEST="true"

## Example base name: MURI-12_S7_L001
BASE_NAME=`echo $1 | grep -o "MURI_[0-9]\+_[AGCT]\+_L[0-9]\+"`
SAMPLE_DIR=`echo $1 | grep -o "MURI_[0-9]\+"`

echo "BASE_NAME: $BASE_NAME"
echo "SAMPLE_DIR: $SAMPLE_DIR"

if [ ! -d "$SAMPLE_DIR" ]; then
   mkdir $SAMPLE_DIR	
fi


if [ ! -d "$SAMPLE_DIR/raw_reads" ]; then
   mkdir raw_reads
fi 

mv $BASE_NAME*.fastq $SAMPLE_DIR/raw_reads/
cd $SAMPLE_DIR

#gunzip raw_reads/*

echo "flexbar -n 3 -t $BASE_NAME -r raw_reads/${BASE_NAME}_R1_001.fastq -p raw_reads/${BASE_NAME}_R2_001.fastq -f fastq -a $SCRATCH/adaptors.fna > ${BASE_NAME}_flexbar.out"
TEST="false"
if [[ ! $TEST = "true" ]]; then 
   flexbar -n 3 -t $BASE_NAME -r raw_reads/${BASE_NAME}_R1_001.fastq -p raw_reads/${BASE_NAME}_R2_001.fastq -f fastq -a $SCRATCH/adaptors.fna > ${BASE_NAME}_flexbar.out
fi

if [ ! -d "trimmed_reads" ]; then
   mkdir trimmed_reads
fi  

mv ${BASE_NAME}_1.fastq ${BASE_NAME}_2.fastq ./trimmed_reads

echo "bowtie2 -x $SCRATCH/indexes/REL606 -1 trimmed_reads/${BASE_NAME}_1.fastq -2 trimmed_reads/${BASE_NAME}_2.fastq -S ${BASE_NAME}_bowtie_out.sam 2> ${BASE_NAME}_align_reads.txt"
if [[ ! $TEST = "true" ]]; then 
   bowtie2 -x $SCRATCH/indexes/REL606 -1 trimmed_reads/${BASE_NAME}_1.fastq -2 trimmed_reads/${BASE_NAME}_2.fastq -S ${BASE_NAME}_bowtie_out.sam 2> ${BASE_NAME}_align_reads.txt
fi
TEST="true"

##Sort for cufflinks
echo "sort -k 3,3 -k 4,4n ${BASE_NAME}_bowtie_out.sam > ${BASE_NAME}_bowtie_out_sorted.sam"
if [[ ! $TEST = "true" ]]; then 
   sort -k 3,3 -k 4,4n ${BASE_NAME}_bowtie_out.sam > ${BASE_NAME}_bowtie_out_sorted.sam
fi 

echo "cufflinks -p 3 -o ${BASE_NAME}_nc_cufflinks_out -G $SCRATCH/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_bowtie_out_sorted.sam"
if [[ ! $TEST = "true" ]]; then 
   cufflinks -p 3 -o ${BASE_NAME}_nc_cufflinks_out -G $SCRATCH/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_bowtie_out_sorted.sam
fi

##looking for novel transcripts
echo "cufflinks -p 3 -o ${BASE_NAME}_novel_trans_cufflinks_out ${BASE_NAME}_bowtie_out_sorted.sam"
if [[ ! $TEST = "true" ]]; then 
   cufflinks -p 3 -o ${BASE_NAME}_novel_trans_cufflinks_out ${BASE_NAME}_bowtie_out_sorted.sam          
fi

echo "cuffcompare -o ${BASE_NAME}_nc_cuffcompare_out -r $SCRATCH/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_novel_trans_cufflinks_out/transcripts.gtf" 
if [[ ! $TEST = "true" ]]; then 
   cuffcompare -o ${BASE_NAME}_nc_cuffcompare_out -r $SCRATCH/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_novel_trans_cufflinks_out/transcripts.gtf
fi

echo "samtools view -bS ${BASE_NAME}_bowtie_out.sam > ${BASE_NAME}_bowtie_out.bam"
if [[ ! $TEST = "true" ]]; then 
   samtools view -bS ${BASE_NAME}_bowtie_out.sam > ${BASE_NAME}_bowtie_out.bam
fi

echo "samtools sort ${BASE_NAME}_bowtie_out.bam ${BASE_NAME}_bowtie_out_sorted"
if [[ ! $TEST = "true" ]]; then 
   samtools sort ${BASE_NAME}_bowtie_out.bam ${BASE_NAME}_bowtie_out_sorted
fi

echo "bedtools coverage -abam ${BASE_NAME}_bowtie_out_sorted.bam -b $SCRATCH/REL606_nc_tss_no_dupl.gtf > ${BASE_NAME}_bedtools_coverage_out.txt"
if [[ ! $TEST = "true" ]]; then 
   bedtools coverage -abam ${BASE_NAME}_bowtie_out_sorted.bam -b $SCRATCH/REL606_nc_tss_no_dupl.gtf > ${BASE_NAME}_bedtools_coverage_out.txt
fi
