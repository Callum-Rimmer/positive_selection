#!/bin/sh
#SBATCH -p lowpri
#SBATCH --job-name=oM_run1
#SBATCH -N 1 -c 1
#SBATCH --time=20-12:0:0
#SBATCH --mail-user=callum.rimmer@ntu.ac.uk
#SBATCH --mail-type=ALL
#SBATCH --output=/users/bio3rimmec/job_logs/oM_%j.log

# This script outputs some useful information so we can see what parallel
# and srun are doing.

# Setting variables

input=$1
echo "File path:" $input
filename=$(basename $input)
echo "File:" $filename
gene=$(echo $filename | sed 's|.fas||')
echo "Gene:" $gene
codon_freq=$(grep -A 16 'Codon frequencies' ./100_strain_dataset/paml_outfiles/${gene}_8.out | tail -n 16 | sed "s/[[:space:]]\+/ /g" | sed "s/^[[:space:]]\+//g" | tr "\n" "," | sed "s| |,|g" | sed "s|,0|,|g" | sed "s|0.|.|" | cut -f 11,12,15 -d',' --complement | rev | sed "s|,||" | rev)
sample_size=$(dirname $input | cut -f9 -d'_')

dir=$(dirname $input)
	if [[ "$dir" == *100 ]]; then
		template=gene_template_100.ini
	fi
	if [[ "$dir" == *99 ]]; then
		template=gene_template_99.ini
	fi
	if [[ "$dir" == *98 ]]; then
		template=gene_template_98.ini
	fi

input_dir=$(dirname $input | cut -f3 -d'/')
output_dir=$(dirname $input | cut -f3 -d'/' | sed "s|input|output|" | sed "s|_${sample_size}||")
control_dir=$(dirname $input | cut -f3 -d'/' | sed "s|input|control_files|" | sed "s|_${sample_size}||")

block_size=$(dirname $input | cut -f4 -d'_' | sed "s|bs||")

echo "Template file:" $template

# Editing template files

sed "s|input|${input_dir}|" $template > ./100_strain_dataset/${control_dir}/${gene}.1.ini
sed -i "s|block_size|${block_size}|g" ./100_strain_dataset/${control_dir}/${gene}.1.ini
sed -i "s|mygene.fas|${filename}|" ./100_strain_dataset/${control_dir}/${gene}.1.ini
sed -i "s|output|${output_dir}|" ./100_strain_dataset/${control_dir}/${gene}.1.ini
sed -i "s|myout|${gene}.1|" ./100_strain_dataset/${control_dir}/${gene}.1.ini
sed -i "s|abc|${codon_freq}|" ./100_strain_dataset/${control_dir}/${gene}.1.ini

# Running omegaMap

./omegaMap ./100_strain_dataset/${control_dir}/${gene}.1.ini

sleepsecs=$[ ( $RANDOM % 10 ) + 10 ]s

#done
