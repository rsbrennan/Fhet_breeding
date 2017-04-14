#!/bin/bash
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o rename-stdout-%j.txt
#SBATCH -e rename-stderr-%j.txt
#SBATCH -J rename


cd ~/breeding/scripts/rename/

for i in $(ls *.rename.sh | cut -c -5)

do {

	cd ~/breeding/processed_data/demultiplex/${i}
	source ~/breeding/scripts/rename/${i}.rename.sh

}
done
