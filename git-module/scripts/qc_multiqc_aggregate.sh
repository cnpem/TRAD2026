#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -ge 2 && $# -le 3 ]] || { echo "Uso: bash $0 QC_ROOT OUTPUT_DIR [DATASET_NAME]" >&2; exit 1; }
QC_ROOT=$(realpath -e -- "$1"); mkdir -p -- "$2"; OUTPUT_DIR=$(realpath -e -- "$2")
DATASET_NAME=${3:-$(basename "$QC_ROOT")}
command -v multiqc >/dev/null 2>&1 || { command -v ml >/dev/null 2>&1 && ml load multiqc/1.35; }
command -v multiqc >/dev/null 2>&1 || { echo 'ERRO: MultiQC nao encontrado' >&2; exit 1; }
sources=()
for d in "$QC_ROOT/1.fastqc_raw" "$QC_ROOT/2.fastp/reports" "$QC_ROOT/3.fastqc_clean" "$QC_ROOT/1.nanoplot"; do
    [[ -d "$d" ]] && sources+=("$d")
done
((${#sources[@]})) || { echo "ERRO: nenhum resultado de QC em $QC_ROOT" >&2; exit 1; }
multiqc "${sources[@]}" --outdir "$OUTPUT_DIR" --filename multiqc_report.html --title "TRAD2026 - $DATASET_NAME" --force
