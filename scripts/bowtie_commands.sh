#!/bin/sh
## $1 = input directory *depleted.processed

##this script runs in sample*/RNA/*depleted.processed
TEST="false"
TEST="true"

READS_1=`echo ${1}* | grep -o "MURI_[0-9]\+_[a-zA-Z0-9_+]*_R1"`
READS_2=`echo ${1}* | grep -o "MURI_[0-9]\+_[a-zA-Z0-9_+]*_R2"`
SAMPLE_DIR=$1

echo "READS_1: $READS_1"
echo "READS_2: $READS_2"
echo "SAMPLE_DIR: $SAMPLE_DIR"

cd $SAMPLE_DIR

##unzip processed reads if zipped
if [ -a "${READS_1}*.fastq.gz" ]; then
	gunzip ${READS_1}*.fastq.gz
	gunzip ${READS_2}*.fastq.gz
fi 

TEST="false"
##trim adaptors on raw reads and moved trimmed reads to trimmed_reads
echo "flexbar -n 3 -t ${READS_1}_trimmed -r ${READS_1}.fastq -f fastq -a $HOME/Ecoli_RNAseq/reference_seqs/adaptors.fna > ${READS_1}_flexbar.out"
if [[ ! $TEST = "true" ]]; then 
	flexbar -n 3 -t ${READS_1}_trimmed -r ${READS_1}.fastq -f fastq -a $HOME/Ecoli_RNAseq/reference_seqs/adaptors.fna > ${READS_1}_flexbar.out
fi

echo "flexbar -n 3 -t ${READS_2}_trimmed -r ${READS_2}.fastq -f fastq -a $HOME/Ecoli_RNAseq/reference_seqs/adaptors.fna > ${READS_2}_flexbar.out"
if [[ ! $TEST = "true" ]]; then 
	flexbar -n 3 -t ${READS_2}_trimmed -r ${READS_2}.fastq -f fastq -a $HOME/Ecoli_RNAseq/reference_seqs/adaptors.fna > ${READS_2}_flexbar.out
fi
TEST="true"

##map trimmed reads to reference sequence in indexes file. 
##Index files were made with:
##bowtie2-build final_reference_seqs/REL606.fa indexes/REL606 
#align both reads together 2
echo "bowtie2 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -1 ${READS_1}_trimmed.fastq -2 trimmed_reads/${READS_2}_trimmed.fastq -S ${READS_1}_R2_aligned.sam 2> ${BASE_NAME}_R2_bowtie.out"
if [[ ! $TEST = "true" ]]; then 
   bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -1 ${READS_1}_trimmed.fastq -2 trimmed_reads/${READS_2}_trimmed.fastq -S ${READS_1}_R2_aligned.sam 2> ${BASE_NAME}_R2_bowtie.out
fi

#align reads 1 separately
echo "bowtie2 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U ${READS_1}_trimmed.fastq -S ${READS_1}_aligned.sam 2> ${READS_1}_bowtie.out"
if [[ ! $TEST = "true" ]]; then 
   bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U ${READS_1}_trimmed.fastq -S ${READS_1}_aligned.sam 2> ${READS_1}_bowtie.out
fi

#align reads 2 separately
echo "bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U ${READS_2}_trimmed.fastq -S ${READS_2}_aligned.sam 2> ${READS_2}_bowtie.out"
if [[ ! $TEST = "true" ]]; then 
   bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U ${READS_2}_trimmed.fastq -S ${READS_2}_aligned.sam 2> ${READS_2}_bowtie.out
fi

##convert bowtie output .sam to .bam
#echo "samtools view -bS ${READS_1}_aligned.sam > ${READS_1}_aligned.bam"
#if [[ ! $TEST = "true" ]]; then 
#   samtools view -bS ${READS_1}_aligned.sam > ${READS_1}_aligned.bam
#fi

##convert bowtie output .sam to .bam
#echo "samtools view -bS ${READS_2}_aligned.sam > ${READS_2}_aligned.bam"
#if [[ ! $TEST = "true" ]]; then 
#   samtools view -bS ${READS_2}_aligned.sam > ${READS_2}_aligned.bam
#fi

echo "sort -k 3,3 -k 4,4n ${READS_1}_aligned.sam > ${READS_1}_bowtie_out_r1_sorted.sam"
if [[ ! $TEST = "true" ]]; then 
   sort -k 3,3 -k 4,4n ${READS_1}_aligned.sam > ${READS_1}_bowtie_out_r1_sorted.sam
fi 

##get raw counts for reads mapped
#echo "bedtools coverage -s -abam ${BASE_NAME}_bowtie_out_r1_sorted.bam -b $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf > ${BASE_NAME}_bedtools_coverage_r1_out.txt"
#if [[ ! $TEST = "true" ]]; then 
#   bedtools coverage -s -abam ${BASE_NAME}_bowtie_out_r1_sorted.bam -b $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf > ${BASE_NAME}_bedtools_coverage_r1_out.txt
#fi

##get raw counts for reads mapped
echo "htseq-count -m union -t exon -i nearest_ref ${BASE_NAME}_bowtie_out_r1_sorted.sam $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf > ${BASE_NAME}_htseq_count_r1.txt"
if [[ ! $TEST = "true" ]]; then
	htseq-count -m union -t exon -i nearest_ref ${BASE_NAME}_bowtie_out_r1_sorted.sam $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf > ${BASE_NAME}_htseq_count_r1.txt
fi

##quality control 
echo "python $HOME/Ecoli_RNAseq/quality_control.py ${BASE_NAME}_flexbar.out ${BASE_NAME}_bowtie_out.txt ${BASE_NAME}_bowtie_out_r1.txt ${BASE_NAME}_bowtie_out_r2.txt $SCRATCH/data/raw_reads/unanalyzed/${BASE_NAME}_R1.fastq trimmed_reads/${BASE_NAME}_1.fastq ${BASE_NAME}_htseq_count_r1.txt"
if [[ ! $TEST = "true" ]]; then
	python $HOME/Ecoli_RNAseq/quality_control.py ${BASE_NAME}_flexbar.out ${BASE_NAME}_bowtie_out.txt ${BASE_NAME}_bowtie_out_r1.txt ${BASE_NAME}_bowtie_out_r2.txt $SCRATCH/data/raw_reads/unanalyzed/${BASE_NAME}_R1_001.fastq trimmed_reads/${BASE_NAME}_1.fastq ${BASE_NAME}_htseq_count_r1.txt
fi 

##normalization 
echo "python $HOME/Ecoli_RNAseq/scripts/calculate_norm_fpkm.py $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_htseq_count_r1.txt"
if [[ ! $TEST = "true" ]]; then
	python $HOME/Ecoli_RNAseq/scripts/calculate_norm_fpkm.py $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_htseq_count_r1.txt
fi	