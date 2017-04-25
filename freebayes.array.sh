#!/bin/bash -l
#SBATCH -J array_job
#SBATCH -o /home/rsbrenna/breeding/slurm-log/array/array_job_out_%A_%a.txt
#SBATCH -e /home/rsbrenna/breeding/slurm-log/array/array_job_err_%A_%a.txt
#SBATCH --array=1-625%15
#SBATCH -p high
#SBATCH --mem=12000
###### number of nodes
###### number of processors
#SBATCH --cpus-per-task=6

bwagenind=~/reference/heteroclitus_000826765.1_3.0.2_genomic.fa
my_freebayes=~/bin/freebayes/bin/freebayes
my_bedtools=~/bin/bedtools2/bin/bedtools
my_bamtools=~/bin/bamtools/bin/bamtools-2.4.0

scaf=$(cat ~/breeding/scripts/probe_scaffolds.txt | awk 'NR=='$SLURM_ARRAY_TASK_ID'')
echo $scaf

#endpos=$(expr $(grep -P "$scaf\t" ~/reference/heteroclitus_000826765.1_3.0.2_genomic.fa.fai | cut -f 2) - 1)
#echo $endpos

#region=$scaf:1..$endpos
#echo $region

outfile=$scaf.vcf

#generate bam list
find ~/breeding/processed_data/aligned/all -type f > ~/breeding/scripts/bam.all.list

vcf_out=~/breeding/variants/all
bam_list=~/breeding/scripts/bam.all.list

$my_bamtools merge -list $bam_list -region $scaf | \
$my_bamtools filter -in stdin -mapQuality '>30' -isProperPair true | \
$my_freebayes -f $bwagenind --use-best-n-alleles 4 --pooled-discrete --stdin \
> $vcf_out/$outfile


