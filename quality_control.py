import sys, re 


def read_flexbar(file):	
	##read flexbar and bowtie output files
	flexbar_file = open(file,"r")

	##get number of reads trimmed and discarded from flexbar
	flexbar_file_lst = flexbar_file.readlines()

	for line in flexbar_file_lst:
		m = re.match( r'Discarded short reads:\s+(\d+)', line )
		if m:
			reads_discarded = int( m.group(1) )
			break # just record the first one

	for line in flexbar_file_lst:        
			m = re.match( r'Reads written to file:\s+(\d+)', line )
			if m:
					reads_trimmed = int( m.group(1) )
					break # just record the first one

	total_reads = reads_trimmed+reads_discarded
	percent_reads_remaining = reads_trimmed/float(total_reads)*100.0
	flexbar_file.close()

	return(total_reads, percent_reads_remaining, reads_trimmed)

def read_bowtie(file,reads_trimmed):
	bowtie_file = open(file,"r")

	##get number of mapped and unmapped reads
	bowtie_file_lst = bowtie_file.readlines()

	for line in bowtie_file_lst:
		m = re.match( r'(\d+)\s+reads; of these:', line)
		if m: 
			total_reads_for_mapping = int( m.group(1) )
			break 

	for line in bowtie_file_lst:
		m = re.match( r'(\d+\.\d+)\%\s+overall alignment rate', line)
		if m:
			percent_mapped_reads = float( m.group(1) )
			break

	if (reads_trimmed != total_reads_for_mapping):
		print("Warning: reads trimmed and written by flexbar does not equal the total number of reads processed by bowtie")

	reads_mapped = percent_mapped_reads/100.0*total_reads_for_mapping
	bowtie_file.close()

	return(reads_mapped, percent_mapped_reads)

def count_bases_from_raw(file):
	reads_file = open(file,"r")
	count = 0
	i = 0
	for line in reads_file.readlines():
		m = re.match( r'^([AGCTN]+)$', line.strip())
		if m: 
			count += len(m.group(1))
			i += 1
	print i, count

	

def main():
	(total_reads, percent_reads_remaining, reads_trimmed) = read_flexbar(sys.argv[1])
	(reads_mapped, percent_mapped_reads) = read_bowtie(sys.argv[2],reads_trimmed)

	##make output file
	outFile = open("test.txt","w")

	##write number of reads trimmed and discarded from flexbar
	outFile.write("sample\ttime\ttotal_read_count\ttotal_base_count\ttrimmed_read_count\tpercent_reads_remaining\ttrimmed_base_count\tmapped_read_count\tpercent_trimmed_reads_mapped\tpercent_mapping_rRNA\tpercent_mapping_tRNA\tpercent_mapping_mRNA\tcount_mapping_to_mRNA\n")
	row = "%s\ttime\t%i\ttotal_base_count\t%i\t%.4g\ttrimmed_base_count\t%i\t%.4g\n" % (sys.argv[1][:7], 
	total_reads, 
	reads_trimmed, percent_reads_remaining, reads_mapped, percent_mapped_reads )
	outFile.write(row)
	outFile.close()

#main()

count_bases_from_raw("MURI_16/raw_reads/MURI_16_AGTTCC_L007_R1_001.fastq")