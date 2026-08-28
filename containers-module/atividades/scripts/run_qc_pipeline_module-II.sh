#!/usr/bin/env bash
#
# =============================================================================
#  run_qc_pipeline.sh  -  v2.0.0
#
#  Pipeline de controle de qualidade de reads via SingularityCE, projetado
#  para a imagem multi-app (SCIF) construida a partir de:
#      Bootstrap: docker / From: condaforge/miniforge3:24.7.1-0
#      apps: fastqc (0.12.1), fastp (0.23.4), multiqc (1.22.3)
#
#  Etapas:
#     1) FastQC   nos reads brutos
#     2) fastp    trimagem / filtragem
#     3) FastQC   nos reads processados
#     4) MultiQC  relatorio consolidado
#
#  Cada etapa e instrumentada: inicio, fim, duracao, exit code, pico de
#  memoria (max RSS) e uso de CPU sao gravados num TSV para benchmark.
#
#  Uso:
#     ./run_qc_pipeline.sh -p <projeto> -i <dir_reads> -o <dir_saida> \
#                          -s <imagem.sif> [-t <threads>] [-e <ext>] [-m app|exec]
#
#  SLURM:
#     sbatch run_qc_pipeline.sh -p projeto -i /dados/raw -o /dados/qc -s qc.sif -t 16
# =============================================================================

###SBATCH --job-name=qc_pipeline
###SBATCH --output=slurm-%x-%j.out
###SBATCH --error=slurm-%x-%j.err
###SBATCH --cpus-per-task=16
###SBATCH --mem=32G
###SBATCH --time=24:00:00

set -Eeuo pipefail

VERSION="2.0.0"
SCRIPT_NAME="$(basename "$0")"

# -----------------------------------------------------------------------------
# Mapeamento app -> diretorio bin do environment conda dentro do container
# (conforme o arquivo .def: cada ferramenta vive no seu proprio env)
# -----------------------------------------------------------------------------
declare -A ENV_BIN=(
    [fastqc]="/opt/conda/envs/fastqc/bin"
    [fastp]="/opt/conda/envs/fastp/bin"
    [multiqc]="/opt/conda/envs/multiqc/bin"
)

# PATH base do container (o env do app e prefixado a este valor)
BASE_PATH="/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Argumentos padrao do fastp (ajuste conforme o desenho experimental)
FASTP_ARGS_PE=(
    --detect_adapter_for_pe
    -5 -3 -y -p
    --qualified_quality_phred 20
    --length_required 50

)
FASTP_ARGS_SE=(
    -5 -3 -y -p
    --qualified_quality_phred 20
    --length_required 50
)

# -----------------------------------------------------------------------------
# Parametros
# -----------------------------------------------------------------------------
PROJECT=""; RAW_DIR=""; OUT_BASE=""; SIF=""
THREADS=8
EXT="fastq.gz"
RUN_MODE="app"          # app  -> singularity run --app <nome>
                        # exec -> singularity exec <caminho absoluto do binario>

usage() {
    cat <<EOF
${SCRIPT_NAME} v${VERSION}

Pipeline de QC (FastQC -> fastp -> FastQC -> MultiQC) via SingularityCE,
usando os apps SCIF definidos na imagem.

OBRIGATORIOS
  -p, --project   Nome do projeto
  -i, --input     Diretorio com os reads brutos (FASTQ)
  -o, --output    Diretorio raiz de saida
  -s, --sif       Caminho para a imagem .sif

OPCIONAIS
  -t, --threads   Threads por ferramenta (padrao: ${THREADS})
  -e, --ext       Extensao dos FASTQ (padrao: ${EXT})
  -m, --mode      'app' usa 'singularity run --app' (padrao);
                  'exec' usa 'singularity exec' com caminho absoluto do binario
  -h, --help      Esta mensagem

EXEMPLO
  ${SCRIPT_NAME} -p sugiyamaella_xyl -i /scratch/raw -o /scratch/qc \\
                 -s /containers/qc_tools.sif -t 16

SAIDA
  <output>/<projeto>/
      00_logs/            log de execucao + metricas TSV + versoes
      01_fastqc_raw/      FastQC dos reads brutos
      02_fastp/           reads limpos + relatorios JSON/HTML
      03_fastqc_trimmed/  FastQC dos reads processados
      04_multiqc/         relatorio consolidado
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--project) PROJECT="${2:-}";  shift 2 ;;
        -i|--input)   RAW_DIR="${2:-}";  shift 2 ;;
        -o|--output)  OUT_BASE="${2:-}"; shift 2 ;;
        -s|--sif)     SIF="${2:-}";      shift 2 ;;
        -t|--threads) THREADS="${2:-}";  shift 2 ;;
        -e|--ext)     EXT="${2:-}";      shift 2 ;;
        -m|--mode)    RUN_MODE="${2:-}"; shift 2 ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "ERRO: parametro desconhecido: $1" >&2; usage >&2; exit 2 ;;
    esac
done

for var in PROJECT RAW_DIR OUT_BASE SIF; do
    if [[ -z "${!var}" ]]; then
        echo "ERRO: parametro obrigatorio ausente: --${var,,}" >&2
        usage >&2; exit 2
    fi
done
[[ "$RUN_MODE" == "app" || "$RUN_MODE" == "exec" ]] || {
    echo "ERRO: --mode deve ser 'app' ou 'exec'." >&2; exit 2; }

# -----------------------------------------------------------------------------
# Diretorios
# -----------------------------------------------------------------------------
RAW_DIR="$(readlink -f "$RAW_DIR")"
OUT_BASE="$(readlink -f "$OUT_BASE")"
SIF="$(readlink -f "$SIF")"

PROJ_DIR="${OUT_BASE}/${PROJECT}"
LOG_DIR="${PROJ_DIR}/00_logs"
QC_RAW_DIR="${PROJ_DIR}/01_fastqc_raw"
FASTP_DIR="${PROJ_DIR}/02_fastp"
QC_TRIM_DIR="${PROJ_DIR}/03_fastqc_trimmed"
MULTIQC_DIR="${PROJ_DIR}/04_multiqc"

mkdir -p "$LOG_DIR" "$QC_RAW_DIR" "$FASTP_DIR" "$QC_TRIM_DIR" "$MULTIQC_DIR"

RUN_STAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${LOG_DIR}/${PROJECT}_${RUN_STAMP}.log"
METRICS_FILE="${LOG_DIR}/${PROJECT}_${RUN_STAMP}_metrics.tsv"
VERSIONS_FILE="${LOG_DIR}/${PROJECT}_${RUN_STAMP}_versoes.txt"
JOB_ID="${SLURM_JOB_ID:-local_$$}"

# -----------------------------------------------------------------------------
# Log
# -----------------------------------------------------------------------------
log() {
    local level="$1"; shift
    printf '[%s] [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*" | tee -a "$LOG_FILE"
}
log_raw() { printf '%s\n' "$*" | tee -a "$LOG_FILE"; }
log_header() {
    log_raw ""
    log_raw "==============================================================================="
    log_raw " $*"
    log_raw "==============================================================================="
}
fmt_hms() {
    local s="$1"
    printf '%02d:%02d:%02d' $(( s/3600 )) $(( (s%3600)/60 )) $(( s%60 ))
}

on_error() {
    local code=$?
    log "ERRO" "Falha na linha ${1:-?} (exit ${code}). Abortando pipeline."
    finalize "FALHOU" "$code"
    exit "$code"
}
trap 'on_error $LINENO' ERR

# -----------------------------------------------------------------------------
# Metricas
# -----------------------------------------------------------------------------
init_metrics() {
    printf 'job_id\tprojeto\tetapa\talvo\tinicio\tfim\tduracao_s\tduracao_hms\texit_code\tmax_rss_mb\tcpu_pct\tthreads\n' \
        > "$METRICS_FILE"
}
write_metric() {
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$JOB_ID" "$PROJECT" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" >> "$METRICS_FILE"
}

TIME_BIN=""
if command -v /usr/bin/time >/dev/null 2>&1 && /usr/bin/time -f "%e" true >/dev/null 2>&1; then
    TIME_BIN="/usr/bin/time"
fi

# -----------------------------------------------------------------------------
# Construcao do comando Singularity
#
#   build_cmd <app> [args...]  ->  popula o array global CMD[]
#
#   IMPORTANTE: e um array de comando real (binario + argumentos), nao uma
#   funcao de shell, porque /usr/bin/time precisa poder fazer exec() direto.
#
#   O PATH e injetado apontando para o bin do env conda do app. Isso garante
#   que dependencias internas (ex.: o java usado pelo FastQC) sejam resolvidas
#   mesmo sem 'conda activate', ja que os %apprun do .def chamam o binario por
#   caminho absoluto sem ajustar o PATH.
# -----------------------------------------------------------------------------
SINGULARITY_BIN="$(command -v singularity || true)"
declare -a CMD=()

build_cmd() {
    local app="$1"; shift
    local bin="${ENV_BIN[$app]}"

    CMD=( "$SINGULARITY_BIN" )
    if [[ "$RUN_MODE" == "app" ]]; then
        CMD+=( run --app "$app" )
    else
        CMD+=( exec )
    fi
    CMD+=(
        --cleanenv
        --env "PATH=${bin}:${BASE_PATH}"
        --env "LC_ALL=C"
        -B "${RAW_DIR}:${RAW_DIR}:ro"
        -B "${OUT_BASE}:${OUT_BASE}"
        "$SIF"
    )
    [[ "$RUN_MODE" == "exec" ]] && CMD+=( "${bin}/${app}" )
    CMD+=( "$@" )
}

# -----------------------------------------------------------------------------
# Executor instrumentado:  run_timed <etapa> <alvo> <comando...>
# -----------------------------------------------------------------------------
run_timed() {
    local step="$1"; shift
    local target="$1"; shift

    local start_epoch start_iso end_epoch end_iso rc=0 dur
    local max_rss_mb="NA" cpu_pct="NA"
    local tmp; tmp="$(mktemp)"

    start_epoch=$(date +%s); start_iso=$(date '+%Y-%m-%dT%H:%M:%S')
    log "INFO" ">> INICIO  | etapa=${step} | alvo=${target} | ${start_iso}"
    log "DEBUG" "   comando: $*"

    set +e
    if [[ -n "$TIME_BIN" ]]; then
        "$TIME_BIN" -f "%M\t%P" -o "$tmp" "$@" >>"$LOG_FILE" 2>&1
        rc=$?
    else
        "$@" >>"$LOG_FILE" 2>&1
        rc=$?
    fi
    set -e

    end_epoch=$(date +%s); end_iso=$(date '+%Y-%m-%dT%H:%M:%S')
    dur=$(( end_epoch - start_epoch ))

    if [[ -n "$TIME_BIN" && -s "$tmp" ]]; then
        local rss_kb
        rss_kb=$(awk -F'\t' 'NF>=2 {print $1}' "$tmp" | tail -n1)
        cpu_pct=$(awk -F'\t' 'NF>=2 {print $2}' "$tmp" | tail -n1)
        [[ "$rss_kb" =~ ^[0-9]+$ ]] && max_rss_mb=$(awk -v k="$rss_kb" 'BEGIN{printf "%.1f", k/1024}')
    fi
    rm -f "$tmp"

    write_metric "$step" "$target" "$start_iso" "$end_iso" "$dur" \
                 "$(fmt_hms "$dur")" "$rc" "$max_rss_mb" "$cpu_pct" "$THREADS"

    if [[ $rc -ne 0 ]]; then
        log "ERRO" "<< FALHA   | etapa=${step} | alvo=${target} | exit=${rc} | duracao=$(fmt_hms "$dur")"
        return "$rc"
    fi
    log "INFO" "<< FIM     | etapa=${step} | alvo=${target} | duracao=$(fmt_hms "$dur") | max_rss=${max_rss_mb} MB | cpu=${cpu_pct}"
    return 0
}

# -----------------------------------------------------------------------------
# Validacoes + captura de versoes (reprodutibilidade)
# -----------------------------------------------------------------------------
validate() {
    [[ -n "$SINGULARITY_BIN" ]] || { echo "ERRO: 'singularity' nao esta no PATH." >&2; exit 3; }
    [[ -d "$RAW_DIR" ]] || { echo "ERRO: diretorio de reads inexistente: $RAW_DIR" >&2; exit 3; }
    [[ -f "$SIF" ]]     || { echo "ERRO: imagem .sif inexistente: $SIF" >&2; exit 3; }
    [[ "$THREADS" =~ ^[0-9]+$ ]] || { echo "ERRO: --threads deve ser inteiro." >&2; exit 3; }

    log "INFO" "Modo de execucao: ${RUN_MODE}"
    {
        echo "# Versoes das ferramentas - ${PROJECT} - ${RUN_STAMP}"
        echo "# Imagem: ${SIF}"
        echo "# Singularity: $("$SINGULARITY_BIN" --version 2>/dev/null || echo NA)"
        echo "# Checksum da imagem (sha256):"
        sha256sum "$SIF" 2>/dev/null || echo "  NA"
        echo
    } > "$VERSIONS_FILE"

    local missing=0 out
    for app in fastqc fastp multiqc; do
        build_cmd "$app" --version
        set +e
        out="$("${CMD[@]}" 2>&1 | head -n1)"
        local rc=$?
        set -e
        if [[ $rc -eq 0 && -n "$out" ]]; then
            log "INFO" "App OK: ${app} -> ${out}"
            printf '%-10s %s\n' "$app" "$out" >> "$VERSIONS_FILE"
        else
            log "ERRO" "App indisponivel ou com falha: ${app} (exit ${rc}) :: ${out}"
            missing=1
        fi
    done

    if [[ $missing -eq 1 ]]; then
        log "ERRO" "Verifique se a imagem foi construida com as secoes %apprun do .def."
        log "ERRO" "Alternativa: reexecute com --mode exec (chama o binario por caminho absoluto)."
        exit 4
    fi
    log "INFO" "Versoes registradas em: ${VERSIONS_FILE}"
}

# -----------------------------------------------------------------------------
# Cabecalho do job
# -----------------------------------------------------------------------------
GLOBAL_START_EPOCH=$(date +%s)
GLOBAL_START_ISO=$(date '+%Y-%m-%dT%H:%M:%S')

log_header "INICIO DO JOB - PIPELINE DE QC"
log "INFO" "Script............: ${SCRIPT_NAME} v${VERSION}"
log "INFO" "Projeto...........: ${PROJECT}"
log "INFO" "Job ID............: ${JOB_ID}"
log "INFO" "Host..............: $(hostname)"
log "INFO" "Usuario...........: $(whoami)"
log "INFO" "Inicio............: ${GLOBAL_START_ISO}"
log "INFO" "Reads brutos......: ${RAW_DIR}"
log "INFO" "Saida.............: ${PROJ_DIR}"
log "INFO" "Imagem............: ${SIF}"
log "INFO" "Threads...........: ${THREADS}"
log "INFO" "Extensao FASTQ....: ${EXT}"
log "INFO" "CPUs no no........: $(nproc 2>/dev/null || echo NA)"
log "INFO" "Memoria total.....: $(awk '/MemTotal/ {printf "%.1f GB", $2/1048576}' /proc/meminfo 2>/dev/null || echo NA)"
log "INFO" "Log...............: ${LOG_FILE}"
log "INFO" "Metricas..........: ${METRICS_FILE}"
[[ -n "${SLURM_JOB_ID:-}" ]] && \
    log "INFO" "SLURM.............: particao=${SLURM_JOB_PARTITION:-NA} nos=${SLURM_JOB_NODELIST:-NA} cpus=${SLURM_CPUS_PER_TASK:-NA}"

init_metrics
validate

# -----------------------------------------------------------------------------
# ETAPA 0 - Descoberta das amostras
# -----------------------------------------------------------------------------
log_header "ETAPA 0 - DESCOBERTA DAS AMOSTRAS"

shopt -s nullglob
declare -a R1_FILES=()
R1_PATTERN=""

for pat in "_R1_001.${EXT}" "_R1.${EXT}" "_1.${EXT}"; do
    for f in "${RAW_DIR}"/*"${pat}"; do R1_FILES+=("$f"); done
    if [[ ${#R1_FILES[@]} -gt 0 ]]; then R1_PATTERN="$pat"; break; fi
done

PAIRED=1
if [[ ${#R1_FILES[@]} -eq 0 ]]; then
    for f in "${RAW_DIR}"/*."${EXT}"; do R1_FILES+=("$f"); done
    R1_PATTERN=".${EXT}"
    PAIRED=0
    log "AVISO" "Nenhum par R1/R2 reconhecido. Assumindo modo SINGLE-END."
fi

if [[ ${#R1_FILES[@]} -eq 0 ]]; then
    log "ERRO" "Nenhum FASTQ (*.${EXT}) encontrado em ${RAW_DIR}."
    exit 5
fi

N_SAMPLES=${#R1_FILES[@]}
log "INFO" "Padrao detectado..: *${R1_PATTERN}"
log "INFO" "Layout............: $([[ $PAIRED -eq 1 ]] && echo paired-end || echo single-end)"
log "INFO" "Amostras..........: ${N_SAMPLES}"
for f in "${R1_FILES[@]}"; do log "INFO" "  - $(basename "$f")"; done

# -----------------------------------------------------------------------------
# ETAPA 1 - FastQC (reads brutos)
# -----------------------------------------------------------------------------
log_header "ETAPA 1 - FASTQC (READS BRUTOS)"

declare -a RAW_ALL=()
for f in "${RAW_DIR}"/*."${EXT}"; do RAW_ALL+=("$f"); done
log "INFO" "Arquivos submetidos ao FastQC: ${#RAW_ALL[@]}"

build_cmd fastqc --threads "$THREADS" --outdir "$QC_RAW_DIR" "${RAW_ALL[@]}"
run_timed "01_fastqc_raw" "todas_amostras" "${CMD[@]}"

log "INFO" "Relatorios em: ${QC_RAW_DIR}"

# -----------------------------------------------------------------------------
# ETAPA 2 - fastp
# -----------------------------------------------------------------------------
log_header "ETAPA 2 - FASTP (TRIMAGEM E FILTRAGEM)"

IDX=0
for R1 in "${R1_FILES[@]}"; do
    IDX=$(( IDX + 1 ))
    BASE="$(basename "$R1")"
    SAMPLE="${BASE%%${R1_PATTERN}}"

    R2=""
    case "$R1_PATTERN" in
        "_R1_001.${EXT}") R2="${R1/_R1_001./_R2_001.}" ;;
        "_R1.${EXT}")     R2="${R1/_R1./_R2.}" ;;
        "_1.${EXT}")      R2="${R1/_1./_2.}" ;;
    esac

    JSON="${FASTP_DIR}/${SAMPLE}.fastp.json"
    HTML="${FASTP_DIR}/${SAMPLE}.fastp.html"

    if [[ -n "$R2" && -f "$R2" ]]; then
        log "INFO" "[${IDX}/${N_SAMPLES}] ${SAMPLE} (paired-end)"
        build_cmd fastp \
            --in1 "$R1" --in2 "$R2" \
            --out1 "${FASTP_DIR}/${SAMPLE}_R1.trimmed.${EXT}" \
            --out2 "${FASTP_DIR}/${SAMPLE}_R2.trimmed.${EXT}" \
            --json "$JSON" --html "$HTML" \
            --report_title "${PROJECT} - ${SAMPLE}" \
            --thread "$THREADS" \
            "${FASTP_ARGS_PE[@]}"
    else
        log "INFO" "[${IDX}/${N_SAMPLES}] ${SAMPLE} (single-end)"
        build_cmd fastp \
            --in1 "$R1" \
            --out1 "${FASTP_DIR}/${SAMPLE}.trimmed.${EXT}" \
            --json "$JSON" --html "$HTML" \
            --report_title "${PROJECT} - ${SAMPLE}" \
            --thread "$THREADS" \
            "${FASTP_ARGS_SE[@]}"
    fi

    run_timed "02_fastp" "$SAMPLE" "${CMD[@]}"
done

log "INFO" "Reads processados em: ${FASTP_DIR}"

# -----------------------------------------------------------------------------
# ETAPA 3 - FastQC (reads processados)
# -----------------------------------------------------------------------------
log_header "ETAPA 3 - FASTQC (READS PROCESSADOS)"

declare -a TRIM_ALL=()
for f in "${FASTP_DIR}"/*.trimmed."${EXT}"; do TRIM_ALL+=("$f"); done

if [[ ${#TRIM_ALL[@]} -eq 0 ]]; then
    log "ERRO" "Nenhum arquivo processado em ${FASTP_DIR}."
    exit 6
fi
log "INFO" "Arquivos submetidos ao FastQC: ${#TRIM_ALL[@]}"

build_cmd fastqc --threads "$THREADS" --outdir "$QC_TRIM_DIR" "${TRIM_ALL[@]}"
run_timed "03_fastqc_trimmed" "todas_amostras" "${CMD[@]}"

log "INFO" "Relatorios em: ${QC_TRIM_DIR}"

# -----------------------------------------------------------------------------
# ETAPA 4 - MultiQC
# -----------------------------------------------------------------------------
log_header "ETAPA 4 - MULTIQC (RELATORIO CONSOLIDADO)"

build_cmd multiqc \
    --force \
    --title "${PROJECT} - Controle de Qualidade" \
    --filename "${PROJECT}_multiqc_report.html" \
    --outdir "$MULTIQC_DIR" \
    "$QC_RAW_DIR" "$FASTP_DIR" "$QC_TRIM_DIR"
run_timed "04_multiqc" "$PROJECT" "${CMD[@]}"

log "INFO" "Relatorio: ${MULTIQC_DIR}/${PROJECT}_multiqc_report.html"

# -----------------------------------------------------------------------------
# Encerramento + sumario de benchmark
# -----------------------------------------------------------------------------
finalize() {
    local status="${1:-CONCLUIDO}" code="${2:-0}"
    local end_epoch end_iso total
    end_epoch=$(date +%s); end_iso=$(date '+%Y-%m-%dT%H:%M:%S')
    total=$(( end_epoch - GLOBAL_START_EPOCH ))

    write_metric "JOB_TOTAL" "$PROJECT" "$GLOBAL_START_ISO" "$end_iso" "$total" \
                 "$(fmt_hms "$total")" "$code" "NA" "NA" "$THREADS"

    log_header "FIM DO JOB - ${status}"
    log "INFO" "Inicio........: ${GLOBAL_START_ISO}"
    log "INFO" "Fim...........: ${end_iso}"
    log "INFO" "Tempo total...: $(fmt_hms "$total") (${total} s)"
    log "INFO" "Amostras......: ${N_SAMPLES:-NA}"
    log "INFO" "Status........: ${status} (exit ${code})"

    log_raw ""
    log_raw "--- BENCHMARK POR ETAPA ------------------------------------------------------"
    log_raw "  ETAPA                ALVO                       TEMPO     MAX_RSS      CPU"
    if [[ -s "$METRICS_FILE" ]]; then
        awk -F'\t' 'NR>1 {printf "  %-20s %-24s %9s  %8s MB  %7s\n", $3, $4, $8, $10, $11}' \
            "$METRICS_FILE" | tee -a "$LOG_FILE"
        log_raw ""
        log_raw "  Tempo acumulado por etapa:"
        awk -F'\t' 'NR>1 && $3!="JOB_TOTAL" {s[$3]+=$7} END {for (k in s) printf "    %-20s %8d s\n", k, s[k]}' \
            "$METRICS_FILE" | sort | tee -a "$LOG_FILE"
    fi
    log_raw "------------------------------------------------------------------------------"
    log "INFO" "Metricas (TSV): ${METRICS_FILE}"
    log "INFO" "Versoes.......: ${VERSIONS_FILE}"
    log "INFO" "Log completo..: ${LOG_FILE}"
}

trap - ERR
finalize "CONCLUIDO COM SUCESSO" 0
exit 0
