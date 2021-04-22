#!/bin/bash -l
module load miniconda3/4.6.14
conda activate /gpfs/data/fisherlab/conda_envs/RNAseq

for num in {1..100}
do
    if ! python cat_rename.py ${num}; then
        echo "Exiting..."
        exit
    fi
done

snakemake --cluster "sbatch -J {cluster.Job_name} --mem {cluster.Mem} -c {cluster.Cores} -p {cluster.Partition} -t {cluster.Time} --output {cluster.Error}" --cluster-config cluster_config.yml --jobs 6

conda deactivate
module unload miniconda3/4.6.14
module load python/cpu/2.7.15
multiqc .