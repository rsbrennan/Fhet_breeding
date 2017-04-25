#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o intersect-stdout-%j.txt
#SBATCH -e intersect-stderr-%j.txt
#SBATCH -J intersect

my_bedtools=~/bin/bedtools2/bin/bedtools

zcat ~/breeding/variants/BW-Combo1.filtered.vcf.gz | \
bedtools intersect \
	-a stdin \
	-b ~/breeding/scripts/probes.700pos.bed \
	-header \
	> ~/breeding/variants/BW-Combo1.700.vcf
