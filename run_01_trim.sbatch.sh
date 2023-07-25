#!/bin/bash                                                                                                                                                      
#SBATCH --job-name=em_trim
#SBATCH --mail-type=BEGIN,END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=hayan.lee@stanford.edu  # Where to send mail  
 
#SBATCH --nodes=1 
#SBATCH --ntasks=1                    # Run on a single CPU
# One CPU/core per task
#SBATCH --cpus-per-task=4 
#SBATCH --mem=20G                     # Job memory request
 
# Set job time to 1 day.
#SBATCH --time=2-20:00:00

#SBATCH --output=array_%A-%a.log          # Standard output and error log
#SBATCH --array=1,3,18,22,26,28,51
#SBATCH --account=mpsnyder

#array_31822446-1.log EP_blood
#array_31822446-3.log EP_034
#array_31822446-12.log CRC1_FFPE
#array_31822446-18.log A035_E024 
#array_31822446-22.log A035_E020
#array_31822446-26.log A033_E002
#array_31822446-28.log A015_C008 
#array_31822446-51.log A001_C005
 
#### scontrol update jobid=21678 account=PI_SUNetID
 
#module add picard-tools/1.92
#module add java/latest
#module add samtools/0.1.19
#module add vcftools/0.1.12a
#module add bedtools/2.18.0
#module add pysam/0.8.3 
#module add tabix/0.2.6
#module add fastqc/0.10.1
#module add igvtools/2.3.3
#module add r/3.1.1
#module add bsmap/2.89
#module add python/2.7
#module add bamUtil/1.0.12
module add trim_galore/0.4.5
#module load java/latest
module load fastqc/0.11.9

DATE=20220222
DATE=20220313
ref=hg38

#REF=/srv/gsfs0/projects/snyder/njaeger/genomes/hg19/refgenome_ucsc/hg19.fa
#REF=/srv/gsfs0/projects/snyder/hayanlee/genome/GRCh38/hg38.chr.fa
REF=/labs/mpsnyder/hayanlee/genome/GRCh38/hg38.chr.fa
DIR_PRJ=/labs/mpsnyder/hayanlee/projects/EM-seq
DIR_SRC=${DIR_PRJ}/src
#DIR_READS=${DIR_PRJ}/fastq/$DATE
DIR_READS=${DIR_PRJ}/fastq/FQ
DIR_PIPE=${DIR_PRJ}/pipeline.$ref

############################
#samples=(A001C005_Polyp A001C007_AdCa)
#samples=(120648-UGAv3-11 120648-UGAv3-12 120648-UGAv3-13 120648-UGAv3-14 120648-UGAv3-15 120648-UGAv3-16 120655-UGAv3-11 120655-UGAv3-12 120655-UGAv3-13 120655-UGAv3-14 120655-UGAv3-15 120655-UGAv3-16)
#index=(Blood C010 C116 C121 C212 C204)
#samples=(A001_blood A001_C113 A001_C206 A002_C012 A002_C111 A015_C002 A015_C008 A015_C203)
#samples=(A014_C037 A014_C038 A014_C052 )
#samples=(A014_C202 A033_E002 A035_E002 A035_E021 A035_E023 A052_E018)
#samples=(A014_blood A015_blood)
#samples=(A014_C044 A014_C052 A014_C115 A014_C202 A055_C111 A055_C211)
#samples=(A014_C001)
samples=( EP_blood
EP_88B
EP_034
EP_007
CRC7_FreshFrozen
CRC6_FreshFrozen
CRC5_FreshFrozen
CRC4_FreshFrozen
CRC3_FreshFrozen
CRC2_FreshFrozen
CRC1_FreshFrozen
CRC1_FFPE
A055_C211
A055_C111
A055_C012
A052_E018
A052_E016
A035_E024
A035_E023
A035_E022
A035_E021
A035_E020
A035_E019
A035_E018
A035_E002
A033_E002
A015_C203
A015_C008
A015_C002
A015_blood
A014_C202
A014_C115
A014_C052
A014_C044
A014_C038
A014_C037
A014_C001
A014_blood
A002_C212
A002_C204
A002_C121
A002_C116
A002_C111
A002_C012
A002_C010
A002_Blood
A001_C206
A001_C113
A001_C021
A001_C007
A001_C005
A001_C004
A001_blood
)

set -x 

#SLURM_ARRAY_TASK_ID=1
pwd; hostname; date
echo "Running plot script on a single CPU core"
echo "This is task $SLURM_ARRAY_TASK_ID"
i=$(($SLURM_ARRAY_TASK_ID-1))
echo $i 
#diid=${index[i]}
sid=${samples[i]}

STAGE=01_trim
DIR_STAGE=$DIR_PIPE/$STAGE
DIR_SAMPLE=$DIR_PIPE/$STAGE/$sid

mkdir -p $DIR_SAMPLE     

FASTQ=$DIR_READS/${sid}_*.fq.gz
ls $FASTQ
se_list=`ls $FASTQ`
pe_list=`ls $FASTQ`
#pe_list=`ls $FASTQ $DIR_READS/*-${iid}/*.fastq.gz`
#trim_galore --paired --length 50 --clip_R1 6 --clip_R2 6 -o $DIR_SAMPLE $pe_list &> $DIR_STAGE/${iid}.log
trim_galore --length 50 --clip_R1 6 -o $DIR_SAMPLE $se_list &> $DIR_STAGE/${sid}.log

# check that no adapter contamination left and expected CG contents, 
# typical BisulfiteSeq tends to have an average cytosine content of ~1-2% 
# throughout the entire sequence length, otherwise likely adapter contamination or primer.
# K-mer plot can be ignored for MethylSeq, random
 
#module load perl-scg/1.0

#trimmed_pe_list=`ls $DIR_SAMPLE/*.fq.gz`
#fastqc -t 8 --noextract $trimmed_pe_list


