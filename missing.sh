#!/bin/bash -l
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o depth-stdout-%j.txt
#SBATCH -e depth-stderr-%j.txt
#SBATCH -J depth

cd ~/breeding/variants/

my_bedtools=~/bin/bedtools2/bin/bedtools

for i in $(ls *.vcf.gz | cut -f 1 -d "." | sort | uniq)

do {

	~/bin/vcftools/bin/vcftools --gzvcf ~/breeding/variants/${i}.parent2all.vcf.gz \
	--missing-indv \
	--stdout \
	> ~/breeding/summary_files/${i}.parent2all.depth


}
done
