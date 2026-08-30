#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 2 ]] || { echo "Uso: bash $0 INPUT_DIR OUTPUT_DIR" >&2; exit 1; }
INPUT_DIR=$(realpath -e -- "$1"); mkdir -p -- "$2" "$2/reports"; OUTPUT_DIR=$(realpath -e -- "$2")
THREADS=${THREADS:-${SLURM_CPUS_PER_TASK:-4}}
command -v fastp >/dev/null 2>&1 || { command -v ml >/dev/null 2>&1 && ml load fastp/1.0.1; }
command -v fastp >/dev/null 2>&1 || { echo 'ERRO: fastp nao encontrado' >&2; exit 1; }
mapfile -d '' -t r1s < <(find "$INPUT_DIR" -maxdepth 1 \( -type f -o -type l \) \( -name '*_1.fastq.gz' -o -name '*_R1.fastq.gz' -o -name '*_1.fq.gz' -o -name '*_R1.fq.gz' \) -print0 | sort -z)
((${#r1s[@]})) || { echo 'ERRO: nenhum par R1/R2 encontrado' >&2; exit 1; }
for r1 in "${r1s[@]}"; do
    case "$r1" in
        *_R1.fastq.gz) r2=${r1%_R1.fastq.gz}_R2.fastq.gz; sample=$(basename "${r1%_R1.fastq.gz}") ;;
        *_1.fastq.gz) r2=${r1%_1.fastq.gz}_2.fastq.gz; sample=$(basename "${r1%_1.fastq.gz}") ;;
        *_R1.fq.gz) r2=${r1%_R1.fq.gz}_R2.fq.gz; sample=$(basename "${r1%_R1.fq.gz}") ;;
        *_1.fq.gz) r2=${r1%_1.fq.gz}_2.fq.gz; sample=$(basename "${r1%_1.fq.gz}") ;;
    esac
    [[ -e "$r2" ]] || { echo "ERRO: R2 ausente para $r1" >&2; exit 1; }
    fastp --in1 "$r1" --in2 "$r2" \
      --out1 "$OUTPUT_DIR/${sample}_1.clean.fastq.gz" \
      --out2 "$OUTPUT_DIR/${sample}_2.clean.fastq.gz" \
      --thread "$THREADS" \
      --html "$OUTPUT_DIR/reports/${sample}.fastp.html" \
      --json "$OUTPUT_DIR/reports/${sample}.fastp.json"
done
