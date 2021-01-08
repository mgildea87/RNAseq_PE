import pandas as pd
import os, sys

sample_file = "samples_info.tab"
sample = pd.read_table(sample_file)['Sample']
replicate = pd.read_table(sample_file)['Replicate']
condition = pd.read_table(sample_file)['Condition']
File_R1 = pd.read_table(sample_file)['File_Name_R1']
File_R2 = pd.read_table(sample_file)['File_Name_R2']

for i in range(len(File_R1)):
	if os.path.exists('fastq/%s' % (File_R1[i])):
		os.system('mv fastq/%s fastq/%s_%s_%s_R1.fastq.gz' % (File_R1[i],sample[i],condition[i],replicate[i]))
	elif os.path.exists('fastq/%s_%s_%s_R1.fastq.gz' % (sample[i],condition[i],replicate[i])) == False:
		print('fastq/%s and fastq/%s_%s_%s_R1.fastq.gz do not exist!' % (File_R1[i], sample[i],condition[i],replicate[i]))
		sys.exit(1)

for i in range(len(File_R2)):
	if os.path.exists('fastq/%s' % (File_R2[i])):
		os.system('mv fastq/%s fastq/%s_%s_%s_R2.fastq.gz' % (File_R2[i],sample[i],condition[i],replicate[i]))
	elif os.path.exists('fastq/%s_%s_%s_R2.fastq.gz' % (sample[i],condition[i],replicate[i])) == False:
		print('fastq/%s and fastq/%s_%s_%s_R2.fastq.gz do not exist!' % (File_R2[i], sample[i],condition[i],replicate[i]))
		sys.exit(1)