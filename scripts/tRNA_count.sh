READS_1=`echo ${1}*R1.fastq | grep -o "MURI_[0-9]\+_[a-zA-Z0-9_+]*_R1"`
SAMPLE_DIR=$1

cd $SAMPLE_DIR

python $HOME/Ecoli_RNAseq/scripts/trna_fraction.py $HOME/Ecoli_RNAseq/reference_seqs/final_reference_seqs/REL606_nc_tss_no_dupl.gtf ${READS_1}_raw_rna_count.txt ${READS_1}_trna_norm_counts.txt