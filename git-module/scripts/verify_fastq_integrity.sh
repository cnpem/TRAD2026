#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 2 ]] || { echo "Uso: bash $0 INPUT_DIR OUTPUT_DIR" >&2; exit 1; }
INPUT_DIR=$(realpath -e -- "$1")
mkdir -p -- "$2"
OUTPUT_DIR=$(realpath -e -- "$2")
CORRUPT="$OUTPUT_DIR/_corrompidos.txt"
: > "$CORRUPT"
n_ok=0; n_bad=0
while IFS= read -r -d '' f; do
    if gzip -t -- "$f" 2>/dev/null; then
        ((n_ok+=1))
    else
        printf '%s\n' "$f" | tee -a "$CORRUPT" >&2
        ((n_bad+=1))
    fi
done < <(find "$INPUT_DIR" -maxdepth 1 \( -type f -o -type l \) \( -name '*.fastq.gz' -o -name '*.fq.gz' \) -print0)
((n_ok+n_bad > 0)) || { echo "ERRO: nenhum FASTQ.GZ em $INPUT_DIR" >&2; exit 1; }
echo "Integridade: $n_ok OK; $n_bad corrompido(s)"
if ((n_bad > 0)); then exit 1; fi
