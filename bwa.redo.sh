#!/bin/bash
#SBATCH -D /home/rsbrenna/breeding/slurm-log/array/bwa/
#SBATCH -o bwa.align-stdout-%j.txt
#SBATCH -e bwa.align-stderr-%j.txt
#SBATCH -J bwa.align
#SBATCH --mem=10000
###### number of nodes
###### number of processors

cd ~/breeding/processed_data/demultiplex/

#move all fastq files to parent directory

#find . -mindepth 2 -type f -print -exec mv {} . \;

indir=~/breeding/processed_data/demultiplex/
my_samtools=~/bin/samtools-1.3.1/samtools
my_bwa=~/bin/bwa-0.7.12/bwa
my_samblstr=~/bin/samblaster/samblaster
bwagenind=~/reference/heteroclitus_000826765.1_3.0.2_genomic.fa
outdir=~/breeding/processed_data/aligned/all


for i in 1783 1791 189 190 191 192 193 194 56 57 58 59 60 61 74 75 76 77 78 79 81 82 83 84 85 86 87 88 89 90 91 92
do

{
	fq1=$(find $indir -name "*_RA.fastq" | sed -n ${i}p)
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

}

done
