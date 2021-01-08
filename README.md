# RNAseq_PE
This readme describes how to execute the snake make workflow for paired-end RNA-seq pre-processing (fastq -> feature counting), Utilizing STAR for alignment and Featurecounts for gene level counting.

# Description of files required for snakemake:
## Snakefile
This file contains the work flow
## samples_info.tab
This file contains a tab deliminated table with:

		1. The names of R1 and R2 of each fastq file as received from the sequencing center. 
		2. Simple sample names
		3. Condition (e.g. diabetic vs non_diabetic)
		4. Replicate #
		5. Sample name is the concatenated final sample_id 
		6. Additional info can be added to this table for downstream use in analysis
## config.yaml
This file contains general configuaration info.

		1. Where to locate the samples_info.tab file
		2. Path to STAR indexed genome
		3. Path to feature file (.GTF) for featurecounts
## cluster_config.yml
Sbatch parameters for each rule in the Snakefile workflow
## rename.py
		1. This python script renames the fastq files from the generally verbose ids given by the sequencing center to those supplied in the Samples_info.tab file.
		2. The Simple sample name, condition, and replicate columns are concatenated and form the new sample_id_Rx.fastq.gz files
		3. This script is executed snakemake_init.sh prior to snakemake execution
## snakemake_init.sh
This bash script:

		1. loads the miniconda3/4.6.14 module
		2. Loads the conda environment (/gpfs/data/fisherlab/conda_envs/RNAseq). You can clone the conda environment using the RNAseq_PE.yml file and modify this bash script to load the env.
		3. Executes snakemake

## Usage
When starting a new project:

		1. Copy the above noted files (6) into the new project directory from /gpfs/home/gildem01/workflows/RNAseq_PE
		2. Make a fastq/ directory in the new project directory
		3. Copy the fastq.gz files into fastq/ 
		4. Update the samples_info.tab file with fastq.gz file names and desired sample, condition, and replicate names
		5. Update config.yaml with path to genome and feature file (if needed. The default right now is mm10)
		6. Update cluster_config.yml with job desired specifications for each Snakemake rule if desired
		7. Perform a dry run of snakemake with 'snakemake -n -r' to check for errors and this will tell you the number of jobs required. You will need to load the miniconda3/4.6.14 module and activate the RNAseq environment first. Dont forget to deactivate the environment and miniconda module before running snakemake_init.sh
		8. Run snakemake_init.sh
