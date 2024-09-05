#!/bin/sh
#SBATCH --job-name=PAML_M7
#SBATCH -N 1 -c 1
#SBATCH --time=30-12:0:0
#SBATCH --mail-user=callum.rimmer@ntu.ac.uk
#SBATCH --mail-type=ALL
#SBATCH --output=/users/xxxxx/job_logs/paml_%j.log

. /users/xxxxx/miniconda3/etc/profile.d/conda.sh
conda activate paml
# This script outputs some useful information so we can see what parallel
# and srun are doing.

filename=$1
gene=$(basename $filename)
echo $gene
input_dir=$(dirname $filename | cut -f3 -d'/')
x=$(echo $gene | sed 's|.phy||' )
sed "s|myin|${input_dir}/${gene}|" codemlmod7.ctl > ./genes_7/${x}/${x}_7.ctl
sed -i "s|mytree|${x}.raxml.bestTree|" ./genes_7/${x}/${x}_7.ctl
sed -i "s|myout|replicate_1/${x}_7.out|" ./genes_7/${x}/${x}_7.ctl
cd ./genes_7/${x}
codeml ./${x}_7.ctl


sleepsecs=$[ ( $RANDOM % 10 ) + 10 ]s

#done
