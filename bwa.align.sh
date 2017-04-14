#!/bin/bash
#SBATCH -D /home/rsbrenna/breeding/slurm-log/array/
#SBATCH -o bwa.align-stdout-%j.txt
#SBATCH -e bwa.align-stderr-%j.txt
#SBATCH -J bwa.align
#SBATCH --array=1-3000%400
#SBATCH -p med
#SBATCH --mem=10000
###### number of nodes
###### number of processors

cd ~/reference/

#move all fastq files to parent directory

#find . -mindepth 2 -type f -print -exec mv {} . \;

indir=~/breeding/processed_data/demultiplex/
my_samtools=~/bin/samtools-1.3.1/samtools
my_bwa=~/bin/bwa-0.7.12/bwa
my_samblstr=~/bin/samblaster/samblaster
bwagenind=~/reference/heteroclitus_000826765.1_3.0.2_genomic.fa
outdir=~/breeding/processed_data/aligned/all

fq1=$(find $indir -name "*_RA.fastq" | sed -n $(echo $SLURM_ARRAY_TASK_ID)p)
fq2=$(echo $fq1 | sed 's/_RA/_RB/g')
root=$(echo $fq1 | sed 's/.*\///' | cut -f 1 -d "_")
rg=$(echo \@RG\\tID:$root\\tPL:Illumina\\tPU:x\\tLB:na\\tSM:$root)
tempsort=$root.temp
outfile=$outdir/$root.bam

echo $SLURM_ARRAY_TASK_ID
echo $indir
echo $root
echo $fq1
echo $fq2
echo $rg
echo $tempsort
echo $outfile
echo $outdir


$my_bwa mem -t 6 -R $rg $bwagenind $fq1 $fq2 | \
$my_samblstr | \
$my_samtools view -S -h -u - | \
$my_samtools sort - -T /scratch/$tempsort -O bam -o $outfile


