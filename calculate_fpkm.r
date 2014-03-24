args <- commandArgs(TRUE)

##read in the table
rna_counts_tbl <- read.table(args[1],sep = "\t", col.names = c("V1","V2","V3","V4","V5","V6","V7","V8","gene_id","raw_read_count","gene_coverage","gene_length","percent_gene_covered")) 
rna_counts_tbl <- rna_counts_tbl[,-c(1,2,3,4,5,6,7,8)]

##FPKM=(# of fragments)/(length of transcript/1000)/(total reads/10^6)
total_reads <- sum(rna_counts_tbl$raw_read_count)

rna_counts_tbl$fpkm <- rna_counts_tbl$raw_read_count/(rna_counts_tbl$gene_length/1000)/(total_reads/1000000)

write.table(rna_counts_tbl, file=args[2], quote=F, sep="\t")

