#!/bin/sh

# location of data files to be tarred
DATA_DIR=/scratch/02159/ds29583/data/glucose_time_course

# samples to process
SAMPLES=(sample16 sample17 sample18 sample19 sample20 sample21 sample22 sample23 sample24 sample25 sample26 sample27 sample28 sample29 sample30 sample31 sample32 sample33 sample97 sample98 sample99 sample100 sample101 sample102 sample103 sample104 sample105)
#SAMPLES=(sample16 sample17)

# location of the tar file to be created
DEST_DIR=/scratch/02159/ds29583/data/glucose_time_course

# name of the tar file to be created
TAR_NAME=glucose_RNA_processed.tgz

### make no changes below this line

FILELIST=${DEST_DIR}/${TAR_NAME}.filelist
rm -f $FILELIST

cd $DATA_DIR
for SAMPLE in ${SAMPLES[@]}; do
	gzip ${SAMPLE}/RNA/*.processed/*_aligned_sorted.sam
	gzip ${SAMPLE}/RNA/*.processed/*_R1_R2_aligned.sam
	ls -1 ${SAMPLE}/RNA/*.processed/*_aligned_sorted.sam.gz >> $FILELIST
	ls -1 ${SAMPLE}/RNA/*.processed/*_R1_R2_aligned.sam.gz >> $FILELIST
	ls -1 ${SAMPLE}/RNA/*.processed/*.out >> $FILELIST
	ls -1 ${SAMPLE}/RNA/*.processed/*.log >> $FILELIST
	ls -1 ${SAMPLE}/RNA/*.processed/*.txt >> $FILELIST
done

tar cvfz $DEST_DIR/$TAR_NAME --files-from=${FILELIST}

md5sum $DEST_DIR/$TAR_NAME > $DEST_DIR/$TAR_NAME.md5sum

rm -f $FILELIST