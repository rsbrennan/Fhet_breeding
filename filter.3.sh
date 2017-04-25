#!/bin/bash -l
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o filt-stdout-%j.txt
#SBATCH -e filt-stderr-%j.txt
#SBATCH -J filt

cd ~/breeding/variants/

my_bedtools=~/bin/bedtools2/bin/bedtools

for i in $(ls *.vcf.gz | cut -f 1 -d "." | sort | uniq)

do {

	~/bin/vcftools/bin/vcftools --gzvcf ~/breeding/variants/${i}.filtered.vcf.gz \
	--maf 0.01 \
	--recode --recode-INFO-all \
	--positions ~/breeding/variants/parent.${i}.snp \
	--max-missing 0.8 \
	--stdout |\
	bgzip > ~/breeding/variants/${i}.parent2all.vcf.gz

	tabix -p vcf -f ~/breeding/variants/${i}.parent2all.vcf.gz
}
done
