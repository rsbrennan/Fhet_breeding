#!/bin/bash
#SBATCH -J array_job
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o colony_job_out_%A_%a.txt
#SBATCH -e colony_job_err_%A_%a.txt
#SBATCH --array=1-1
#SBATCH -p med


cd ~/breeding/analysis/colony/


#REP=$(ls *.colony.dat | awk 'NR=='$SLURM_ARRAY_TASK_ID'')

REP=$(ls *.colony.dat | grep 'all' | awk 'NR=='$SLURM_ARRAY_TASK_ID'')
#REP=$(ls *.colony.dat |  awk 'NR=='$SLURM_ARRAY_TASK_ID'')

echo $REP

./colony2s.ifort.out IFN:$REP
