#!/bin/bash -l
#SBATCH --mail-type=END
#SBATCH --mail-user=rsbrennan@ucdavis.edu
#SBATCH -D /home/rsbrenna/breeding/slurm-log/
#SBATCH -o sra_upload-stdout-%j.txt
#SBATCH -e sra_upload-stderr-%j.txt
#SBATCH -J aspera

module load aspera-connect/3.7.4

# aspera connect
# see here: https://www.ncbi.nlm.nih.gov/books/NBK242625/

ascp -i /home/rsbrenna/admixture_mapping/aspera.openssh -QT -l100m -k1 -d ~/breeding/processed_data/demultiplex subasp@upload.ncbi.nlm.nih.gov:uploads/reid.brennan_gmail.com_gOcpXpBD/set3

#ssh -i ~/admixture_mapping/aspera.openssh asp-ucdbioinfo@upload.ncbi.nlm.nih.gov
