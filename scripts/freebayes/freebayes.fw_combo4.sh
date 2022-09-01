#!/bin/bash -l
#SBATCH -J array_job
#SBATCH -o /home/rsbrenna/breeding/slurm-log/array/fw4/array_job_out_%A_%a.txt
#SBATCH -e /home/rsbrenna/breeding/slurm-log/array/fw4/array_job_err_%A_%a.txt
#SBATCH --array=1-625%5
#SBATCH -p high
#SBATCH --mem=12000
###### number of nodes
###### number of processors
#SBATCH --cpus-per-task=6

pop=FW-Combo4

bwagenind=~/reference/heteroclitus_000826765.1_3.0.2_genomic.fa
my_freebayes=~/bin/freebayes/bin/freebayes
my_bedtools=~/bin/bedtools2/bin/bedtools
my_bamtools=~/bin/bamtools/bin/bamtools-2.4.0

scaf=$(cat ~/breeding/scripts/probe_scaffolds.txt | awk 'NR=='$SLURM_ARRAY_TASK_ID'')
#scaf=$(cat ~/breeding/scripts/freebayes/scaffold.redo.fw4 | awk 'NR=='$SLURM_ARRAY_TASK_ID'')
echo $scaf

outfile=$scaf.vcf

#generate bam list
#find ~/breeding/processed_data/aligned/all -type f | grep "$pop" > ~/breeding/scripts/freebayes/$pop.list

vcf_out=~/breeding/variants/$pop
bam_list=~/breeding/scripts/freebayes/$pop.list

$my_bamtools merge -list $bam_list -region $scaf | \
$my_bamtools filter -in stdin -mapQuality '>30' -isProperPair true | \
$my_freebayes -f $bwagenind --use-best-n-alleles 4 --pooled-discrete --stdin \
> $vcf_out/$outfile


