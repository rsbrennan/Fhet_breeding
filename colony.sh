#!/bin/bash
#SBATCH -J array_job
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o colony_job_out_%A_%a.txt
#SBATCH -e colony_job_err_%A_%a.txt
#SBATCH --array=1-10
#SBATCH -p med


cd ~/breeding/analysis/colony/


#REP=$REP=$(ls *.colony.dat | awk 'NR=='$SLURM_ARRAY_TASK_ID'')

REP=$(ls *.colony.dat | grep 'BW\|all' | grep -v 'BW-Combo5.colony.dat' | grep -v 'BW-Combo4.colony.dat' | awk 'NR=='$SLURM_ARRAY_TASK_ID'')

echo $REP

./colony2s.ifort.out IFN:$REP
