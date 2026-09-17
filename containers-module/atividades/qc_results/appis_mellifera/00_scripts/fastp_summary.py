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
