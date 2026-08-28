#!/bin/bash
#SBATCH --job-name=fastp-biod
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH	--cpus-per-task=16
#SBATCH --hint=multithread
#SBATCH -p cpu
#SBATCH --mem=24G
###SBATCH -e log/slurm-%x-%u-%j.err  #serial jobs
###SBATCH -o log/slurm-%x-%u-%j.out  #serial jobs
#SBATCH --array=1-32%4
#SBATCH -o log/slurm-%x-%u-%A-%a.out #job array
#SBATCH -e log/slurm-%x-%u-%A-%a.err

echo "JOB $SLURM_JOB_ID running at $SLURM_SUBMIT_DIR"

cd $SLURM_SUBMIT_DIR

fastp_image=/ibira/lnbr/scratch/images/omics_tools/omics-tools.sif
READS=/ibira/lnbr/scratch/Projects/brazilian_biodiversity/fungo_isolados/raw_data/fastqs_rnaseq
experiment_table=$READS/experiment_table.tsv

record=$(cat $experiment_table | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)
smp=$(echo "$record" | cut -f1)
read1=$(echo "$record" | cut -f2)
read2=$(echo "$record" | cut -f3)
outputdir=$SLURM_SUBMIT_DIR/fastp

readsdir=$(dirname $(realpath $READS/$read1))

###set functions###
#save logs
function logMsg () {
    echo -e $1
    echo -e $1 1>&2
}

#create db folder
function createFolders () {
	local output=$1
	
	if [ ! -d "$output" ];then
		logMsg "[:: $(date +'%d-%m-%y %H:%M:%S') ::] -> Directory $output DOES NOT exists."
        mkdir -p $output
		logMsg "[:: $(date +'%d-%m-%y %H:%M:%S') ::] -> $output created!"
	fi
}

#run fastp
function run_fastp () {
    local input1=$1
    local input2=$2

    singularity exec --bind /usr/lib/locale \
    --bind $readsdir:/data \
    --bind $outputdir:/outdir \
    $fastp_image fastp -i /data/$input1 \
    -I /data/$input2 \
    -o /outdir/$(basename $input1 ".fastq.gz").CLEAN.fastq.gz \
    -O /outdir/$(basename $input2 ".fastq.gz").CLEAN.fastq.gz \
    -h /outdir/$(basename $input1 "_R1_001.fastq.gz")_fastp.html \
    -j /outdir/$(basename $input1 "_R1_001.fastq.gz")_fastp.json \
    -R /outdir/$(basename $input1 "_R1_001.fastq.gz")_fastp_report \
    -w $SLURM_CPUS_PER_TASK -q 20 -5 -3 -y -p \
    --length_required 50 
}

####MAIN####
logMsg "[:: $(date +'%d-%m-%y %H:%M:%S') ::] -> Creating output dir $outputdir ..."
createFolders "$outputdir"

logMsg "[:: $(date +'%d-%m-%y %H:%M:%S') ::] -> Running fastp for sample $smp ..."
run_fastp "$read1" "$read2"

logMsg "[:: $(date +'%d-%m-%y %H:%M:%S') ::] -> Done!!! ..."