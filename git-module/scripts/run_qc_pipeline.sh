#!/usr/bin/env bash
# TRAD2026 - Orquestrador serial de controle de qualidade
# Executa scripts auxiliares com bash. Nao submete jobs com sbatch.

set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
VERIFY=false
POSITIONAL=()

usage() {
    cat <<'HELP'
Uso:
  bash run_qc_pipeline.sh [--verify] INPUT_DIR OUTPUT_DIR [READ_TYPE] [DATASET_NAME]

Opcoes:
  --verify   Verifica a integridade gzip dos FASTQ antes do controle de qualidade
  -h, --help Exibe esta ajuda

READ_TYPE:
  auto      Usa o tipo predefinido para os datasets conhecidos (padrao)
  short-pe  Short reads paired-end: FastQC -> fastp -> FastQC -> MultiQC
  short-se  Short reads single-end: FastQC -> MultiQC
  long      Long reads: NanoPlot -> MultiQC

Exemplos:
  bash run_qc_pipeline.sh INPUT_DIR OUTPUT_DIR
  bash run_qc_pipeline.sh --verify INPUT_DIR OUTPUT_DIR
  bash run_qc_pipeline.sh INPUT_DIR OUTPUT_DIR long Novo_dataset

Com srun:
  srun --partition=<particao> --cpus-per-task=8 --mem=16G --time=06:00:00 \
    bash run_qc_pipeline.sh INPUT_DIR OUTPUT_DIR auto
HELP
}

die() { printf 'ERRO: %s\n' "$*" >&2; exit 1; }
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }

# Permite --verify antes ou depois dos argumentos posicionais.
while (($#)); do
    case "$1" in
        --verify)
            VERIFY=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            POSITIONAL+=("$@")
            break
            ;;
        -* )
            die "opcao desconhecida: $1"
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"
[[ $# -ge 2 && $# -le 4 ]] || { usage; exit 1; }

INPUT_DIR=$(realpath -e -- "$1") || die "diretorio de entrada inexistente: $1"
[[ -d "$INPUT_DIR" ]] || die "a entrada nao e um diretorio: $INPUT_DIR"
mkdir -p -- "$2"
OUTPUT_DIR=$(realpath -e -- "$2")
READ_TYPE=${3:-auto}
DATASET_NAME=${4:-$(basename "$INPUT_DIR")}
THREADS=${THREADS:-${SLURM_CPUS_PER_TASK:-4}}

[[ "$READ_TYPE" =~ ^(auto|short-pe|short-se|long)$ ]] || \
    die "READ_TYPE invalido: $READ_TYPE"
[[ "$THREADS" =~ ^[1-9][0-9]*$ ]] || \
    die "THREADS deve ser um inteiro positivo"

required=(
    qc_fastqc_shortread.sh
    qc_fastp_shortread.sh
    qc_nanoplot_longread.sh
    qc_multiqc_aggregate.sh
)
$VERIFY && required+=(verify_fastq_integrity.sh)

for script in "${required[@]}"; do
    [[ -f "$SCRIPT_DIR/$script" ]] || \
        die "script auxiliar ausente: $SCRIPT_DIR/$script"
done

detect_type() {
    case "$DATASET_NAME" in
        16S_Hydrochoerus_hydrochaeris|Apis_mellifera|HNSCC|MG_Hydrochoerus_hydrochaeris|Salminus_brasiliensis)
            printf 'short-pe\n'
            ;;
        16S_Waterwaste)
            printf 'short-se\n'
            ;;
        Alouatta_sp|Euterpe_oleracea|Ipomoea_cavalcantei)
            printf 'long\n'
            ;;
        *)
            die "tipo desconhecido para o dataset '$DATASET_NAME'. Informe READ_TYPE: short-pe, short-se ou long"
            ;;
    esac
}

if [[ "$READ_TYPE" == auto ]]; then
    READ_TYPE=$(detect_type)
fi

RAW_FASTQC="$OUTPUT_DIR/1.fastqc_raw"
FASTP_OUT="$OUTPUT_DIR/2.fastp"
CLEAN_FASTQC="$OUTPUT_DIR/3.fastqc_clean"
NANOPLOT_OUT="$OUTPUT_DIR/1.nanoplot"
MULTIQC_OUT="$OUTPUT_DIR/4.multiqc"

START=$SECONDS
log "Dataset: $DATASET_NAME"
log "Tipo: $READ_TYPE"
log "CPUs: $THREADS"
log "Entrada: $INPUT_DIR"
log "Saida: $OUTPUT_DIR"
log "Verificacao de integridade: $VERIFY"

if $VERIFY; then
    log "Verificando a integridade dos arquivos FASTQ.GZ"
    bash "$SCRIPT_DIR/verify_fastq_integrity.sh" \
        "$INPUT_DIR" "$OUTPUT_DIR"
else
    log "Verificacao de integridade ignorada; use --verify para ativa-la"
fi

case "$READ_TYPE" in
    short-pe)
        THREADS=$THREADS bash "$SCRIPT_DIR/qc_fastqc_shortread.sh" \
            "$INPUT_DIR" "$RAW_FASTQC"
        THREADS=$THREADS bash "$SCRIPT_DIR/qc_fastp_shortread.sh" \
            "$INPUT_DIR" "$FASTP_OUT"
        THREADS=$THREADS bash "$SCRIPT_DIR/qc_fastqc_shortread.sh" \
            "$FASTP_OUT" "$CLEAN_FASTQC"
        ;;
    short-se)
        THREADS=$THREADS bash "$SCRIPT_DIR/qc_fastqc_shortread.sh" \
            "$INPUT_DIR" "$RAW_FASTQC"
        log "fastp ignorado: dataset short-read single-end"
        ;;
    long)
        THREADS=$THREADS bash "$SCRIPT_DIR/qc_nanoplot_longread.sh" \
            "$INPUT_DIR" "$NANOPLOT_OUT"
        ;;
esac

bash "$SCRIPT_DIR/qc_multiqc_aggregate.sh" \
    "$OUTPUT_DIR" "$MULTIQC_OUT" "$DATASET_NAME"

ELAPSED=$((SECONDS - START))
printf -v DURATION '%02d:%02d:%02d' \
    $((ELAPSED / 3600)) \
    $(((ELAPSED % 3600) / 60)) \
    $((ELAPSED % 60))

log "Pipeline concluido em $DURATION"
log "Relatorio: $MULTIQC_OUT/multiqc_report.html"
