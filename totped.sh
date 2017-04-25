#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o totped-stdout-%j.txt
#SBATCH -e totped-stderr-%j.txt
#SBATCH -J totped

# mod 2017-01-11

module load vcftools/0.1.13

cd ~/breeding/variants/

for CROSS in $(ls *.parent2all.vcf.gz | cut -f 1 -d "."); do

	~/bin/plink --file ${CROSS} \
	--recode transpose \
	--allow-extra-chr \
        --remove ~/breeding/scripts/lists/${CROSS}.parent.plink \
	--out ${CROSS}.offspring

        ~/bin/plink --file ${CROSS} \
	--recode transpose \
        --allow-extra-chr \
        --keep ~/breeding/scripts/lists/${CROSS}.parent.plink \
        --out ${CROSS}.parent

done

#--extract ~/breeding/scripts/lists/${CROSS}.snpsub.list
