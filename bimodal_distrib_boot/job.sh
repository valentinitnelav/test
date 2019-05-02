#!/bin/bash
#$ -S /bin/bash
#$ -N bootstrap_glopl_stackexchange
#$ -l h_rt=1:00:00
#$ -l h_vmem=2G
#$ -cwd
#$ -o /work/$USER/$JOB_NAME-$JOB_ID/log-files/$JOB_NAME-$JOB_ID-$TASK_ID.log
#$ -j y
#$ -binding linear:1


module load R/3.5.1-1

data_path=$1
output=/work/$USER/$JOB_NAME-$JOB_ID
mkdir -p $output

Rscript bootstrap.r \
"$data_path" \
"$output/coef-$SGE_TASK_ID.rda"
