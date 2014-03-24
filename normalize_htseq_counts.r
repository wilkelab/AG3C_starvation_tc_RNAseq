args <- commandArgs(TRUE)

##read in the table from htseq output file
rna_counts_tbl <- read.table(args[1],sep = "\t", col.names = c("gene_id","raw_count")) 
rna_counts_tbl <- rna_counts_tbl[c(-(length(rna_counts_tbl$raw_count)),-(length(rna_counts_tbl$raw_count)-1),-(length(rna_counts_tbl$raw_count)-2),-(length(rna_counts_tbl$raw_count)-3),-(length(rna_counts_tbl$raw_count)-4)),]

##get rid of last four rows stats of htseq output
rna_counts_tbl <- rna_counts_tbl[c(-(length(rna_counts_tbl$raw_count)),-(length(rna_counts_tbl$raw_count)-1),-(length(rna_counts_tbl$raw_count)-2),-(length(rna_counts_tbl$raw_count)-3),-(length(rna_counts_tbl$raw_count)-4)),]
 
rna_counts_sum <- sum(rna_counts_tbl$raw_count)

rna_counts_normalized <- rna_counts_tbl$raw_count/rna_counts_sum
rna_counts_tbl$normalized_counts <- rna_counts_normalized

write.table(rna_counts_tbl, file=args[2], quote=F, sep="\t")

