#!/bin/bash -l
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o download-stdout-%j.txt
#SBATCH -e download-stderr-%j.txt
#SBATCH -J download

cd ~/breeding/rawdata/

wget -r -nH -nc -np -R index.html* "http://slims.bioinformatics.ucdavis.edu/Data/9e5nf0ujv4/Unaligned/Project_AWRB_L4_RSB_BE/"
