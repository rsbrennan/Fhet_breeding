#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o count.demultiplex-stdout-%j.txt
#SBATCH -e count.demultiplex-stderr-%j.txt
#SBATCH -J count.demultiplex


cd ~/breeding/processed_data/demultiplex/

touch ~/breeding/summary_files/count.demultiplex.txt

for i in $(ls *.fastq | grep 'RA' | grep -v 'Best');

do {
	FORWARD=$(cat ${i}| wc -l)
	echo ${i},$FORWARD
} >> ~/breeding/summary_files/count.demultiplex.txt

done
