#!/usr/bin/env bash
# =============================================================================
#  qc.sh - FastQC -> fastp -> FastQC -> MultiQC -> tabela resumo -> figuras
#
#  Uso:  ./qc.sh <container.sif> <projeto> <dir_saida> [dir_reads]
#
#  dir_reads e opcional; se omitido, usa o diretorio atual.
#  A saida das ferramentas vai para <dir_saida>/<projeto>/<projeto>_<data>.log
#
#  A tabela resumo e as figuras sao geradas pelo python do proprio container
#  (o env do MultiQC ja traz matplotlib), sem dependencia externa.
#
# =============================================================================

set -Eeuo pipefail

[[ $# -ge 3 ]] || { echo "Uso: $(basename "$0") <container.sif> <projeto> <dir_saida> [dir_reads]" >&2; exit 1; }

SIF="$(readlink -f "$1")"
PROJECT="$2"
OUT="$(readlink -f "$3")"
RAW="$(readlink -f "${4:-$PWD}")"

EXT="fastq.gz"
THREADS="${SLURM_CPUS_PER_TASK:-$(nproc)}"
BASE_PATH="/opt/conda/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PYTHON_BIN="/opt/conda/envs/multiqc/bin/python"   # python do container (traz matplotlib)

[[ -f "$SIF" ]] || { echo "ERRO: container inexistente: $SIF" >&2; exit 1; }
[[ -d "$RAW" ]] || { echo "ERRO: diretorio de reads inexistente: $RAW" >&2; exit 1; }

DIR="$OUT/$PROJECT"
QC1="$DIR/01_fastqc_raw"; FP="$DIR/02_fastp"; QC2="$DIR/03_fastqc_trimmed"
MQC="$DIR/04_multiqc"; TAB="$DIR/05_tabelas"; FIG="$DIR/06_figuras"; AUX="$DIR/00_scripts"
mkdir -p "$QC1" "$FP" "$QC2" "$MQC" "$TAB" "$FIG" "$AUX"
LOG="$DIR/${PROJECT}_$(date +%Y%m%d_%H%M%S).log"

msg() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
trap 'msg "ERRO na linha $LINENO. Veja: $LOG"' ERR

# Executa um app SCIF da imagem, com a saida redirecionada para o log
sing() {
    local app="$1"; shift
    singularity run --app "$app" --cleanenv \
        --env "PATH=/opt/conda/envs/${app}/bin:${BASE_PATH}" --env "LC_ALL=C" \
        -B "$RAW:$RAW:ro" -B "$OUT:$OUT" "$SIF" "$@" >>"$LOG" 2>&1
}

# Executa o python do container (etapas 5 e 6)
sing_py() {
    singularity exec --cleanenv --env "LC_ALL=C" \
        -B "$RAW:$RAW:ro" -B "$OUT:$OUT" "$SIF" "$PYTHON_BIN" "$@" >>"$LOG" 2>&1
}

# --- amostras ----------------------------------------------------------------
shopt -s nullglob
SUF=""
for s in _R1_001 _R1 _1; do
    R1S=( "$RAW"/*"${s}.${EXT}" )
    [[ ${#R1S[@]} -gt 0 ]] && { SUF="$s"; break; }
done
[[ -n "$SUF" ]] || R1S=( "$RAW"/*."$EXT" )
[[ ${#R1S[@]} -gt 0 ]] || { echo "ERRO: nenhum *.${EXT} em $RAW" >&2; exit 1; }

msg "Job iniciado | projeto: $PROJECT | ${#R1S[@]} amostra(s) | $THREADS threads"

# --- 1) FastQC nos reads brutos ----------------------------------------------
msg "Etapa 1/6 - FastQC (reads brutos): iniciada"
sing fastqc --threads "$THREADS" --outdir "$QC1" "$RAW"/*."$EXT"
msg "Etapa 1/6 - FastQC (reads brutos): concluida"

# --- 2) fastp ----------------------------------------------------------------
msg "Etapa 2/6 - fastp (trimagem): iniciada"
for R1 in "${R1S[@]}"; do
    SAMPLE="$(basename "$R1" ".${EXT}")"; SAMPLE="${SAMPLE%$SUF}"
    R2=""
    [[ -n "$SUF" ]] && R2="${R1/${SUF}.${EXT}/${SUF/1/2}.${EXT}}"

    if [[ -n "$R2" && -f "$R2" ]]; then
        sing fastp --in1 "$R1" --in2 "$R2" \
            --out1 "$FP/${SAMPLE}_R1.trimmed.$EXT" --out2 "$FP/${SAMPLE}_R2.trimmed.$EXT" \
            --json "$FP/$SAMPLE.fastp.json" --html "$FP/$SAMPLE.fastp.html" \
            --thread "$THREADS" --detect_adapter_for_pe \
            -5 -3 -y -p --qualified_quality_phred 20 --length_required 50
    else
        sing fastp --in1 "$R1" --out1 "$FP/${SAMPLE}.trimmed.$EXT" \
            --json "$FP/$SAMPLE.fastp.json" --html "$FP/$SAMPLE.fastp.html" \
            --thread "$THREADS" \
            -5 -3 -y -p --qualified_quality_phred 20 --length_required 50
    fi
done
msg "Etapa 2/6 - fastp (trimagem): concluida"

# --- 3) FastQC nos reads processados -----------------------------------------
msg "Etapa 3/6 - FastQC (reads processados): iniciada"
sing fastqc --threads "$THREADS" --outdir "$QC2" "$FP"/*.trimmed."$EXT"
msg "Etapa 3/6 - FastQC (reads processados): concluida"

# --- 4) MultiQC --------------------------------------------------------------
msg "Etapa 4/6 - MultiQC: iniciada"
sing multiqc --force --title "$PROJECT" --filename "${PROJECT}_multiqc_report.html" \
    --outdir "$MQC" "$QC1" "$FP" "$QC2"
msg "Etapa 4/6 - MultiQC: concluida"

# --- 5) Tabela resumo dos JSON do fastp --------------------------------------
msg "Etapa 5/6 - Tabela resumo do fastp: iniciada"
cat > "$AUX/fastp_summary.py" <<'PY'
#!/usr/bin/env python3
"""Consolida os JSON do fastp em uma tabela TSV.

Uso: fastp_summary.py <dir_json> <saida.tsv>
"""
import csv, glob, json, os, sys

json_dir, out = sys.argv[1], sys.argv[2]

rows = []
for f in sorted(glob.glob(os.path.join(json_dir, "*.fastp.json"))):
    with open(f) as fh:
        d = json.load(fh)
    b = d["summary"]["before_filtering"]
    a = d["summary"]["after_filtering"]
    rows.append({
        "amostra":         os.path.basename(f).replace(".fastp.json", ""),
        "reads_brutas":    b["total_reads"],
        "reads_filtradas": a["total_reads"],
        "pct_retidas":     round(100 * a["total_reads"] / b["total_reads"], 2) if b["total_reads"] else 0.0,
        "q30_antes_pct":   round(100 * b["q30_rate"], 2),
        "q30_depois_pct":  round(100 * a["q30_rate"], 2),
        "gc_pct":          round(100 * a["gc_content"], 2),
        "len_media_r1":    a.get("read1_mean_length", "NA"),
        "duplicacao_pct":  round(100 * d.get("duplication", {}).get("rate", 0), 2),
    })

if not rows:
    sys.exit(f"ERRO: nenhum *.fastp.json encontrado em {json_dir}")

os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=list(rows[0]), delimiter="\t", lineterminator="\n")
    w.writeheader()
    w.writerows(rows)
print(f"{len(rows)} amostras escritas em {out}")
PY
sing_py "$AUX/fastp_summary.py" "$FP" "$TAB/fastp_summary.tsv"
msg "Etapa 5/6 - Tabela resumo do fastp: concluida"

# --- 6) Figuras --------------------------------------------------------------
msg "Etapa 6/6 - Figuras: iniciada"
cat > "$AUX/fastp_figuras.py" <<'PY'
#!/usr/bin/env python3
"""Figuras a partir da tabela resumo do fastp.

Uso: fastp_figuras.py <fastp_summary.tsv> <dir_figuras>
"""
import csv, os, sys

import matplotlib
matplotlib.use("Agg")          # backend sem display, obrigatorio em no de calculo
import matplotlib.pyplot as plt

tsv, figdir = sys.argv[1], sys.argv[2]
os.makedirs(figdir, exist_ok=True)

with open(tsv) as fh:
    d = list(csv.DictReader(fh, delimiter="\t"))
if not d:
    sys.exit(f"ERRO: tabela vazia: {tsv}")

d.sort(key=lambda r: float(r["reads_filtradas"]))
amostras  = [r["amostra"] for r in d]
brutas    = [float(r["reads_brutas"]) / 1e6 for r in d]
filtradas = [float(r["reads_filtradas"]) / 1e6 for r in d]
q30_antes  = [float(r["q30_antes_pct"]) for r in d]
q30_depois = [float(r["q30_depois_pct"]) for r in d]

def limpa(ax):
    for lado in ("top", "right"):
        ax.spines[lado].set_visible(False)

# 1. Reads antes x depois da filtragem
y, h = range(len(amostras)), 0.38
fig, ax = plt.subplots(figsize=(7, max(3.0, 0.45 * len(amostras) + 1.5)))
ax.barh([i + h / 2 for i in y], brutas,    height=h, color="#a6a6a6", label="Bruto")
ax.barh([i - h / 2 for i in y], filtradas, height=h, color="#2c7fb8", label="Filtrado")
ax.set_yticks(list(y))
ax.set_yticklabels(amostras)
ax.set_xlabel("Milhoes de reads")
ax.set_title("Reads por amostra, antes e depois do fastp")
ax.legend(frameon=False, loc="lower right")
ax.grid(axis="x", alpha=0.3)
ax.set_axisbelow(True)
limpa(ax)
fig.tight_layout()
fig.savefig(os.path.join(figdir, "reads_por_amostra.png"), dpi=300)
plt.close(fig)

# 2. Ganho de qualidade (Q30)
lo = min(q30_antes + q30_depois) - 1
hi = max(q30_antes + q30_depois) + 1
fig, ax = plt.subplots(figsize=(6, 5))
ax.plot([lo, hi], [lo, hi], ls="--", color="#999999", lw=1)   # linha y = x
ax.scatter(q30_antes, q30_depois, s=45, color="#e6550d", zorder=3)
for nome, x, yv in zip(amostras, q30_antes, q30_depois):
    ax.annotate(nome, (x, yv), textcoords="offset points", xytext=(6, 4), fontsize=8)
ax.set_xlim(lo, hi)
ax.set_ylim(lo, hi)
ax.set_xlabel("% bases Q30 (bruto)")
ax.set_ylabel("% bases Q30 (filtrado)")
ax.set_title("Efeito da filtragem sobre a qualidade")
ax.grid(alpha=0.3)
ax.set_axisbelow(True)
limpa(ax)
fig.tight_layout()
fig.savefig(os.path.join(figdir, "q30_antes_depois.png"), dpi=300)
plt.close(fig)

print(f"Figuras salvas em {figdir}")
PY
sing_py "$AUX/fastp_figuras.py" "$TAB/fastp_summary.tsv" "$FIG"
msg "Etapa 6/6 - Figuras: concluida"

msg "Job finalizado | resultados em: $DIR"
