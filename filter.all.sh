#!/bin/bash -l
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o filt-stdout-%j.txt
#SBATCH -e filt-stderr-%j.txt
#SBATCH -J filt

cd ~/breeding/variants/

my_bedtools=~/bin/bedtools2/bin/bedtools


	~/bin/vcftools/bin/vcftools --gzvcf ~/breeding/variants/all.vcf.gz \
	--maf 0.01 \
	--recode --recode-INFO-all \
	--max-alleles 2 --min-alleles 2 \
	--max-meanDP 110 \
	--min-meanDP 10 \
	--minGQ 30 \
	--minQ 20 \
	--max-missing 0.85 \
	--remove-indels \
	--keep ~/breeding/scripts/lists/all.redo.list \
	--stdout |\
	bgzip > ~/breeding/variants/all.final.vcf.gz

	tabix -p vcf -f ~/breeding/variants/all.final.vcf.gz

