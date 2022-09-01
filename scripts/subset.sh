#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o toplink-stdout-%j.txt
#SBATCH -e toplink-stderr-%j.txt
#SBATCH -J toplink

# mod 2017-01-11

module load vcftools/0.1.13
module load bcftools

cd ~/breeding/variants/


# first, thin for ld with all samples

	# convert to plink
	zcat ~/breeding/variants/all.final.vcf.gz  |\
	vcftools --vcf - --remove-indv FW-Combo5-PL-F-8 \
	--plink --chrom-map ~/breeding/scripts/all.plink-chrom-map.txt --out all

	#thin markers for ld
	~/bin/plink --file all --indep 50 5 1.5 \
	--allow-extra-chr \
	--out all.ld
	# this leaves 1606 snps

	~/bin/plink --file all --extract all.ld.prune.in --recode transpose \
		--allow-extra-chr \
        --out all

for CROSS in BW-Combo1 BW-Combo2 BW-Combo3 BW-Combo4 BW-Combo5 FW-Combo1 FW-Combo2 FW-Combo4 FW-Combo5 ; do

	# make list for each set:
	zcat ~/breeding/variants/all.final.vcf.gz | head -n 100| grep '^#CHROM' | tr '\t' '\n' | grep -v '#CHROM' | grep ${CROSS} | grep -v 'FW-Combo5-PL-F-8' > ~/breeding/scripts/lists/${CROSS}.allindiv.list

	# filter to make new vcf for each combo
	zcat ~/breeding/variants/all.final.vcf.gz  |\
	vcftools --vcf -  \
	--keep ~/breeding/scripts/lists/${CROSS}.allindiv.list \
	--chrom-map ~/breeding/scripts/all.plink-chrom-map.txt --recode --out ${CROSS}.subset

	mv ${CROSS}.subset.recode.vcf ${CROSS}.subset.vcf

	# convert to plink
	cat ${CROSS}.subset.vcf  |\
	vcftools --vcf -  \
	--plink --chrom-map ~/breeding/scripts/all.plink-chrom-map.txt --out ${CROSS}

    ##### make tped

	~/bin/plink --file ${CROSS} --extract all.ld.prune.in --recode transpose \
		--allow-extra-chr \
        --out ${CROSS}.all

done

