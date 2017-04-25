#!/bin/bash -l
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o filt-stdout-%j.txt
#SBATCH -e filt-stderr-%j.txt
#SBATCH -J filt

cd ~/breeding/variants/

for i in $(ls *filtered.vcf.gz | cut -f 1 -d "." | sort | uniq)

do {

	~/bin/vcftools/bin/vcftools --gzvcf ~/breeding/variants/${i}.filtered.vcf.gz \
	--keep ~/breeding/scripts/${i}.parent \
	--maf 0.01 \
	--recode \
	--recode-INFO-all \
	--max-missing 0.75 \
	--stdout | bgzip > ~/breeding/variants/${i}.parent.vcf.gz

	tabix -p vcf -f ~/breeding/variants/${i}.parent.vcf.gz
}
done

