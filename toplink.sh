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

for CROSS in $(ls *.final.vcf.gz | cut -f 1 -d "."); do

	zcat ~/breeding/variants/${CROSS}.final.vcf.gz  |\
	vcftools --vcf - \
	--plink --chrom-map ~/breeding/scripts/all.plink-chrom-map.txt --out ${CROSS}

	#think markers for ld
	~/bin/plink --file $CROSS --indep 50 5 1.5 \
	--allow-extra-chr \
	--out $CROSS

	# output ped

	~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode \
	--allow-extra-chr \
	--out ${CROSS}.thinned

	#output bed
	~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode \
        --allow-extra-chr \
	--make-bed \
        --out ${CROSS}.thinned

done

for CROSS in $(ls *.final.vcf.gz | cut -f 1 -d "."); do

	~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode transpose \
	--allow-extra-chr \
        --remove ~/breeding/scripts/lists/${CROSS}.parent.plink \
	--out ${CROSS}.offspring


        ~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode transpose \
        --allow-extra-chr \
        --keep ~/breeding/scripts/lists/${CROSS}.parent.plink \
        --out ${CROSS}.parent

	# write vcf

	~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode vcf \
        --allow-extra-chr \
        --remove ~/breeding/scripts/lists/${CROSS}.parent.plink \
        --out ${CROSS}.offspring

        ~/bin/plink --file ${CROSS} --extract ${CROSS}.prune.in --recode vcf \
        --allow-extra-chr \
        --keep ~/breeding/scripts/lists/${CROSS}.parent.plink \
        --out ${CROSS}.parent



done

