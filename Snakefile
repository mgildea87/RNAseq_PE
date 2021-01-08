import pandas as pd
import os

for directory in ['fastqc', 'trim', 'logs', 'logs/slurm_reports', 'logs/trim_reports', 'alignment', 'logs/alignment_reports', 'feature_counts']:
	if not os.path.isdir(directory):
		os.mkdir(directory)

configfile: "config.yaml"
sample_file = config["sample_file"]
GTF = config["GTF"]
sample = pd.read_table(sample_file)['Sample']
replicate = pd.read_table(sample_file)['Replicate']
condition = pd.read_table(sample_file)['Condition']
File_R1 = pd.read_table(sample_file)['File_Name_R1']
File_R2 = pd.read_table(sample_file)['File_Name_R2']
File_names = File_R1.append(File_R2)
genome = config["genome"]

sample_ids = []
for i in range(len(sample)):
	sample_ids.append('%s_%s_%s' % (sample[i], condition[i], replicate[i]))

read = ['_R1', '_R2']


rule all:
	input:
		'feature_counts/count_table.txt',
		expand('fastqc/{sample}{read}_fastqc.html', sample = sample_ids, read = read)

rule fastqc:
	input: 
		fastq = "fastq/{sample}{read}.fastq.gz"
	output:  
		"fastqc/{sample}{read}_fastqc.html",
		"fastqc/{sample}{read}_fastqc.zip"
	params:
		'fastqc/'
	shell: 
		'fastqc {input.fastq} -o {params}'

rule trim:
	input:
		R1='fastq/{sample}_R1.fastq.gz',
		R2='fastq/{sample}_R2.fastq.gz'
	output:
		R1='trim/{sample}_trimmed_R1.fastq.gz',
		R2='trim/{sample}_trimmed_R2.fastq.gz',
		html='logs/trim_reports/{sample}.html',
		json='logs/trim_reports/{sample}.json'
	threads: 4
	log:
		'logs/trim_reports/{sample}.log'
	params:
		'--adapter_sequence CTGTCTCTTATACACATCT --adapter_sequence_r2 CTGTCTCTTATACACATCT'
	shell:
		'fastp -w {threads} {params} -i {input.R1} -I {input.R2} -o {output.R1} -O {output.R2} --html {output.html} --json {output.json} 2> {log}'

rule align:
	input:
		R1='trim/{sample}_trimmed_R1.fastq.gz',
		R2='trim/{sample}_trimmed_R2.fastq.gz'
	output:
		bam = 'alignment/{sample}.bam'
	threads: 10
	log:
#		'logs/alignment_reports/{sample}.log'
	params:
		'--readFilesCommand zcat --outStd BAM_SortedByCoordinate --outSAMtype BAM SortedByCoordinate --outSAMprimaryFlag AllBestScore --alignMatesGapMax 1000000 --outFilterMismatchNmax 999 --alignIntronMax 1000000' 
		'--alignSplicedMateMapLmin 3 --alignSJoverhangMin 8 --alignSJDBoverhangMin 3 --outFilterMismatchNoverReadLmax 0.04 --outSAMunmapped Within KeepPairs --outSAMattributes All --alignIntronMin 20'
#		 --outFilterMultimapNmax 1
	shell:
		'STAR {params} --genomeDir %s --runThreadN {threads} --readFilesIn {input.R1} {input.R2} --outFileNamePrefix alignment/{wildcards.sample}_ | samtools view -bh > alignment/{wildcards.sample}.bam' % (genome)
		# removed -q 5 from samtools view (filters out multimappers)
rule count:
	input:
		bam = expand('alignment/{sample}.bam', sample = sample_ids)
	output:
		counts = 'feature_counts/count_table.txt'
	threads: 20
	params:
		'-p -g gene_id -s 2 -M'
	shell:
		'featureCounts {params} -T {threads} -a %s -o {output.counts} {input.bam}' % (GTF)