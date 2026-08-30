#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 2 ]] || { echo "Uso: bash $0 INPUT_DIR OUTPUT_DIR" >&2; exit 1; }
INPUT_DIR=$(realpath -e -- "$1"); mkdir -p -- "$2"; OUTPUT_DIR=$(realpath -e -- "$2")
THREADS=${THREADS:-${SLURM_CPUS_PER_TASK:-4}}
command -v NanoPlot >/dev/null 2>&1 || { command -v ml >/dev/null 2>&1 && ml load nanoplot/1.47.2; }
command -v NanoPlot >/dev/null 2>&1 || { echo 'ERRO: NanoPlot nao encontrado no PATH' >&2; exit 1; }
mapfile -d '' -t files < <(find "$INPUT_DIR" -maxdepth 1 \( -type f -o -type l \) \( -name '*.fastq.gz' -o -name '*.fq.gz' \) -print0 | sort -z)
((${#files[@]})) || { echo "ERRO: nenhum FASTQ.GZ em $INPUT_DIR" >&2; exit 1; }
for fastq in "${files[@]}"; do
    sample=$(basename "$fastq"); sample=${sample%.fastq.gz}; sample=${sample%.fq.gz}
    out="$OUTPUT_DIR/$sample"; mkdir -p "$out"
    NanoPlot --threads "$THREADS" --fastq "$fastq" --outdir "$out" --prefix "${sample}_" --N50 --tsv_stats --plots kde
done
