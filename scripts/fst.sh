#!/bin/bash -l
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/admixture_mapping/scripts/slurm-log/
#SBATCH -o weir_fst-stdout-%j.txt
#SBATCH -e weir_fst-stderr-%j.txt
#SBATCH -J weir_fst



zcat  ~/admixture_mapping/variants/${POP}.chrom.vcf.gz |\
sed 's/\.:\.:\.:\.:\.:\.:\./\.\/\.:\.:\.:\.:\.:\.:\./g' |\


vcftools --gzvcf ~/breeding/variants/all.parent.vcf.gz  \
--weir-fst-pop ~/breeding/scripts/pl.indivs \
--weir-fst-pop ~/breeding/scripts/pp.indivs \
--out pl_vs_pp.fst
