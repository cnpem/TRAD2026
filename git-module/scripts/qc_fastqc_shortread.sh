#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 2 ]] || { echo "Uso: bash $0 INPUT_DIR OUTPUT_DIR" >&2; exit 1; }
INPUT_DIR=$(realpath -e -- "$1"); mkdir -p -- "$2"; OUTPUT_DIR=$(realpath -e -- "$2")
THREADS=${THREADS:-${SLURM_CPUS_PER_TASK:-4}}
command -v fastqc >/dev/null 2>&1 || { command -v ml >/dev/null 2>&1 && ml load fastqc/0.12.1; }
command -v fastqc >/dev/null 2>&1 || { echo 'ERRO: FastQC nao encontrado' >&2; exit 1; }
mapfile -d '' -t files < <(find "$INPUT_DIR" -maxdepth 1 \( -type f -o -type l \) \( -name '*.fastq.gz' -o -name '*.fq.gz' \) -print0 | sort -z)
((${#files[@]})) || { echo "ERRO: nenhum FASTQ.GZ em $INPUT_DIR" >&2; exit 1; }
fastqc --threads "$THREADS" --outdir "$OUTPUT_DIR" "${files[@]}"
