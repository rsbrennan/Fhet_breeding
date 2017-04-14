#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o cov.probe-stdout-%j.txt
#SBATCH -e cov.probe-stderr-%j.txt
#SBATCH -J cov.probe

my_bamtools=~/bin/bamtools/bin/bamtools-2.4.0
my_bedtools=~/bin/bedtools2/bin/bedtools
my_samtools=~/bin/samtools-1.3.1/samtools

#generate list of bam files

find ~/breeding/processed_data/aligned/all -type f | head -n 500 > ~/breeding/scripts/bam.list

$my_bamtools merge -list ~/breeding/scripts/bam.list |\
	$my_samtools sort - -T tmp.temp -O bam |\
	$my_bedtools coverage -abam stdin -b ~/breeding/scripts/probes.20pos.bed \
	> ~/breeding/summary_files/coverage.probe.txt
