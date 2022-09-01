#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o pca-stdout-%j.txt
#SBATCH -e pca-stderr-%j.txt
#SBATCH -J pca

# mod 2017-01-11

cd ~/breeding/variants/


~/bin/plink --tfile ~/breeding/variants/all.parent --pca header --allow-extra-chr --out ~/breeding/results/pca/all.parent
