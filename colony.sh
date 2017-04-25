#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o colony-stdout-%j.txt
#SBATCH -e colony-stderr-%j.txt
#SBATCH -J colony

cd ~/breeding/analysis/colony/

./colony2s.ifort.out IFN:BW-Combo1.colony
