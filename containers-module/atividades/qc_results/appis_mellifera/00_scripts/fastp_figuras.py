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
