#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o cat.var.indiv-stdout-%j.txt
#SBATCH -e cat.var.indiv-stderr-%j.txt
#SBATCH -J cat.var.indiv

cd ~/breeding/variants

for i in BW-Combo1  BW-Combo2  BW-Combo3  BW-Combo4  BW-Combo5  FW-Combo1  FW-Combo2  FW-Combo4  FW-Combo5 all;
#for i in all;
do {
	cd ~/breeding/variants/$i

	~/bin/vcftools/bin/vcf-concat $(ls -1 ~/breeding/variants/${i}/*.vcf | perl -pe 's/\n/ /g') | \
	~/bin/vcftools/bin/vcf-sort -c |\
	bgzip -c > ~/breeding/variants/${i}.vcf.gz

	tabix -f -p vcf ~/breeding/variants/${i}.vcf.gz

}

done



