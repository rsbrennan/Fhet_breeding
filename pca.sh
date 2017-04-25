#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o pca-stdout-%j.txt
#SBATCH -e pca-stderr-%j.txt
#SBATCH -J pca

# mod 2017-01-11

cd ~/breeding/variants/

for CROSS in $(ls *.filtered.vcf.gz | cut -f 1 -d "."); do

	#pca
	~/bin/plink --file ${CROSS} \
	--pca header --allow-extra-chr --out ~/breeding/results/pca/${CROSS}

done
