#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o cov.indiv-stdout-%j.txt
#SBATCH -e cov.indiv-stderr-%j.txt
#SBATCH -J cov.indiv

my_bamtools=~/bin/bamtools/bin/bamtools
my_bedtools=~/bin/bedtools2/bin/bedtools
my_samtools=~/bin/samtools-1.3.1/samtools

cd ~/breeding/processed_data/aligned/all

for indiv in $( ls )

do {

	find *bam | parallel \
	'bedtools coverage -abam {} \
	-b ~/breeding/scripts/probes.20pos.bed > ~/breeding/summary_files/coverage/{}.depth.txt'
  }
done
