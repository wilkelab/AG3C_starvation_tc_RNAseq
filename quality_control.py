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

def count_bases(file):
	reads_file = open(file,"r")
	count = 0
	i = 0
	for line in reads_file.readlines():
		m = re.match( r'^([AGCTN]+)$', line.strip())
		if m: 
			count += len(m.group(1))
			i += 1

	return(i,count)

def count_rna_type(file,reads_mapped):
	count_rna_file = open(file,"r")
	
	count_mRNA = 0
	count_tRNA = 0
	count_rRNA = 0

	for line in count_rna_file.readlines():
		m = re.match(r'.+oId \"ECB\_([\drt])\d+.+',line)
		if m:
			m2 = re.match(r'.*\s(\d+)\s\d+\s\d+\s[\d\.]+$',line)
			if re.match(r'\d',m.group(1)):
				count_mRNA += int(m2.group(1))
			elif m.group(1) == "t":
				count_tRNA += int(m2.group(1))
			elif m.group(1) == "r": 
				count_rRNA += int(m2.group(1))
					
	percent_mRNA = count_mRNA/float(reads_mapped)*100
	percent_tRNA = count_tRNA/float(reads_mapped)*100
	percent_rRNA = count_rRNA/float(reads_mapped)*100				
	return (count_mRNA, percent_mRNA, percent_tRNA, percent_rRNA)	
	
def main():
	(total_reads_flexbar, percent_reads_remaining, reads_trimmed) = read_flexbar(sys.argv[1])
	(reads_mapped, percent_mapped_reads) = read_bowtie(sys.argv[2],reads_trimmed)
	(total_reads_raw_fastq, base_count_raw) = count_bases(sys.argv[3])
	(total_reads_trimmed_fastq, base_count_trimmed) = count_bases(sys.argv[4])
	(count_mRNA, percent_mRNA, percent_tRNA, percent_rRNA) = count_rna_type(sys.argv[5],reads_mapped)	 
	##make output file
	outFile = open("test.txt","w")

	m = re.match(r'^\S+(MURI_\d+)\S+',sys.argv[1])
	if m:
		sample = m.group(1)
		
	##write number of reads trimmed and discarded from flexbar
	outFile.write("sample\ttime\ttotal_read_count\ttotal_base_count\ttrimmed_read_count\tpercent_reads_remaining\ttrimmed_base_count\tmapped_read_count\tpercent_trimmed_reads_mapped\tcount_mapping_mRNA\tpercent_mapping_mRNA\tpercent_mapping_tRNA\tpercent_mapping_to_rRNA\n")
	row = "%s\ttime\t%i\t%i\t%i\t%.4g\t%i\t%i\t%.4g\t%i\t%.4g\t%.4g\t%.4g\n" % (sample, total_reads_flexbar, base_count_raw, reads_trimmed, percent_reads_remaining, base_count_trimmed, reads_mapped, percent_mapped_reads, count_mRNA, percent_mRNA, percent_tRNA, percent_rRNA )
	outFile.write(row)
	outFile.close()

main()

