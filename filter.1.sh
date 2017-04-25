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

	~/bin/vcftools/bin/vcftools --gzvcf ~/breeding/variants/${i}.vcf.gz \
	--recode --recode-INFO-all --maf 0.05 \
	--max-alleles 2 --min-alleles 2 \
	--maxDP 110 \
	--minDP 10 \
	--minGQ 30 \
	--minQ 20 \
	--max-missing 0.75 \
	--remove ~/breeding/scripts/lists/exclude.${i}.txt \
	--remove-indels \
	--stdout |\
	bgzip > ~/breeding/variants/${i}.filtered.vcf.gz

	tabix -f -p vcf ~/breeding/variants/${i}.filtered.vcf.gz
}
done
