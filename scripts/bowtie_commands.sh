#!/bin/sh
## $1 = input fastq file for read 1
## $2 = input fastq file for read 2

TEST="false"
TEST="true"

## Example base name: MURI-12_S7_L001
BASE_NAME=`echo $1 | grep -o "MURI_[0-9]\+_SA[0-9]\+_[AGCT]\+_L[0-9]\+"`
SAMPLE_DIR=`echo $1 | grep -o "MURI_[0-9]\+"`

echo "BASE_NAME: $BASE_NAME"
echo "SAMPLE_DIR: $SAMPLE_DIR"

##create sample directory in data/
if [ ! -d "$SAMPLE_DIR" ]; then
   mkdir $SAMPLE_DIR	
fi

##unzip raw reads if zipped
if [ -a "raw_reads/${BASE_NAME}*fastq.gz" ]; then
	gunzip raw_reads/${BASE_NAME}*fastq.gz
fi 

cd $SAMPLE_DIR

##trim adaptors on raw reads and moved trimmed reads to trimmed_reads
echo "flexbar -n 3 -t $BASE_NAME -r $SCRATCH/data/raw_reads/unanalyzed/${BASE_NAME}_R1_001.fastq -p $SCRATCH/data/raw_reads/unanalyzed/${BASE_NAME}_R2_001.fastq -f fastq -a $HOME/Ecoli_RNAseq/reference_seqs/adaptors.fna > ${BASE_NAME}_flexbar.out"
if [[ ! $TEST = "true" ]]; then 
   flexbar -n 3 -t $BASE_NAME -r $SCRATCH/data/raw_reads/unanalyzed/${BASE_NAME}_R1_001.fastq -p $SCRATCH/data/raw_reads/unanalyzed/${BASE_NAME}_R2_001.fastq -f fastq -a $HOME/Ecoli_RNAseq/reference_seqs/adaptors.fna > ${BASE_NAME}_flexbar.out
fi

if [ ! -d "trimmed_reads" ]; then
   mkdir trimmed_reads
fi  

if [ -a "${BASE_NAME}_1.fastq" ]; then
	mv ${BASE_NAME}_1.fastq ${BASE_NAME}_2.fastq ./trimmed_reads
fi

##map trimmed reads to reference sequence in indexes file. 
##Index files were made with:
##bowtie2-build final_reference_seqs/REL606.fa indexes/REL606 
#align both reads together 2
echo "bowtie2 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -1 trimmed_reads/${BASE_NAME}_1.fastq -2 trimmed_reads/${BASE_NAME}_2.fastq -S ${BASE_NAME}_bowtie_out.sam 2> ${BASE_NAME}_bowtie_out.txt"
if [[ ! $TEST = "true" ]]; then 
   bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -1 trimmed_reads/${BASE_NAME}_1.fastq -2 trimmed_reads/${BASE_NAME}_2.fastq -S ${BASE_NAME}_bowtie_out_all.sam 2> ${BASE_NAME}_bowtie_out.txt
fi

#align reads 1 separately
echo "bowtie2 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U trimmed_reads/${BASE_NAME}_1.fastq -S ${BASE_NAME}_bowtie_out_r1.sam 2> ${BASE_NAME}_bowtie_out_r1.txt"
if [[ ! $TEST = "true" ]]; then 
   bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U trimmed_reads/${BASE_NAME}_1.fastq -S ${BASE_NAME}_bowtie_out_r1.sam 2> ${BASE_NAME}_bowtie_out_r1.txt
fi

#align reads 2 separately
echo "bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U trimmed_reads/${BASE_NAME}_2.fastq -S ${BASE_NAME}_bowtie_out_r2.sam 2> ${BASE_NAME}_bowtie_out_r2.txt"
if [[ ! $TEST = "true" ]]; then 
   bowtie2 -k 1 -q -x $HOME/Ecoli_RNAseq/reference_seqs/indexes/REL606 -U trimmed_reads/${BASE_NAME}_2.fastq -S ${BASE_NAME}_bowtie_out_r2.sam 2> ${BASE_NAME}_bowtie_out_r2.txt
fi

##Sort bowtie output file for cufflinks
echo "sort -k 3,3 -k 4,4n ${BASE_NAME}_bowtie_out.sam > ${BASE_NAME}_bowtie_out_r1_sorted.sam"
if [[ ! $TEST = "true" ]]; then 
   sort -k 3,3 -k 4,4n ${BASE_NAME}_bowtie_out_r1.sam > ${BASE_NAME}_bowtie_out_r1_sorted.sam
fi 

##calculate FPKMs using sorted bowtie output
echo "cufflinks -p 3 -o ${BASE_NAME}_nc_cufflinks_out -G $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_bowtie_out_sorted.sam"
if [[ ! $TEST = "true" ]]; then 
   cufflinks -p 3 -o ${BASE_NAME}_nc_cufflinks_out -G $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_bowtie_out_sorted.sam
fi

##look for novel transcripts
#make novel reference GTF file from reads mapped
echo "cufflinks -p 3 -o ${BASE_NAME}_novel_trans_cufflinks_out ${BASE_NAME}_bowtie_out_sorted.sam"
if [[ ! $TEST = "true" ]]; then 
   cufflinks -p 3 -o ${BASE_NAME}_novel_trans_cufflinks_out ${BASE_NAME}_bowtie_out_sorted.sam          
fi

#compare novel reference GTF to the original GTF file
echo "cuffcompare -o ${BASE_NAME}_nc_cuffcompare_out -r $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_novel_trans_cufflinks_out/transcripts.gtf" 
if [[ ! $TEST = "true" ]]; then 
   cuffcompare -o ${BASE_NAME}_nc_cuffcompare_out -r $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_novel_trans_cufflinks_out/transcripts.gtf
fi

##convert bowtie output .sam to .bam
echo "samtools view -bS ${BASE_NAME}_bowtie_out_r1.sam > ${BASE_NAME}_bowtie_out_r1.bam"
if [[ ! $TEST = "true" ]]; then 
   samtools view -bS ${BASE_NAME}_bowtie_out_r1.sam > ${BASE_NAME}_bowtie_out_r1.bam
fi

##sort .bam file
echo "samtools sort ${BASE_NAME}_bowtie_out_r1.bam ${BASE_NAME}_bowtie_out_r1_sorted"
if [[ ! $TEST = "true" ]]; then 
   samtools sort ${BASE_NAME}_bowtie_out_r1.bam ${BASE_NAME}_bowtie_out_r1_sorted
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
echo "python $HOME/Ecoli_RNAseq/calculate_norm_fpkm.py $HOME/Ecoli_RNAseq/reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_htseq_count_r1_k.txt"
if [[ ! $TEST = "true" ]]; then
	python $HOME/Ecoli_RNAseq/calculate_norm_fpkm.py $HOME/Ecoli_RNAseq/reference_seqs/REL606_nc_tss_no_dupl.gtf ${BASE_NAME}_htseq_count_r1_k.txt
fi	