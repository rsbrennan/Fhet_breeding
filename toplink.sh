#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o toplink-stdout-%j.txt
#SBATCH -e toplink-stderr-%j.txt
#SBATCH -J toplink

# mod 2017-01-11

module load vcftools/0.1.13

cd ~/breeding/variants/

for CROSS in $(ls *.parent2all.vcf.gz | cut -f 1 -d "."); do

	zcat ~/breeding/variants/${CROSS}.parent2all.vcf.gz  |\
	vcftools --vcf - \
	--plink --chrom-map ~/breeding/scripts/all.plink-chrom-map.txt --out ${CROSS}

	#think markers for ld
	~/bin/plink --file $CROSS --indep 50 5 2 \
	--allow-extra-chr \
	--out $CROSS

	# output ped

	~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode \
	--allow-extra-chr \
	--out ${CROSS}.thinned

	~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode transpose \
	--allow-extra-chr \
        --remove ~/breeding/scripts/lists/${CROSS}.parent.plink \
	--out ${CROSS}.offspring

        ~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode transpose \
        --allow-extra-chr \
        --keep ~/breeding/scripts/lists/${CROSS}.parent.plink \
        --out ${CROSS}.parent

done

