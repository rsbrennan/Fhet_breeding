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

	~/bin/vcftools/bin/vcftools --gzvcf ~/breeding/variants/${i}.filter1.vcf.gz \
	--maf 0.01 \
	--recode --recode-INFO-all \
	--positions ~/breeding/variants/parent.${i}.snp \
	--max-meanDP 110 \
	--min-meanDP 10 \
	--max-missing 0.9 \
	--stdout |\
	bgzip > ~/breeding/variants/${i}.final.vcf.gz

	tabix -p vcf -f ~/breeding/variants/${i}.final.vcf.gz
}
done
